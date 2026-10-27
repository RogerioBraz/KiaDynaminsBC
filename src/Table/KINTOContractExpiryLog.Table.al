table 60004 "KINTO Contract Expiry Log"
{
    Caption = 'KINTO Contract Expiry Log';
    DataClassification = CustomerContent;

    // D4 — log do job de vencimento (rastreabilidade das acoes automaticas).

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Contract No."; Code[20]) { Caption = 'Contract No.'; }
        field(3; "Action Date"; Date) { Caption = 'Action Date'; }
        field(4; "Action Type"; Enum "KINTO Contract Expiry Action") { Caption = 'Action'; }
        field(5; "Days to Expiry"; Integer) { Caption = 'Days to Expiry'; }
        field(6; "Log Message"; Text[250]) { Caption = 'Log Message'; }
        field(7; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Contract No.", "Action Date") { }
    }
}
