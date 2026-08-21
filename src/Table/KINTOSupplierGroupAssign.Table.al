table 50128 "KINTO Supplier Group Assign"
{
    Caption = 'KINTO Supplier Group Assignment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Group Code"; Code[20]) { Caption = 'Group Code'; TableRelation = "KINTO Supplier Group"; NotBlank = true; }
        field(2; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; TableRelation = Vendor; NotBlank = true; }
        field(3; "Vendor Name"; Text[100]) { Caption = 'Vendor Name'; FieldClass = FlowField; CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No."))); Editable = false; }
    }

    keys { key(PK; "Group Code", "Vendor No.") { Clustered = true; } }
}

