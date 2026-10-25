table 50202 "KINTO Financial Product"
{
    Caption = 'KINTO Financial Product';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Financial Product List";
    DrillDownPageId = "KINTO Financial Product List";

    fields
    {
        field(1; "Product Code"; Code[20]) { Caption = 'Product Code'; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Product Type"; Enum "KINTO Financial Product Type") { Caption = 'Product Type'; }
        field(4; "Service Item No."; Code[20])
        {
            Caption = 'Service Item No.';
            TableRelation = Item."No." where(Type = const(Service));
        }
        field(5; "Service Item Description"; Text[100])
        {
            Caption = 'Service Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Service Item No.")));
            Editable = false;
        }
        field(6; "Unit Price"; Decimal) { Caption = 'Default Unit Price'; DecimalPlaces = 2 : 2; }
        field(7; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(8; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(9; "Separate Invoice"; Boolean)
        {
            Caption = 'Separate Invoice';
            InitValue = true;
        }
        field(10; "Regular/Additional"; Option) { Caption = 'Regular/Additional'; OptionMembers = Regular,Additional; }
        field(11; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "KINTO Country Setup";
        }
        field(12; Blocked; Boolean) { Caption = 'Blocked'; }
        field(13; "Credit Allowed"; Boolean) { Caption = 'Credit Allowed'; }
        field(14; "Credit Limit % of Billing"; Decimal)
        {
            Caption = 'Credit Limit % of Billing';
            DecimalPlaces = 0 : 5;
            InitValue = 2;
        }
    }

    keys
    {
        key(PK; "Product Code") { Clustered = true; }
        key(Idx1; "Product Type") { }
    }
}