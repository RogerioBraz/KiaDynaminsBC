table 50447 "KINTO Remarketing Channel"
{
    Caption = 'KINTO Remarketing Channel';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Remarketing Channel List";
    DrillDownPageId = "KINTO Remarketing Channel List";

    fields
    {
        field(1; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(2; "Step No."; Integer) { Caption = 'Cascade Step'; }
        field(3; "Channel Type"; Enum "KINTO Remark. Channel Type") { Caption = 'Channel Type'; }
        field(4; Description; Text[100]) { Caption = 'Description'; }
        field(5; "Duration Days"; Integer) { Caption = 'Duration (days)'; }
        field(6; "Price Adj. %"; Decimal) { Caption = 'Price Adjustment % (cascade discount)'; }
        field(7; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No. (dealer)';
            TableRelation = Vendor;
        }
        field(8; Active; Boolean) { Caption = 'Active'; InitValue = true; }
    }

    keys
    {
        key(PK; "Country Code", "Step No.") { Clustered = true; }
    }
}
