table 50139 "KINTO Tire Package"
{
    Caption = 'KINTO Tire Package';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Tire Package List";

    fields
    {
        field(1; "Package ID"; Code[20]) { Caption = 'Package ID'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Rim Size"; Text[20]) { Caption = 'Rim Size'; }
        field(4; "Aspect Ratio"; Text[20]) { Caption = 'Aspect Ratio'; }
        field(5; "Section Width"; Text[20]) { Caption = 'Section Width'; }
        field(6; "Cost per Tire"; Decimal) { Caption = 'Cost per Tire'; AutoFormatType = 1; }
        field(7; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(8; "Default Quantity"; Integer) { Caption = 'Default Number of Tires'; }
        field(9; "Part Number"; Text[30]) { Caption = 'Part Number'; }
        field(10; "Usage Type"; Enum "KINTO Usage Type") { Caption = 'Usage Type'; }
        field(11; "Active Start Date"; Date) { Caption = 'Active Start Date'; }
        field(12; "Active End Date"; Date) { Caption = 'Active End Date'; }
        field(13; "Show on Dealer Portal"; Boolean) { Caption = 'Show on Dealer Portal'; InitValue = true; }
        field(14; "Block Pre-Approved Pricing"; Boolean) { Caption = 'Block Pre-Approved Pricing'; }
        field(15; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
        field(16; Status; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; InitValue = Active; }
    }

    keys { key(PK; "Package ID") { Clustered = true; } }

    procedure GetTotalCost(NumberOfTires: Integer): Decimal
    begin
        exit(Round("Cost per Tire" * NumberOfTires * (1 + "Markup %" / 100), 0.01));
    end;

    procedure GetMonthlyCost(NumberOfTires: Integer; ContractTermMonths: Integer): Decimal
    begin
        if ContractTermMonths = 0 then exit(0);
        exit(Round(GetTotalCost(NumberOfTires) / ContractTermMonths, 0.01));
    end;
}