table 50125 "KINTO Vendor Category Assign"
{
    Caption = 'KINTO Vendor Category Assignment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; TableRelation = Vendor; NotBlank = true; }
        field(2; "Category Code"; Code[20]) { Caption = 'Category Code'; TableRelation = "KINTO Vendor Category"; NotBlank = true; }
        field(3; "Category Description"; Text[100]) { Caption = 'Description'; FieldClass = FlowField; CalcFormula = lookup("KINTO Vendor Category".Description where("Category Code" = field("Category Code"))); Editable = false; }
        field(4; "Is Primary"; Boolean) { Caption = 'Is Primary'; }
    }

    keys { key(PK; "Vendor No.", "Category Code") { Clustered = true; } }
}
