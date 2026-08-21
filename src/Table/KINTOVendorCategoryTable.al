table 50124 "KINTO Vendor Category"
{
    Caption = 'KINTO Vendor Category';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Category Code"; Code[20]) { Caption = 'Category Code'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Category Type"; Enum "KINTO Vendor Category Type") { Caption = 'Category Type'; }
        field(4; Active; Boolean) { Caption = 'Active'; InitValue = true; }
    }

    keys { key(PK; "Category Code") { Clustered = true; } }
}
