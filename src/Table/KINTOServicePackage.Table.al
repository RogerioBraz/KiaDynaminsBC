table 50140 "KINTO Service Package"
{
    Caption = 'KINTO Service Package';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Package ID"; Code[20]) { Caption = 'Package ID'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Cost"; Decimal) { Caption = 'Cost'; AutoFormatType = 1; }
        field(4; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(5; "Billing Frequency"; Enum "KINTO Billing Frequency") { Caption = 'Billing from Supplier Frequency'; }
        field(6; "Related Accessory No."; Code[20]) { Caption = 'Related Accessory'; TableRelation = Item; }
        field(7; "Active Start Date"; Date) { Caption = 'Active Start Date'; }
        field(8; "Active End Date"; Date) { Caption = 'Active End Date'; }
        field(9; "Show on Dealer Portal"; Boolean) { Caption = 'Show on Dealer Portal'; InitValue = true; }
        field(10; "Block Pre-Approved Pricing"; Boolean) { Caption = 'Block Pre-Approved Pricing'; }
        field(11; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
        field(12; Status; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; InitValue = Active; }
    }

    keys { key(PK; "Package ID") { Clustered = true; } }

    procedure GetMonthlyCost(): Decimal
    begin
        case "Billing Frequency" of
            "Billing Frequency"::Monthly:
                exit(Round(Cost * (1 + "Markup %" / 100), 0.01));
            "Billing Frequency"::"Semi-Annual":
                exit(Round(Cost * (1 + "Markup %" / 100) / 6, 0.01));
            "Billing Frequency"::Annual:
                exit(Round(Cost * (1 + "Markup %" / 100) / 12, 0.01));
        end;
        exit(0);
    end;
}