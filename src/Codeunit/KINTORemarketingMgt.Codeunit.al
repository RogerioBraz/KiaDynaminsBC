codeunit 50171 "KINTO Remarketing Mgt."
{
    // D8 Remarketing — motor de venda do usado. BR: portal externo com
    // 3 touchpoints + preço mínimo/alvo c/ fórmula configurável + alçada
    // 4-olhos; venda ao motorista fecha o contrato na data do pagamento.
    // AR: cascata de canais c/ prazos (alvo 60 dias), baixa antes do
    // pagamento, estoque até a transferência de domínio.

    var
        NoOffersErr: Label 'Vehicle %1 has no open offer to accept.';
        NotApprovedErr: Label 'Sale %1 needs price approval (4-eyes) before invoicing.';
        AlreadySoldErr: Label 'Vehicle %1 already has an active remarketing sale.';
        ChannelDoneErr: Label 'Cascade finished for vehicle %1 — no channel accepted.';

    // ---------- INÍCIO DO PROCESSO ----------
    procedure StartRemarketing(VehicleNo: Code[20])
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        FleetMgt: Codeunit "KINTO Fleet Management";
    begin
        Vehicle.Get(VehicleNo);
        if Vehicle.Status = Vehicle.Status::Remarketing then
            exit;
        FleetMgt.ChangeVehicleStatus(VehicleNo, Vehicle.Status::Remarketing, '',
            'Remarketing process started');
        Vehicle.Get(VehicleNo);
        Vehicle.Status := Vehicle.Status::Remarketing;
        Vehicle.Modify(true);
    end;

    // ---------- PRECIFICAÇÃO (fontes ponderadas + fórmula) ----------
    procedure CalculatePrice(VehicleNo: Code[20]) : Decimal
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Setup: Record "KINTO Remarketing Setup";
        Source: Record "KINTO Remark. Pricing Source";
        WeightedPrice: Decimal;
        TotalWeight: Decimal;
    begin
        Vehicle.Get(VehicleNo);
        Setup.GetSetup(Vehicle."Country Code");

        Source.SetRange("Country Code", Vehicle."Country Code");
        Source.SetRange(Active, true);
        if Source.FindSet() then
            repeat
                WeightedPrice += Source."Reference Price" * (Source."Weight %" / 100);
                TotalWeight += Source."Weight %";
            until Source.Next() = 0;

        if TotalWeight > 0 then
            WeightedPrice := WeightedPrice * (100 / TotalWeight);

        // Depreciação por km (AR: Infoauto/ACARA/CCA − depreciação por km)
        if Vehicle."Current Odometer" > 0 then
            WeightedPrice := WeightedPrice * (1 - (Vehicle."Current Odometer" / GetDeprecBaseKm(Vehicle."Country Code") * (GetDeprecPercent(Vehicle."Country Code") / 100)));
        // (depreciação máx. 15% para 300.000 km — simplificação configurável depois)

        exit(Round(WeightedPrice, 1));
    end;

    // ---------- CASCATA DE CANAIS ----------
    procedure CreateCascadeOffers(VehicleNo: Code[20]) : Integer
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Channel: Record "KINTO Remarketing Channel";
        Offer: Record "KINTO Remarketing Offer";
        BasePrice: Decimal;
        OfferPrice: Decimal;
        Count: Integer;
    begin
        Vehicle.Get(VehicleNo);
        StartRemarketing(VehicleNo);
        BasePrice := CalculatePrice(VehicleNo);

        Channel.SetRange("Country Code", Vehicle."Country Code");
        Channel.SetRange(Active, true);
        if not Channel.FindSet() then
            Error('No active remarketing channels for country %1.', Vehicle."Country Code");

        repeat
            OfferPrice := BasePrice * (1 - Channel."Price Adj. %" / 100);
            Offer.Init();
            Offer."Offer No." := '';
            Offer."No. Series" := 'KINTO-RMK';
            Offer."Vehicle No." := VehicleNo;
            Offer."Contract No." := Vehicle."Last Contract No.";
            Offer."Step No." := Channel."Step No.";
            Offer."Channel Type" := Channel."Channel Type";
            Offer."Vendor No." := Channel."Vendor No.";
            Offer."Offer Price" := Round(OfferPrice, 1);
            Offer."Country Code" := Vehicle."Country Code";
            Offer.Insert(true);
            Count += 1;
        until Channel.Next() = 0;

        exit(Count);
    end;

    procedure SendOffer(var Offer: Record "KINTO Remarketing Offer")
    begin
        Offer.TestField("Offer Price");
        Offer.Status := Offer.Status::Sent;
        Offer."Sent Date" := WorkDate();
        Offer."Expiry Date" := CalcDate('<+7D>', WorkDate()); // prazo do canal — configurável
        Offer.Modify(true);
    end;

    procedure AcceptOffer(var Offer: Record "KINTO Remarketing Offer")
    var
        Sale: Record "KINTO Remarketing Sale";
        Vehicle: Record "KINTO Inventory Vehicle";
    begin
        if Offer.Status <> Offer.Status::Sent then
            Error(NoOffersErr, Offer."Vehicle No.");

        Vehicle.Get(Offer."Vehicle No.");
        Sale.SetRange("Vehicle No.", Offer."Vehicle No.");
        Sale.SetFilter(Status, '<>%1&<>%2', Sale.Status::Cancelled, Sale.Status::Completed);
        if not Sale.IsEmpty() then
            Error(AlreadySoldErr, Offer."Vehicle No.");

        Offer.Status := Offer.Status::Accepted;
        Offer."Response Date" := WorkDate();
        Offer.Modify(true);

        // Rejeita as demais ofertas do veículo
        RejectOtherOffers(Offer."Vehicle No.", Offer."Offer No.");

        // Cria a venda
        Sale.Init();
        Sale."Sale No." := '';
        Sale."No. Series" := 'KINTO-RMS';
        Sale."Vehicle No." := Offer."Vehicle No.";
        Sale."Contract No." := Offer."Contract No.";
        Sale."Offer No." := Offer."Offer No.";
        Sale."Buyer Type" := Offer."Channel Type";
        Sale."Buyer No." := Offer."Vendor No.";
        Sale."Sale Price" := Offer."Offer Price";
        Sale."Country Code" := Offer."Country Code";
        Sale."Sale Date" := WorkDate();
        Sale.Insert(true);
    end;

    local procedure RejectOtherOffers(VehicleNo: Code[20]; AcceptedOfferNo: Code[20])
    var
        Offer: Record "KINTO Remarketing Offer";
    begin
        Offer.SetRange("Vehicle No.", VehicleNo);
        Offer.SetRange(Status, Offer.Status::Sent);
        if Offer.FindSet() then
            repeat
                if Offer."Offer No." <> AcceptedOfferNo then begin
                    Offer.Status := Offer.Status::Rejected;
                    Offer."Response Date" := WorkDate();
                    Offer.Modify(true);
                end;
            until Offer.Next() = 0;
    end;

    // ---------- ALÇADA 4-OLHOS ----------
    procedure ApproveSalePrice(var Sale: Record "KINTO Remarketing Sale")
    var
        Setup: Record "KINTO Remarketing Setup";
    begin
        Sale.TestField("Sale Price");
        Setup.GetSetup(Sale."Country Code");
        if Setup."Four Eyes Approval" then begin
            Sale."Approved By" := CopyStr(UserId, 1, MaxStrLen(Sale."Approved By"));
            Sale."Approved DateTime" := CurrentDateTime;
        end;
        Sale.Status := Sale.Status::"Price Approved";
        Sale.Modify(true);
    end;

    // ---------- VENDA / FATURA / PAGAMENTO ----------
    procedure InvoiceSale(var Sale: Record "KINTO Remarketing Sale")
    var
        Setup: Record "KINTO Remarketing Setup";
        NotApproved: Boolean;
    begin
        Setup.GetSetup(Sale."Country Code");
        if Setup."Four Eyes Approval" and (Sale."Approved By" = '') then
            Error(NotApprovedErr, Sale."Sale No.");

        Sale.Status := Sale.Status::Invoiced;
        Sale."Invoice No." := CopyStr('SIM-' + Sale."Sale No.", 1, 20); // placeholder — Sales Invoice real depois
        Sale.Modify(true);

        // TP2 automático: lança a venda no portal (se integração ativa)
        EnqueuePortalSale(Sale);
    end;

    local procedure EnqueuePortalSale(var Sale: Record "KINTO Remarketing Sale")
    var
        PortalConfig: Record "KINTO Portal Config";
        PortalIntegration: Codeunit "KINTO Portal Integration";
    begin
        if not PortalConfig.GetConfig() then
            exit;
        if not PortalConfig.Enabled then
            exit;
        PortalIntegration.PostSaleToPortal(Sale);
    end;

    procedure RegisterPayment(var Sale: Record "KINTO Remarketing Sale"; PaymentDate: Date)
    var
        Setup: Record "KINTO Remarketing Setup";
        Vehicle: Record "KINTO Inventory Vehicle";
        Contract: Record "KINTO Vehicle Contract";
        FleetMgt: Codeunit "KINTO Fleet Management";
    begin
        Setup.GetSetup(Sale."Country Code");
        Sale.Status := Sale.Status::Paid;
        Sale."Payment Date" := PaymentDate;
        Sale.Modify(true);

        // BR: venda ao motorista fecha o contrato na data do pagamento
        if Setup."Sale to Driver Closes Contract" and Sale.IsDriverSale() then
            if (Sale."Contract No." <> '') and Contract.Get(Sale."Contract No.") then
                if Contract.Status in [Contract.Status::Active, Contract.Status::Extended] then
                    Contract.Terminate("KINTO Termination Type"::"End of Term", PaymentDate);

        // AR: baixa do ativo antes do pagamento
        if Setup."Write-off Before Payment" then
            WriteOffAsset(Sale);
    end;

    procedure CompleteSale(var Sale: Record "KINTO Remarketing Sale")
    var
        Setup: Record "KINTO Remarketing Setup";
        PortalConfig: Record "KINTO Portal Config";
    begin
        Setup.GetSetup(Sale."Country Code");

        // TP3 automático ANTES de completar (FIX 27/10): o WriteOffToPortal exige
        // Status=Paid — mudar p/ Completed ANTES do TP3 fazia o portal rejeitar
        // ("Sale %1 is not Paid") sempre que a integração estava ativa.
        if PortalConfig.GetConfig() then
            if PortalConfig.Enabled then
                PortalIntegrationHook.WriteOffToPortal(Sale);

        if not Setup."Write-off Before Payment" then
            WriteOffAsset(Sale); // BR: baixa após pagamento
        Sale.Status := Sale.Status::Completed;
        Sale.Modify(true);
    end;

    var
        PortalIntegrationHook: Codeunit "KINTO Portal Integration";

    local procedure WriteOffAsset(var Sale: Record "KINTO Remarketing Sale")
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        FleetMgt: Codeunit "KINTO Fleet Management";
    begin
        if Sale."Asset Written Off" then
            exit;
        if Vehicle.Get(Sale."Vehicle No.") then
            FleetMgt.ChangeVehicleStatus(Sale."Vehicle No.", Vehicle.Status::Inactive, '',
                StrSubstNo('Asset written off — sale %1', Sale."Sale No."));
        Sale."Asset Written Off" := true;
        Sale.Modify(true);
    end;

    local procedure GetDeprecBaseKm(CountryCode: Code[10]): Decimal
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CountrySetup.GetForCompanyOr(CountryCode) then
            if CountrySetup."Remarketing Km Deprec. Base" > 0 then
                exit(CountrySetup."Remarketing Km Deprec. Base");
        exit(300000);
    end;

    local procedure GetDeprecPercent(CountryCode: Code[10]): Decimal
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CountrySetup.GetForCompanyOr(CountryCode) then
            if CountrySetup."Remarketing Km Deprec. %" > 0 then
                exit(CountrySetup."Remarketing Km Deprec. %");
        exit(15);
    end;
}
