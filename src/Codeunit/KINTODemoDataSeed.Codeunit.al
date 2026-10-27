codeunit 50156 "KINTO Demo Data Seed"
{
    // ============================================================
    // SEED DE DADOS DE DEMONSTRAÇÃO — usado pelos testes E2E e pela
    // carga inicial (codeunit 50157). Cria cotações, contratos, multas,
    // tickets e danos de forma determinística e idempotente.
    // ============================================================

    var
        DemoCustomerNo: Code[20];
        DemoItemNo: Code[20];

    // ============================================================
    // COTAÇÃO COM ITEM (dentro da faixa da RV Matrix por padrão)
    // ============================================================
    procedure CreateQuoteWithItem(CountryCode: Code[10]; TermMonths: Integer; MonthlyKm: Decimal; TargetROI: Decimal): Code[20]
    var
        Quote: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
    begin
        EnsureDemoMasterData();

        Quote.Init();
        Quote."Quote No." := '';
        Quote."No. Series" := 'KINTO-QUOTE';
        Quote."Customer No." := DemoCustomerNo;
        Quote."Country Code" := CountryCode;
        Quote.Insert(true);

        QuoteItem.Init();
        QuoteItem."Quote No." := Quote."Quote No.";
        QuoteItem."Line No." := 10000;
        QuoteItem."Item No." := DemoItemNo;
        QuoteItem."Contract Term (Months)" := TermMonths;
        QuoteItem."Monthly Mileage (km)" := MonthlyKm;
        QuoteItem."Target ROI %" := TargetROI;
        QuoteItem."Payment Allowance (days)" := 5;
        QuoteItem."Vehicle Condition" := QuoteItem."Vehicle Condition"::New;
        QuoteItem."Usage Type" := QuoteItem."Usage Type"::Normal;
        QuoteItem.MSRP := GetDemoMSRP();
        QuoteItem.Insert(true);

        exit(Quote."Quote No.");
    end;

    procedure RunPricing(var Quote: Record "KINTO Quote Header")
    var
        Engine: Codeunit "KINTO Pricing Engine Mgt.";
        PricingContext: Codeunit "KINTO Pricing Context";
    begin
        PricingContext.BeginPricing();
        Engine.RunPricing(Quote);
        PricingContext.EndPricing();
    end;

    // ============================================================
    // CONTRATO ATIVO (cotação → pricing → approve → contract → activate)
    // ============================================================
    procedure CreateActiveContract(CountryCode: Code[10]; TermMonths: Integer; MonthlyKm: Decimal; TargetROI: Decimal): Code[20]
    var
        Quote: Record "KINTO Quote Header";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        PricingContext: Codeunit "KINTO Pricing Context";
        QuoteNo: Code[20];
        ContractNo: Code[20];
    begin
        QuoteNo := CreateQuoteWithItem(CountryCode, TermMonths, MonthlyKm, TargetROI);
        Quote.Get(QuoteNo);
        RunPricing(Quote);
        Quote.Get(QuoteNo);

        // Aprovação em contexto programático (guard não interfere)
        PricingContext.BeginPricing();
        Quote."Pricing Status" := Quote."Pricing Status"::Approved;
        Quote.Modify(true);
        PricingContext.EndPricing();
        Quote.Get(QuoteNo);

        if Quote."Pricing Status" <> Quote."Pricing Status"::Approved then
            Error('Quote %1 não ficou Approved após aprovação (status: %2)', QuoteNo, Quote."Pricing Status");

        ContractNo := BillingMgt.CreateContractFromQuote(Quote);

        // Vincula veículo demo ao contrato (multas/odômetro/pool precisam)
        EnsureDemoVehicle(ContractNo);

        // Ativa o contrato
        ActivateContract(ContractNo);
        exit(ContractNo);
    end;

    procedure EnsureDemoVehicle(ContractNo: Code[20])
    var
        Contract: Record "KINTO Vehicle Contract";
        Vehicle: Record "KINTO Inventory Vehicle";
        FleetMgt: Codeunit "KINTO Fleet Management";
    begin
        Contract.Get(ContractNo);
        if Contract."Vehicle No." <> '' then
            exit;

        // 1 veículo demo por contrato (placa única por contador)
        Vehicle.Init();
        Vehicle."Vehicle No." := '';
        Vehicle."No. Series" := 'KINTO-VEH';
        Vehicle."Item No." := DemoItemNo;
        Vehicle."License Plate" := CopyStr(StrSubstNo('DEM%1A99', GetVehicleCounter()), 1, 20);
        Vehicle."Vehicle Condition" := Vehicle."Vehicle Condition"::New;
        Vehicle."Current Odometer" := 35000;
        Vehicle."Acquisition Date" := CalcDate('<-6M>', WorkDate());
        Vehicle."Acquisition Cost" := GetDemoMSRP() * 0.85;
        Vehicle."Booking Value" := GetDemoMSRP();
        Vehicle."Country Code" := Contract."Country Code";
        Vehicle.Insert(true);

        // Movimento inicial no ledger (D7)
        FleetMgt.ChangeVehicleStatus(Vehicle."Vehicle No.", Vehicle.Status::"In Contract",
            '', StrSubstNo('Contract %1 activated (demo)', ContractNo));

        Contract."Vehicle No." := Vehicle."Vehicle No.";
        Contract.Modify(true);
    end;

    procedure CreateDemoDevice(VehicleNo: Code[20]; ContractNo: Code[20]): Code[20]
    var
        Device: Record "KINTO Telematic Device";
        FleetMgt: Codeunit "KINTO Fleet Management";
    begin
        Device.Init();
        Device."Device No." := '';
        Device."No. Series" := 'KINTO-DEV';
        Device.Description := 'Telemático demo (KINTO)';
        Device."Serial Number" := CopyStr('SN-DEMO-' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>'), 1, 50);
        // FIX 27/10: device demo COM vendor — sem vendor o aging pula o device
        // (e o cenário E2E de aging não gera cobrança)
        Device."Vendor No." := EnsureDemoVendor();
        Device."Country Code" := 'BR';
        Device.Insert(true);
        FleetMgt.InstallDevice(Device."Device No.", VehicleNo, ContractNo);
        exit(Device."Device No.");
    end;

    procedure CreateDemoPolicy(VehicleNo: Code[20]; ContractNo: Code[20]): Code[20]
    var
        Policy: Record "KINTO Insurance Policy";
    begin
        Policy.Init();
        Policy."Policy No." := '';
        Policy."No. Series" := 'KINTO-POL';
        Policy."Vehicle No." := VehicleNo;
        Policy."Policy Number (Ext.)" := 'APOL-DEMO-001';
        Policy.Description := 'Apólice demo (cobertura completa)';
        Policy.Status := Policy.Status::Active;
        Policy."Start Date" := CalcDate('<-1M>', WorkDate());
        Policy."End Date" := CalcDate('<+11M>', WorkDate());
        Policy."Annual Premium" := 4200;
        Policy."Monthly Cost" := 350;
        Policy."Coverage Type" := 'Compreensiva';
        Policy."Deductible Amount" := 5000;
        Policy."Contract No." := ContractNo;
        Policy."Country Code" := 'BR';
        Policy.Insert(true);
        exit(Policy."Policy No.");
    end;

    procedure EnsureDemoVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        // Vendor demo p/ dispositivos telemáticos (aging cobra dele)
        Vendor.SetRange(Name, 'Fornecedor Demo Telematica');
        if Vendor.FindFirst() then
            exit(Vendor."No.");
        Vendor.Init();
        Vendor.Insert(true);
        Vendor.Name := 'Fornecedor Demo Telematica';
        Vendor."Vendor Posting Group" := 'DOMESTIC';
        Vendor."Gen. Bus. Posting Group" := 'DOMESTIC';
        Vendor."VAT Bus. Posting Group" := 'DOMESTIC';
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure GetVehicleCounter(): Integer
    var
        Vehicle: Record "KINTO Inventory Vehicle";
    begin
        if Vehicle.FindLast() then
            exit(Vehicle.Count() + 1);
        exit(1);
    end;

    local procedure ActivateContract(ContractNo: Code[20])
    var
        Contract: Record "KINTO Vehicle Contract";
        Vehicle: Record "KINTO Inventory Vehicle";
    begin
        Contract.Get(ContractNo);
        if Contract.Status = Contract.Status::Active then
            exit;
        Contract.Status := Contract.Status::Active;
        // FIX 27/10: Start Date retroativo SEMPRE no demo — multas/billing/reajuste
        // precisam de vigência que cubra datas passadas (CreateContractFromQuote
        // seta Start Date = hoje, e a multa de -1M ficava fora da vigência).
        Contract."Start Date" := CalcDate('<-2M>', WorkDate());
        if Contract."Current End Date" = 0D then
            Contract."Current End Date" := CalcDate('<+22M>', Contract."Start Date");
        Contract.Modify(true);
        // FIX 27/10: vincula o veículo ao contrato (Last Contract No.) — sem isso
        // a oferta de remarketing nasce sem Contract No. e a venda ao motorista
        // não fecha o contrato no pagamento.
        if (Contract."Vehicle No." <> '') and Vehicle.Get(Contract."Vehicle No.") then
            if Vehicle."Last Contract No." = '' then begin
                Vehicle."Last Contract No." := ContractNo;
                Vehicle.Modify(true);
            end;
    end;

    // ============================================================
    // MULTA (vinculada a um contrato pela placa)
    // ============================================================
    procedure CreateFine(ContractNo: Code[20]; InfractionDate: Date): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        Fine: Record "KINTO Traffic Fine";
    begin
        Contract.Get(ContractNo);
        Fine.Init();
        Fine."Fine No." := '';
        Fine."No. Series" := 'KINTO-FINE';
        Fine."Vehicle No." := Contract."Vehicle No.";
        Fine."License Plate" := GetVehiclePlate(Contract."Vehicle No.");
        Fine."AIIP Code" := CopyStr('AIIP-' + Format(InfractionDate, 0, '<Year4><Month,2><Day,2>') + '-001', 1, 30);
        Fine."Issuing Authority Code" := 'DETRAN-SP';
        Fine."Infraction Code" := '745-50';
        Fine."Infraction Description" := 'Excesso de velocidade (demo)';
        Fine."Infraction DateTime" := CreateDateTime(InfractionDate, 143000T);
        Fine."Capture DateTime" := CreateDateTime(InfractionDate + 7, 090000T);
        Fine."Customer Amount" := 195.23;
        Fine."Vendor Amount" := 130.15;
        Fine."Full Amount" := 195.23;
        Fine."Country Code" := 'BR';
        Fine.Status := Fine.Status::Registered;
        Fine.Insert(true);
        exit(Fine."Fine No.");
    end;

    local procedure GetVehiclePlate(VehicleNo: Code[20]): Text[20]
    var
        Vehicle: Record "KINTO Inventory Vehicle";
    begin
        if Vehicle.Get(VehicleNo) then
            exit(Vehicle."License Plate");
        exit('');
    end;

    // ============================================================
    // TERMINAÇÃO + DANOS
    // ============================================================
    procedure TerminateContract(ContractNo: Code[20])
    var
        Contract: Record "KINTO Vehicle Contract";
    begin
        TerminateContract(ContractNo, "KINTO Termination Type"::"End of Term");
    end;

    procedure TerminateContract(ContractNo: Code[20]; TermType: Enum "KINTO Termination Type")
    var
        Contract: Record "KINTO Vehicle Contract";
    begin
        Contract.Get(ContractNo);
        if Contract.Status = Contract.Status::Terminated then
            exit;
        Contract.Terminate(TermType, WorkDate());
    end;

    procedure AddDamageLine(ReturnNo: Code[20]; Description: Text[100]; DamageClass: Enum "KINTO Damage Class"; Payer: Enum "KINTO Damage Payer"; Amount: Decimal)
    var
        DamageLine: Record "KINTO Damage Line";
        LineNo: Integer;
    begin
        DamageLine.SetRange("Return No.", ReturnNo);
        if DamageLine.FindLast() then
            LineNo := DamageLine."Line No." + 10000
        else
            LineNo := 10000;

        DamageLine.Init();
        DamageLine."Return No." := ReturnNo;
        DamageLine."Line No." := LineNo;
        DamageLine.Description := Description;
        DamageLine."Damage Class" := DamageClass;
        DamageLine."Paid By" := Payer;
        DamageLine.Amount := Amount;
        DamageLine.Insert(true);
        DamageLine.Approve();
    end;


    procedure AddTicketLine(TicketNo: Code[20]; Description: Text[100]; Quantity: Decimal; UnitCost: Decimal; BillToCustomer: Boolean)
    var
        TicketLine: Record "KINTO Maint Ticket Line";
        LineNo: Integer;
    begin
        TicketLine.SetRange("Ticket No.", TicketNo);
        if TicketLine.FindLast() then
            LineNo := TicketLine."Line No." + 10000
        else
            LineNo := 10000;

        TicketLine.Init();
        TicketLine."Ticket No." := TicketNo;
        TicketLine."Line No." := LineNo;
        TicketLine."Service Description" := Description;
        TicketLine.Quantity := Quantity;
        TicketLine."Unit Cost" := UnitCost;
        TicketLine."Bill to Customer" := BillToCustomer;
        if BillToCustomer then
            TicketLine."Customer Price" := UnitCost * 1.3; // margem demo 30%
        TicketLine.Insert(true);
    end;

    // ============================================================
    // MASTER DATA DE DEMONSTRAÇÃO (idempotente)
    // ============================================================
    procedure EnsureDemoMasterData()
    var
        Customer: Record Customer;
        Item: Record Item;
        Vehicle: Record "KINTO Inventory Vehicle";
        CountrySetup: Record "KINTO Country Setup";
    begin
        // Cliente demo
        if DemoCustomerNo = '' then begin
            Customer.SetRange(Name, 'Cliente Demo KINTO');
            if Customer.FindFirst() then
                DemoCustomerNo := Customer."No."
            else begin
                Customer.Init();
                Customer.Insert(true);
                Customer.Name := 'Cliente Demo KINTO';
                Customer."Customer Posting Group" := 'DOMESTIC';
                Customer."Gen. Bus. Posting Group" := 'DOMESTIC';
                Customer."VAT Bus. Posting Group" := 'DOMESTIC';
                Customer.Modify(true);
                DemoCustomerNo := Customer."No.";
            end;
        end;

        // Item demo: usa o 114743 (tem entrada na RV Matrix). Se não existir,
        // cria o item E a entrada na RV Matrix (36.000 km / 24 meses, RV 5%).
        if DemoItemNo = '' then begin
            if Item.Get('114743') then
                DemoItemNo := '114743'
            else begin
                Item.SetRange(Description, 'Veículo Demo KINTO');
                if Item.FindFirst() then
                    DemoItemNo := Item."No."
                else begin
                    Item.Init();
                    Item."No." := '';
                    Item.Insert(true);
                    Item.Description := 'Veículo Demo KINTO';
                    Item."Base Unit of Measure" := 'UNID';
                    Item.Modify(true);
                    DemoItemNo := Item."No.";
                end;
                EnsureRVMatrixEntry(DemoItemNo);
            end;
        end;

        // Country Setup BR (se não existir — o engine exige)
        if not CountrySetup.GetForCompanyOr('BR') then
            Error('Country Setup BR não existe — rode o setup padrão antes da carga demo.');

        // Garante RENT com service item (billing falha sem o vínculo)
        EnsureRentServiceItem();

        // Garante Reference Price nas fontes de remarketing (oferta nasce com preço 0 sem isso)
        EnsureRemarketingPrices();
    end;

    // FIX (27/10): o billing exige Financial Product RENT com Service Item No.
    // (Item Type=Service). O Install cria o produto SEM service item — se o
    // ambiente não tiver o vínculo, toda geração de billing falha com
    // "Financial product RENT not found or has no service item".
    procedure EnsureRentServiceItem()
    var
        FinProduct: Record "KINTO Financial Product";
        ServiceItem: Record Item;
        DemoItem: Record Item;
    begin
        if not FinProduct.Get('RENT') then
            exit; // Install cria o produto; nada a fazer aqui sem ele

        if FinProduct."Service Item No." <> '' then
            if DemoItem.Get(FinProduct."Service Item No.") then
                exit; // já configurado

        // Procura item de serviço demo existente
        ServiceItem.SetRange(Type, ServiceItem.Type::Service);
        ServiceItem.SetRange(Description, 'Serviço Locação KINTO');
        if ServiceItem.FindFirst() then begin
            FinProduct."Service Item No." := ServiceItem."No.";
            FinProduct.Modify(true);
            exit;
        end;

        // Cria o item de serviço demo (posting groups herdados do item demo 114743 se houver)
        ServiceItem.Init();
        ServiceItem."No." := '';
        ServiceItem.Insert(true);
        ServiceItem.Description := 'Serviço Locação KINTO';
        ServiceItem.Type := ServiceItem.Type::Service;
        ServiceItem."Base Unit of Measure" := 'UNID';
        if DemoItem.Get('114743') then begin
            ServiceItem."Gen. Prod. Posting Group" := DemoItem."Gen. Prod. Posting Group";
            ServiceItem."VAT Prod. Posting Group" := DemoItem."VAT Prod. Posting Group";
            ServiceItem."Inventory Posting Group" := DemoItem."Inventory Posting Group";
        end;
        ServiceItem.Modify(true);
        FinProduct."Service Item No." := ServiceItem."No.";
        FinProduct.Modify(true);
    end;

    // FIX (27/10): o Install cria as fontes de preço BR (FIPE/Webmotors) SEM
    // Reference Price → CalculatePrice devolve 0 → oferta nasce com preço 0 e
    // SendOffer estoura "Oferta Price deve ter um valor". Demo garante preços.
    procedure EnsureRemarketingPrices()
    var
        Source: Record "KINTO Remark. Pricing Source";
        Updated: Boolean;
    begin
        Updated := false;
        if Source.Get('BR', Source."Source Type"::FIPE) then
            if Source."Reference Price" = 0 then begin
                Source."Reference Price" := 100000;
                Source.Active := true;
                Source."Last Update" := WorkDate();
                Source.Modify(true);
                Updated := true;
            end;
        if Source.Get('BR', Source."Source Type"::Webmotors) then
            if Source."Reference Price" = 0 then begin
                Source."Reference Price" := 95000;
                Source.Active := true;
                Source."Last Update" := WorkDate();
                Source.Modify(true);
                Updated := true;
            end;
        // Sem fontes ativas nenhuma (ambiente limpo): cria as duas
        Source.Reset();
        Source.SetRange("Country Code", 'BR');
        Source.SetRange(Active, true);
        if Source.IsEmpty() then begin
            if not Source.Get('BR', Source."Source Type"::FIPE) then begin
                Source.Init();
                Source."Country Code" := 'BR';
                Source."Source Type" := Source."Source Type"::FIPE;
                Source."Reference Price" := 100000;
                Source."Weight %" := 60;
                Source.Active := true;
                Source."Last Update" := WorkDate();
                Source.Insert(true);
            end else begin
                Source."Reference Price" := 100000;
                Source.Active := true;
                Source."Last Update" := WorkDate();
                Source.Modify(true);
            end;
            if not Source.Get('BR', Source."Source Type"::Webmotors) then begin
                Source.Init();
                Source."Country Code" := 'BR';
                Source."Source Type" := Source."Source Type"::Webmotors;
                Source."Reference Price" := 95000;
                Source."Weight %" := 40;
                Source.Active := true;
                Source."Last Update" := WorkDate();
                Source.Insert(true);
            end else begin
                Source."Reference Price" := 95000;
                Source.Active := true;
                Source."Last Update" := WorkDate();
                Source.Modify(true);
            end;
        end;
    end;

    local procedure GetDemoMSRP(): Decimal
    begin
        exit(191190); // alinhado ao item 114743 da RV Matrix (36.000 km / 24 meses, RV 5%)
    end;

    local procedure EnsureRVMatrixEntry(ItemNo: Code[20])
    var
        RVMatrix: Record "KINTO RV Matrix";
    begin
        RVMatrix.SetRange("Item No.", ItemNo);
        RVMatrix.SetRange("Usage Type", RVMatrix."Usage Type"::Normal);
        RVMatrix.SetRange(Status, RVMatrix.Status::Active);
        if not RVMatrix.IsEmpty() then
            exit;

        // Faixa cobre os cenários demo: até 120.000 km e 48 meses, RV 5%
        RVMatrix.Init();
        RVMatrix."Item No." := ItemNo;
        RVMatrix."Usage Type" := RVMatrix."Usage Type"::Normal;
        RVMatrix."Has Implement" := false;
        RVMatrix."Effective Start Date" := CalcDate('<-1Y>', WorkDate());
        RVMatrix."Max Mileage" := 120000;
        RVMatrix."Max Age" := 48;
        RVMatrix."Tabulated Age" := 48;
        RVMatrix."Residual Value %" := 5;
        RVMatrix.Status := RVMatrix.Status::Active;
        RVMatrix."Created Date" := WorkDate();
        RVMatrix.Insert(true);
    end;
}