table 50115 "KINTO Maintenance Plan Header"
{
    Caption = 'KINTO Maintenance Plan Header';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Maint. Plan List";
    DrillDownPageId = "KINTO Maint. Plan Card";

    fields
    {
        field(1; "Plan ID"; Code[20]) { Caption = 'Plan ID'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Vehicle Model No."; Code[20]) { Caption = 'Vehicle Model'; TableRelation = "KINTO Vehicle Model"; }
        field(4; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item; }
        field(5; "Discount %"; Decimal) { Caption = 'Discount %'; DecimalPlaces = 0 : 5; }
        field(6; Status; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; }
        // Novos campos
        field(10; "Monetary Balance Amount"; Decimal) { Caption = 'Monetary Balance Amount'; AutoFormatType = 1; }
        field(11; "Monetary Balance Markup %"; Decimal) { Caption = 'Monetary Balance Markup %'; DecimalPlaces = 0 : 5; }
        field(12; Armoring; Boolean) { Caption = 'Covers Armored Vehicles'; }
        field(13; "Enable Pool"; Enum "KINTO Pool Rule Type") { Caption = 'Pool Rule'; }
        field(14; "Usage Type Filter"; Code[20]) { Caption = 'Usage Type Filter'; }
        field(15; "Associated Accessory No."; Code[20]) { Caption = 'Associated Accessory'; TableRelation = Item; }
        field(16; "Associated Optional No."; Code[20]) { Caption = 'Associated Optional/Implement'; TableRelation = Item; }
        field(17; "Active Start Date"; Date) { Caption = 'Active Start Date'; }
        field(18; "Active End Date"; Date) { Caption = 'Active End Date'; }
        field(19; "Show on Dealer Portal"; Boolean) { Caption = 'Show on Dealer Portal'; InitValue = true; }
        field(20; "Block Pre-Approved Pricing"; Boolean) { Caption = 'Block Pre-Approved Pricing'; }
        field(21; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
        field(22; "Created Date"; Date) { Caption = 'Created Date'; }
        field(23; "Modified Date"; Date) { Caption = 'Modified Date'; }
    }

    keys { key(PK; "Plan ID") { Clustered = true; } }

    trigger OnInsert()
    begin
        "Created Date" := Today;
        "Modified Date" := Today;
        if "Active Start Date" = 0D then "Active Start Date" := Today;
    end;

    trigger OnModify()
    begin
        "Modified Date" := Today;
    end;

    procedure GetTotalCostForContract(ContractTermMonths: Integer; EstimatedMileage: Decimal; CurrentOdometer: Decimal; CurrentAgeMonths: Integer): Decimal
    var
        MaintRange: Record "KINTO Maintenance Range";
        MaintNumber: Record "KINTO Maintenance Number";
        GenericRange: Record "KINTO Mainten Generic Range";
        TotalCost: Decimal;
        EndMileage: Decimal;
        EndAge: Integer;
    begin
        TotalCost := 0;
        EndMileage := CurrentOdometer + EstimatedMileage;
        EndAge := CurrentAgeMonths + ContractTermMonths;

        // Custo das faixas preventivas elegíveis
        MaintRange.SetRange("Plan ID", "Plan ID");
        MaintRange.SetRange(Active, true);
        MaintRange.SetFilter("Mileage Threshold", '<=%1', EndMileage);
        if MaintRange.FindSet() then
            repeat
                // Verifica se a faixa está dentro do período do contrato
                if (MaintRange."Age Threshold (Months)" <= EndAge) then begin
                    MaintNumber.SetRange("Plan ID", "Plan ID");
                    MaintNumber.SetRange("Range No.", MaintRange."Range No.");
                    if MaintNumber.FindSet() then
                        repeat
                            TotalCost += MaintNumber.Cost * MaintNumber.Quantity * (1 + MaintNumber."Markup %" / 100);
                        until MaintNumber.Next() = 0;
                end;
            until MaintRange.Next() = 0;

        // Custo do Generic Range (corretiva)
        GenericRange.SetRange("Plan ID", "Plan ID");
        GenericRange.SetRange(Active, true);
        if GenericRange.FindSet() then
            repeat
                TotalCost += GenericRange.Cost * GenericRange.Quantity * (1 + GenericRange."Markup %" / 100);
            until GenericRange.Next() = 0;

        // Monetary Balance
        if "Monetary Balance Amount" > 0 then
            TotalCost += "Monetary Balance Amount" * (1 + "Monetary Balance Markup %" / 100);

        exit(TotalCost);
    end;

    procedure GetMonthlyMaintenanceCost(ContractTermMonths: Integer; EstimatedMileage: Decimal; CurrentOdometer: Decimal; CurrentAgeMonths: Integer): Decimal
    var
        TotalCost: Decimal;
    begin
        if ContractTermMonths = 0 then exit(0);
        TotalCost := GetTotalCostForContract(ContractTermMonths, EstimatedMileage, CurrentOdometer, CurrentAgeMonths);
        exit(Round(TotalCost / ContractTermMonths, 0.01));
    end;
}