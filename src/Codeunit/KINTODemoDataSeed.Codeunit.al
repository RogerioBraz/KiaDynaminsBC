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
        QuoteNo: Code[20];
        ContractNo: Code[20];
    begin
        QuoteNo := CreateQuoteWithItem(CountryCode, TermMonths, MonthlyKm, TargetROI);
        Quote.Get(QuoteNo);
        RunPricing(Quote);
        Quote.Get(QuoteNo);
        Quote."Pricing Status" := Quote."Pricing Status"::Approved;
        Quote.Modify(true);
        Quote.Get(QuoteNo);
        ContractNo := BillingMgt.CreateContractFromQuote(Quote);

        // Ativa o contrato
        ActivateContract(ContractNo);
        exit(ContractNo);
    end;

    local procedure ActivateContract(ContractNo: Code[20])
    var
        Contract: Record "KINTO Vehicle Contract";
    begin
        Contract.Get(ContractNo);
        if Contract.Status = Contract.Status::Active then
            exit;
        Contract.Status := Contract.Status::Active;
        if Contract."Start Date" = 0D then
            Contract."Start Date" := CalcDate('<-2M>', WorkDate());
        if Contract."Current End Date" = 0D then
            Contract."Current End Date" := CalcDate('<+22M>', Contract."Start Date");
        Contract.Modify(true);
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
        if not CountrySetup.Get('BR') then
            Error('Country Setup BR não existe — rode o setup padrão antes da carga demo.');
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