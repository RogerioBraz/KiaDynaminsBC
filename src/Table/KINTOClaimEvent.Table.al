table 50470 "KINTO Claim Event"
{
    Caption = 'KINTO Claim Event';
    DataClassification = CustomerContent;

    // Log do ciclo do sinistro (D3c: log completo).

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Claim No."; Code[20])
        {
            Caption = 'Claim No.';
            TableRelation = "KINTO Claim";
        }
        field(3; "Event Date"; DateTime) { Caption = 'Event Date'; }
        field(4; Description; Text[250]) { Caption = 'Description'; }
        field(5; "User ID"; Code[50]) { Caption = 'User ID'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Claim No.") { }
    }
}
