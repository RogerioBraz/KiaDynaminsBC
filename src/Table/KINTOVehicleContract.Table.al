table 50200 "KINTO Vehicle Contract"
{
    Caption = 'KINTO Vehicle Contract';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Vehicle Contract List";
    DrillDownPageId = "KINTO Vehicle Contract Card";

    fields
    {
        field(1; "Contract No."; Code[20]) { Caption = 'Contract No.'; }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(4; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            TableRelation = "KINTO Quote Header";
        }
        field(5; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "KINTO Country Setup";
        }
        field(6; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(7; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(8; "License Plate"; Text[20])
        {
            Caption = 'License Plate';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Inventory Vehicle"."License Plate" where("Vehicle No." = field("Vehicle No.")));
            Editable = false;
        }
        field(9; "Fixed Asset No."; Code[20])
        {
            Caption = 'Fixed Asset No.';
            TableRelation = "Fixed Asset";
        }
        field(10; Status; Enum "KINTO Contract Status") { Caption = 'Status'; }
        field(11; "Start Date"; Date) { Caption = 'Start Date'; }
        field(12; "Original End Date"; Date) { Caption = 'Original End Date'; }
        field(13; "Current End Date"; Date) { Caption = 'Current End Date'; }
        field(14; "Termination Date"; Date) { Caption = 'Termination Date'; }
        field(15; "Termination Type"; Enum "KINTO Termination Type") { Caption = 'Termination Type'; }
        field(16; "Contract Term (Months)"; Integer) { Caption = 'Contract Term (months)'; }
        field(17; "Monthly Rent"; Decimal) { Caption = 'Monthly Rent'; }
        field(18; "Total Monthly Fee"; Decimal)
        {
            Caption = 'Total Monthly Fee';
            FieldClass = FlowField;
            CalcFormula = sum("KINTO Contract Condition"."Monthly Amount" where("Contract No." = field("Contract No."), Active = const(true)));
            Editable = false;
        }
        field(19; "Monthly Mileage (km)"; Decimal) { Caption = 'Monthly Mileage (km)'; }
        field(20; "Cost Center Code"; Code[20])
        {
            Caption = 'Cost Center Code';
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("Dimension Code"));
        }
        field(21; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            TableRelation = Dimension.Code;
            InitValue = 'COSTCENTER';
        }
        field(22; "High Risk"; Boolean) { Caption = 'High Risk'; }
        field(23; "Non-Operational"; Boolean) { Caption = 'Non-Operational'; }
        field(24; "Legal Proceeding"; Boolean) { Caption = 'Legal Proceeding'; }
        field(25; "Extension Count"; Integer) { Caption = 'Extension Count'; Editable = false; }
        field(26; "Amendment Count"; Integer) { Caption = 'Amendment Count'; Editable = false; }
        field(27; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(28; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(29; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(30; "Billing Day"; Integer)
        {
            Caption = 'Billing Day';
            InitValue = 1;
            MinValue = 1;
            MaxValue = 28;
        }
        field(31; "Price Index Code"; Code[10])
        {
            Caption = 'Price Index Code';
            TableRelation = "KINTO Price Index";
        }
        field(32; "Index Frequency"; Enum "KINTO Inflation Frequency") { Caption = 'Index Frequency'; }
        field(33; "Index Cap %"; Decimal)
        {
            Caption = 'Index Cap %';
            DecimalPlaces = 0 : 5;
        }
        field(34; "Last Billing Month"; Date) { Caption = 'Last Billing Month'; Editable = false; }
        field(35; "Retention Fee Indicated"; Boolean) { Caption = 'Retention Fee Indicated'; }
        field(36; "Payment Allowance Days"; Integer) { Caption = 'Payment Allowance (days)'; }
        field(37; "Retention Fee Amount"; Decimal) { Caption = 'Retention Fee Amount (monthly)'; DecimalPlaces = 2 : 2; }
        field(38; "Rescission Fee %"; Decimal)
        {
            Caption = 'Rescission Fee %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
        }
        field(39; "Rescission Waiver Days"; Integer) { Caption = 'Rescission Waiver (days)'; MinValue = 0; }
        field(40; "Excess Km Price (up to 10%)"; Decimal)
        {
            Caption = 'Excess Km Price (up to 10%)';
            DecimalPlaces = 2 : 2;
        }
        field(41; "Excess Km Price (above 10%)"; Decimal)
        {
            Caption = 'Excess Km Price (above 10%)';
            DecimalPlaces = 2 : 2;
        }
    }

    keys
    {
        key(PK; "Contract No.") { Clustered = true; }
        key(Idx1; "Customer No.") { }
        key(Idx2; "Vehicle No.") { }
        key(Idx3; Status) { }
        key(Idx4; "Current End Date") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        // Status default do enum (value 0) já é Draft

        if "Contract No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Contract Series', 'KINTO-CONTR');
            "Contract No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    trigger OnModify()
    begin
        // Expiração automática fica para o job de varredura de vencimentos (fase futura) —
        // evitar Modify dentro de OnModify (recursão).
    end;

    procedure Activate()
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        FixedAsset: Record "Fixed Asset";
        FleetMgt: Codeunit "KINTO Fleet Management";
        AlreadyActiveErr: Label 'Contract %1 is already active.';
        VehicleInUseErr: Label 'Vehicle %1 is already in contract %2.';
    begin
        TestField("Customer No.");
        TestField("Vehicle No.");
        TestField("Start Date");
        TestField("Current End Date");
        if Status = Status::Active then
            Error(AlreadyActiveErr, "Contract No.");

        // Bloqueia veículo em outro contrato ativo
        InventoryVehicle.Get("Vehicle No.");
        if (InventoryVehicle."Last Contract No." <> '') and (InventoryVehicle."Last Contract No." <> "Contract No.") then begin
            if VehicleContract.Get(InventoryVehicle."Last Contract No.") then
                if VehicleContract.Status in [Status::Active, Status::Extended] then
                    Error(VehicleInUseErr, "Vehicle No.", InventoryVehicle."Last Contract No.");
        end;

        Status := Status::Active;
        Modify(true);

        // Atualiza veículo: status In Contract + reserva + LEDGER (D7)
        FleetMgt.ChangeVehicleStatus(InventoryVehicle."Vehicle No.", InventoryVehicle.Status::"In Contract",
            '', StrSubstNo('Contract %1 activated', "Contract No."));
        InventoryVehicle."Last Contract No." := "Contract No.";
        InventoryVehicle.Modify(true);

        // Popula a extensão do Fixed Asset (ponte pronta no código atual)
        if "Fixed Asset No." <> '' then
            if FixedAsset.Get("Fixed Asset No.") then begin
                FixedAsset."KINTO Last Contract No." := "Contract No.";
                FixedAsset."KINTO Asset Status" := FixedAsset."KINTO Asset Status"::"In Contract";
                if FixedAsset."KINTO Booking Value" = 0 then
                    FixedAsset."KINTO Booking Value" := InventoryVehicle."Booking Value";
                FixedAsset.Modify(true);
            end;

        // Ativa as condições
        ContractCondition.Reset();
        ContractCondition.SetRange("Contract No.", "Contract No.");
        if ContractCondition.FindSet() then
            repeat
                ContractCondition.Active := true;
                ContractCondition.Modify(true);
            until ContractCondition.Next() = 0;
    end;

    procedure Terminate(TermType: Enum "KINTO Termination Type"; TermDate: Date)
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        FixedAsset: Record "Fixed Asset";
        AlreadyTermErr: Label 'Contract %1 is already terminated.';
    begin
        if Status in [Status::Terminated, Status::Cancelled] then
            Error(AlreadyTermErr, "Contract No.");
        TestField("Start Date");
        if TermDate = 0D then
            TermDate := WorkDate();

        Status := Status::Terminated;
        "Termination Type" := TermType;
        "Termination Date" := TermDate;
        Modify(true);

        if "Vehicle No." <> '' then
            if InventoryVehicle.Get("Vehicle No.") then begin
                InventoryVehicle.Status := InventoryVehicle.Status::Returned;
                InventoryVehicle.Modify(true);
            end;

        if "Fixed Asset No." <> '' then
            if FixedAsset.Get("Fixed Asset No.") then begin
                FixedAsset."KINTO Asset Status" := FixedAsset."KINTO Asset Status"::Returned;
                FixedAsset.Modify(true);
            end;

        // Inativa condições a partir da data de terminação
        ContractCondition.Reset();
        ContractCondition.SetRange("Contract No.", "Contract No.");
        if ContractCondition.FindSet() then
            repeat
                ContractCondition.Active := false;
                ContractCondition."Valid To" := TermDate;
                ContractCondition.Modify(true);
            until ContractCondition.Next() = 0;
    end;

    procedure Extend(NewEndDate: Date; WithRetention: Boolean)
    var
        AlreadyTermErr: Label 'Contract %1 is terminated and cannot be extended.';
    begin
        if Status in [Status::Terminated, Status::Cancelled] then
            Error(AlreadyTermErr, "Contract No.");
        TestField("Start Date");
        if NewEndDate <= "Current End Date" then
            FieldError("Current End Date");

        "Current End Date" := NewEndDate;
        "Extension Count" += 1;
        "Retention Fee Indicated" := WithRetention;
        Status := Status::Extended;
        Modify(true);

        // Reativa condições
        ContractCondition.Reset();
        ContractCondition.SetRange("Contract No.", "Contract No.");
        if ContractCondition.FindSet() then
            repeat
                ContractCondition.Active := true;
                ContractCondition.Modify(true);
            until ContractCondition.Next() = 0;
    end;

    var
        VehicleContract: Record "KINTO Vehicle Contract";
        ContractCondition: Record "KINTO Contract Condition";
}