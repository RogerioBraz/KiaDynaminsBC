table 50400 "KINTO Vehicle Return"
{
    Caption = 'KINTO Vehicle Return';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Vehicle Return List";
    DrillDownPageId = "KINTO Vehicle Return Card";

    fields
    {
        field(1; "Return No."; Code[20]) { Caption = 'Return No.'; }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(3; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(4; "License Plate"; Text[20])
        {
            Caption = 'License Plate';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Inventory Vehicle"."License Plate" where("Vehicle No." = field("Vehicle No.")));
            Editable = false;
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(6; "Return Date"; Date) { Caption = 'Return Date'; }
        field(7; "Return Location"; Text[100]) { Caption = 'Return Location'; }
        field(8; Latitude; Decimal) { Caption = 'Latitude'; DecimalPlaces = 8 : 6; }
        field(9; Longitude; Decimal) { Caption = 'Longitude'; DecimalPlaces = 8 : 6; }
        field(10; Status; Enum "KINTO Return Status") { Caption = 'Status'; }
        field(11; "Odometer at Return"; Decimal) { Caption = 'Odometer at Return (km)'; DecimalPlaces = 0 : 1; }
        field(12; "Engine Hours at Return"; Decimal) { Caption = 'Engine Hours at Return'; DecimalPlaces = 0 : 1; }
        field(13; "Fuel Level %"; Decimal) { Caption = 'Fuel Level %'; DecimalPlaces = 0 : 2; MaxValue = 100; }
        field(14; "Checklist Complete"; Boolean) { Caption = 'Checklist Complete'; Editable = false; }
        field(15; "Cautelar Report No."; Code[20]) { Caption = 'Cautelar Report (laudo) No.'; }
        field(16; "Cautelar Result"; Option)
        {
            Caption = 'Cautelar Result';
            OptionMembers = " ",Approved,ApprovedWithReservations,Rejected;
        }
        field(17; "Total Damage Amount"; Decimal)
        {
            Caption = 'Total Damage Amount';
            FieldClass = FlowField;
            CalcFormula = sum("KINTO Damage Line".Amount where("Return No." = field("Return No.")));
            Editable = false;
        }
        field(18; "Customer Damage Amount"; Decimal)
        {
            Caption = 'Amount Charged to Customer';
            FieldClass = FlowField;
            CalcFormula = sum("KINTO Damage Line".Amount where("Return No." = field("Return No."), "Paid By" = const(Customer)));
            Editable = false;
        }
        field(19; "Dealer Charge Amount"; Decimal)
        {
            Caption = 'Amount Charged to Dealer';
            FieldClass = FlowField;
            CalcFormula = sum("KINTO Damage Line".Amount where("Return No." = field("Return No."), "Paid By" = const(Dealer)));
            Editable = false;
        }
        field(20; "Pending Items"; Boolean) { Caption = 'Pending Items (accessories/docs)'; Editable = false; }
        field(21; "Pending Items Desc."; Text[250]) { Caption = 'Pending Items Description'; }
        field(22; "Dealer Charge Doc No."; Code[20]) { Caption = 'Dealer Charge Document'; Editable = false; }
        field(23; "Billing Line Entry No."; Integer) { Caption = 'Billing Line Entry No.'; Editable = false; }
        field(24; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(25; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(26; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(27; Notes; Text[250]) { Caption = 'Notes'; }
        field(28; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
            field(29; "Contracted Total Mileage"; Decimal) { Caption = 'Contracted Total Mileage (km)'; Editable = false; }
        field(30; "Mileage Excess (km)"; Decimal) { Caption = 'Mileage Excess (km)'; Editable = false; }
        field(31; "Mileage Excess Charge"; Decimal) { Caption = 'Mileage Excess Charge'; Editable = false; }
}

    keys
    {
        key(PK; "Return No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
        key(Idx2; "Vehicle No.", "Return Date") { }
        key(Idx3; Status) { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Return No." = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-RET';
            "Return No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    // ============================================================
    // D5: DEVOLUÇÃO — checklist, laudo cautelar, danos
    // ============================================================
    procedure CompleteChecklist()
    var
        DamageLine: Record "KINTO Damage Line";
        NoDamagesErr: Label 'Return %1 has no damage lines — complete the inspection first.';
    begin
        if Status <> Status::"In Progress" then
            Error(StatusErr, "Return No.");
        TestField("Return Date");
        TestField("Odometer at Return");

        DamageLine.SetRange("Return No.", "Return No.");
        if DamageLine.IsEmpty() then
            Error(NoDamagesErr, "Return No.");

        "Checklist Complete" := true;
        // INT-06: pré-baixa gerada do checklist — veículo volta para o estoque
        Modify(true);
    end;

    procedure FinishReturn()
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Contract: Record "KINTO Vehicle Contract";
        DamageLine: Record "KINTO Damage Line";
        FleetMgt: Codeunit "KINTO Fleet Management";
        NotCompleteErr: Label 'Checklist for return %1 is not complete.';
    begin
        if not "Checklist Complete" then
            Error(NotCompleteErr, "Return No.");

        DamageLine.SetRange("Return No.", "Return No.");
        DamageLine.SetRange(Approved, false);
        DamageLine.SetFilter("Paid By", '<>%1', DamageLine."Paid By"::" ");
        if not DamageLine.IsEmpty() then
            "Pending Items" := true;

        Status := Status::Completed;
        if "Pending Items" then
            Status := Status::"With Pending Items";

        // Veículo: devolvido ao estoque (guardião fora de contrato — BR) + LEDGER (D7)
        if Vehicle.Get("Vehicle No.") then begin
            FleetMgt.ChangeVehicleStatus(Vehicle."Vehicle No.", Vehicle.Status::Returned,
                '', StrSubstNo('Return %1 completed', "Return No."));
            Vehicle.Status := Vehicle.Status::Returned;
            Vehicle."Current Odometer" := "Odometer at Return";
            Vehicle.Modify(true);
        end;

        Modify(true);
    end;

    // ============================================================
    // D5: COBRANÇA DOS DANOS AO CLIENTE (Billing Line)
    // ============================================================
    procedure BillDamagesToCustomer()
    var
        DamageLine: Record "KINTO Damage Line";
        Contract: Record "KINTO Vehicle Contract";
        BillingLine: Record "KINTO Billing Line";
        FinancialProduct: Record "KINTO Financial Product";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        TotalCustomer: Decimal;
        BillingMonth: Date;
        NothingErr: Label 'Return %1 has no approved customer damages to bill.';
        AlreadyErr: Label 'Return %1 damages already billed.';
    begin
        if "Billing Line Entry No." <> 0 then
            Error(AlreadyErr, "Return No.");

        DamageLine.SetRange("Return No.", "Return No.");
        DamageLine.SetRange("Paid By", DamageLine."Paid By"::Customer);
        DamageLine.SetRange(Approved, true);
        if DamageLine.FindSet() then
            repeat
                TotalCustomer += DamageLine.Amount;
            until DamageLine.Next() = 0;
        if TotalCustomer <= 0 then
            Error(NothingErr, "Return No.");

        Contract.Get("Contract No.");
        BillingMonth := CalcDate('<-CM>', "Return Date");

        if not FinancialProduct.Get('DAMAGE') then begin
            FinancialProduct.Init();
            FinancialProduct."Product Code" := 'DAMAGE';
            FinancialProduct.Description := 'Vehicle Damage Charge';
            FinancialProduct."Product Type" := FinancialProduct."Product Type"::"Additional Service";
            FinancialProduct."Separate Invoice" := true;
            FinancialProduct.Insert(true);
        end;

        BillingLine.Init();
        BillingLine."Contract No." := "Contract No.";
        BillingLine."Customer No." := "Customer No.";
        BillingLine."Vehicle No." := "Vehicle No.";
        BillingLine."Billing Month" := BillingMonth;
        BillingLine."Condition ID" := '';
        BillingLine."Financial Product Code" := 'DAMAGE';
        BillingLine."Product Type" := BillingLine."Product Type"::"Additional Service";
        BillingLine.Description := CopyStr(StrSubstNo('Damage charges — return %1', "Return No."), 1, MaxStrLen(BillingLine.Description));
        BillingLine.Quantity := 1;
        BillingLine."Days Billed" := 30;
        BillingLine."Unit Price" := TotalCustomer;
        BillingLine.Amount := TotalCustomer;
        BillingLine."Billing Period From" := CalcDate('<-CM>', BillingMonth);
        BillingLine."Billing Period To" := CalcDate('<CM>', BillingMonth);
        BillingLine."Currency Code" := "Currency Code";
        BillingLine."Cost Center Code" := Contract."Cost Center Code";
        BillingLine."Origin Description" := CopyStr(StrSubstNo('Return %1', "Return No."), 1, MaxStrLen(BillingLine."Origin Description"));
        BillingLine.Status := BillingLine.Status::Open;
        BillingLine.Insert(true);

        "Billing Line Entry No." := BillingLine."Entry No.";
        Modify(true);
    end;

    // ============================================================
    // D5: COBRANÇA DE PENDÊNCIAS AO DEALER (retorno com pendências)
    // ============================================================
    procedure ChargePendingItemsToDealer()
    var
        DamageLine: Record "KINTO Damage Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorNo: Code[20];
        AlreadyErr: Label 'Return %1 already has a dealer charge document.';
        NothingErr: Label 'Return %1 has no dealer-payable damages.';
    begin
        if "Dealer Charge Doc No." <> '' then
            Error(AlreadyErr, "Return No.");

        DamageLine.SetRange("Return No.", "Return No.");
        DamageLine.SetRange("Paid By", DamageLine."Paid By"::Dealer);
        DamageLine.SetRange(Approved, true);
        if DamageLine.IsEmpty() then
            Error(NothingErr, "Return No.");

        // Purchase Invoice contra o dealer responsável pela preparação
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", GetDealerVendor());
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader."KINTO Return No." := "Return No.";
        PurchaseHeader.Modify(true);

        DamageLine.FindSet();
        repeat
            PurchaseLine.Init();
            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
            PurchaseLine."Document No." := PurchaseHeader."No.";
            PurchaseLine."Line No." := DamageLine."Line No." * 10000;
            PurchaseLine.Insert(true);
            PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
            PurchaseLine.Validate("No.", GetDamageChargeAccount());
            PurchaseLine.Validate(Quantity, 1);
            PurchaseLine.Validate("Direct Unit Cost", DamageLine.Amount);
            PurchaseLine.Description := CopyStr(DamageLine.Description, 1, MaxStrLen(PurchaseLine.Description));
            PurchaseLine.Modify(true);
        until DamageLine.Next() = 0;

        "Dealer Charge Doc No." := PurchaseHeader."No.";
        Modify(true);
    end;

    local procedure GetDealerVendor(): Code[20]
    var
        Setup: Record "KINTO Termination Setup";
    begin
        Setup.Get();
        exit(Setup."Default Dealer Vendor No.");
    end;

    local procedure GetDamageChargeAccount(): Code[20]
    var
        Setup: Record "KINTO Termination Setup";
    begin
        Setup.Get();
        exit(Setup."Damage Charge Account");
    end;

    var
        StatusErr: Label 'Return %1 is not in progress.';
}