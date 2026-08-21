table 50126 "KINTO Vendor Contact"
{
    Caption = 'KINTO Vendor Contact (Portal)';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; Caption = 'Entry No.'; }
        field(2; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; TableRelation = Vendor; NotBlank = true; }
        field(3; "Contact Name"; Text[100]) { Caption = 'Contact Name'; NotBlank = true; }
        field(4; "Contact Email"; Text[100]) { Caption = 'Email'; }
        field(5; "Contact Phone"; Text[30]) { Caption = 'Phone'; }
        field(6; "Dealer Portal Access"; Boolean) { Caption = 'Dealer Portal Access'; }
        field(7; "Portal User ID"; Code[50]) { Caption = 'Portal User ID'; }
        field(8; Active; Boolean) { Caption = 'Active'; InitValue = true; }
    }

    keys { key(PK; "Entry No.") { Clustered = true; } key(Idx1; "Vendor No.") { } }
}
