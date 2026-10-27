table 60009 "KINTO Ticket Subtask"
{
    Caption = 'KINTO Ticket Subtask';
    DataClassification = CustomerContent;

    // D3 — subtasks hierarquicas dentro do ticket de manutencao/atendimento.

    fields
    {
        field(1; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            TableRelation = "KINTO Maintenance Ticket"."Ticket No.";
            NotBlank = true;
        }
        field(2; "Subtask No."; Integer) { Caption = 'Subtask No.'; }
        field(3; Description; Text[250]) { Caption = 'Description'; }
        field(4; Status; Enum "KINTO Subtask Status") { Caption = 'Status'; }
        field(5; "Assigned To"; Code[50]) { Caption = 'Assigned To'; }
        field(6; "Due DateTime"; DateTime) { Caption = 'Due DateTime'; }
        field(7; "Completed DateTime"; DateTime) { Caption = 'Completed DateTime'; }
        field(8; "Sequence"; Integer) { Caption = 'Sequence'; }
        field(9; "Depends On Subtask"; Integer) { Caption = 'Depends On (Subtask No.)'; }
    }

    keys
    {
        key(PK; "Ticket No.", "Subtask No.") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        if Rec."Subtask No." = 0 then
            Rec."Subtask No." := GetNextSubtaskNo(Rec."Ticket No.");
    end;

    local procedure GetNextSubtaskNo(TicketNo: Code[20]): Integer
    var
        Subtask: Record "KINTO Ticket Subtask";
    begin
        Subtask.SetRange("Ticket No.", TicketNo);
        if Subtask.FindLast() then
            exit(Subtask."Subtask No." + 1);
        exit(1);
    end;
}
