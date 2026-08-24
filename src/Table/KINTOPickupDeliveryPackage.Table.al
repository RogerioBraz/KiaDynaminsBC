table 50137 "KINTO Pickup Delivery Package"
{
    Caption = 'KINTO Pick-up and Delivery Package';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Pickup Delivery List";
    fields
    {
        field(1; "Package ID"; Code[20]) { Caption = 'Package ID'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Coverage Km"; Decimal) { Caption = 'Coverage (km round trip)'; }
        field(4; "Cost per Excess Km"; Decimal) { Caption = 'Cost per Excess Km'; AutoFormatType = 1; }
        field(5; "Number of Uses"; Integer) { Caption = 'Number of Uses'; }
        field(6; "Cost"; Decimal) { Caption = 'Cost'; AutoFormatType = 1; }
        field(7; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(8; "Enable Pool"; Enum "KINTO Pool Rule Type") { Caption = 'Pool Rule'; }
        field(9; "Active Start Date"; Date) { Caption = 'Active Start Date'; }
        field(10; "Active End Date"; Date) { Caption = 'Active End Date'; }
        field(11; "Show on Dealer Portal"; Boolean) { Caption = 'Show on Dealer Portal'; InitValue = true; }
        field(12; "Block Pre-Approved Pricing"; Boolean) { Caption = 'Block Pre-Approved Pricing'; }
        field(13; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
        field(14; Status; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; InitValue = Active; }
    }

    keys { key(PK; "Package ID") { Clustered = true; } }

    procedure GetMonthlyCost(ContractTermMonths: Integer): Decimal
    begin
        if ContractTermMonths = 0 then exit(0);
        exit(Round(Cost * (1 + "Markup %" / 100) / ContractTermMonths, 0.01));
    end;
}