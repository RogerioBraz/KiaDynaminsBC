table 50457 "KINTO Remark. Pricing Source"
{
    Caption = 'KINTO Remarketing Pricing Source';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(2; "Source Type"; Enum "KINTO Remark. Source Type") { Caption = 'Source Type'; }
        field(3; "Reference Price"; Decimal) { Caption = 'Reference Price'; }
        field(4; "Weight %"; Decimal) { Caption = 'Weight %'; DecimalPlaces = 0 : 5; }
        field(5; Active; Boolean) { Caption = 'Active'; InitValue = true; }
        field(6; "Last Update"; Date) { Caption = 'Last Update'; }
    }

    keys
    {
        key(PK; "Country Code", "Source Type") { Clustered = true; }
    }
}
