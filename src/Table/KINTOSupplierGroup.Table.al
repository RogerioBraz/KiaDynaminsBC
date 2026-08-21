table 50127 "KINTO Supplier Group"
{
    Caption = 'KINTO Supplier Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Group Code"; Code[20]) { Caption = 'Group Code'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Category Type"; Enum "KINTO Vendor Category Type") { Caption = 'Service Type'; }
        field(4; Active; Boolean) { Caption = 'Active'; InitValue = true; }
        field(5; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
    }

    keys { key(PK; "Group Code") { Clustered = true; } }
}