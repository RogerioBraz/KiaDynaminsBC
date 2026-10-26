table 50468 "KINTO Task Instance"
{
    Caption = 'KINTO Task Instance';
    DataClassification = CustomerContent;

    // Tarefa gerada de um template para um caso concreto (recovery).

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Template Code"; Code[20]) { Caption = 'Template Code'; }
        field(3; "Step No."; Integer) { Caption = 'Step'; }
        field(4; "Recovery Case No."; Code[20]) { Caption = 'Recovery Case No.'; }
        field(5; "Contract No."; Code[20]) { Caption = 'Contract No.'; }
        field(6; Description; Text[100]) { Caption = 'Description'; }
        field(7; "Due Date"; Date) { Caption = 'Due Date'; }
        field(8; Completed; Boolean) { Caption = 'Completed'; }
        field(9; "Completed Date"; Date) { Caption = 'Completed Date'; }
        field(10; "Assigned To"; Code[50]) { Caption = 'Assigned To'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Recovery Case No.", "Step No.") { }
    }

    procedure NextEntryNo(): Integer
    var
        T: Record "KINTO Task Instance";
    begin
        if T.FindLast() then
            exit(T."Entry No." + 1);
        exit(1);
    end;
}
