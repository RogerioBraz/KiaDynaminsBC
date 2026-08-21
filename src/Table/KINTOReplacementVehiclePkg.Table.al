table 50138 "KINTO Replacement Vehicle Pkg"
{
    Caption = 'KINTO Replacement Vehicle Package';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Package ID"; Code[20]) { Caption = 'Package ID'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Category Code"; Code[20]) { Caption = 'Category'; }
        field(4; "Category Description"; Text[50]) { Caption = 'Category Description'; }
        field(5; "Cost"; Decimal) { Caption = 'Cost per Use'; AutoFormatType = 1; }
        field(6; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(7; "Default Uses"; Integer) { Caption = 'Default Number of Uses'; }
        field(8; "Enable Pool"; Enum "KINTO Pool Rule Type") { Caption = 'Pool Rule'; }
        field(9; "Active Start Date"; Date) { Caption = 'Active Start Date'; }
        field(10; "Active End Date"; Date) { Caption = 'Active End Date'; }
        field(11; "Show on Dealer Portal"; Boolean) { Caption = 'Show on Dealer Portal'; InitValue = true; }
        field(12; "Block Pre-Approved Pricing"; Boolean) { Caption = 'Block Pre-Approved Pricing'; }
        field(13; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
        field(14; Status; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; InitValue = Active; }
    }

    keys { key(PK; "Package ID") { Clustered = true; } }

    procedure GetTotalCost(NumberOfUses: Integer): Decimal
    begin
        exit(Round(Cost * NumberOfUses * (1 + "Markup %" / 100), 0.01));
    end;

    procedure GetMonthlyCost(NumberOfUses: Integer; ContractTermMonths: Integer): Decimal
    begin
        if ContractTermMonths = 0 then exit(0);
        exit(Round(GetTotalCost(NumberOfUses) / ContractTermMonths, 0.01));
    end;
}