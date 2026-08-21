table 50129 "KINTO Item Supplier Group"
{
    Caption = 'KINTO Item Supplier Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item; NotBlank = true; }
        field(2; "Group Code"; Code[20]) { Caption = 'Supplier Group'; TableRelation = "KINTO Supplier Group"; NotBlank = true; }
        field(3; "Group Description"; Text[100]) { Caption = 'Group Description'; FieldClass = FlowField; CalcFormula = lookup("KINTO Supplier Group".Description where("Group Code" = field("Group Code"))); Editable = false; }
    }

    keys { key(PK; "Item No.", "Group Code") { Clustered = true; } }
}