table 50135 "KINTO Glass Coverage Package"
{
    Caption = 'KINTO Glass Coverage Package';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Glass Coverage List";

    fields
    {
        field(1; "Package ID"; Code[20]) { Caption = 'Package ID'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Deductible"; Decimal) { Caption = 'Deductible (Flat)'; AutoFormatType = 1; }
        field(4; "Coverage Limit"; Decimal) { Caption = 'Coverage Limit (Flat)'; AutoFormatType = 1; }
        field(5; "Balance Uses"; Integer) { Caption = 'Balance (Number of Uses)'; }
        field(6; "Monetary Balance"; Decimal) { Caption = 'Monetary Balance'; AutoFormatType = 1; }
        field(7; "Cost"; Decimal) { Caption = 'Cost'; AutoFormatType = 1; }
        field(8; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(9; Armoring; Boolean) { Caption = 'Available for Armored'; }
        field(10; "Insurance Supplier ID"; Integer) { Caption = 'Insurance Supplier'; TableRelation = "KINTO Insurer"; }
        field(11; "Active Start Date"; Date) { Caption = 'Active Start Date'; }
        field(12; "Active End Date"; Date) { Caption = 'Active End Date'; }
        field(13; "Show on Dealer Portal"; Boolean) { Caption = 'Show on Dealer Portal'; InitValue = true; }
        field(14; "Block Pre-Approved Pricing"; Boolean) { Caption = 'Block Pre-Approved Pricing'; }
        field(15; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
        field(16; Status; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; InitValue = Active; }
    }

    keys { key(PK; "Package ID") { Clustered = true; } }

    procedure GetMonthlyCost(ContractTermMonths: Integer): Decimal
    begin
        if ContractTermMonths = 0 then exit(0);
        exit(Round(Cost * (1 + "Markup %" / 100) / ContractTermMonths, 0.01));
    end;
}