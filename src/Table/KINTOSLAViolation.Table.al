table 60010 "KINTO SLA Violation"
{
    Caption = 'KINTO SLA Violation';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO SLA Violation List";
    DrillDownPageId = "KINTO SLA Violation List";

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Ticket No."; Code[20]) { Caption = 'Ticket No.'; }
        field(3; "Contract No."; Code[20]) { Caption = 'Contract No.'; }
        field(4; "Violation Type"; Enum "KINTO SLA Violation Type") { Caption = 'Violation Type'; }
        field(5; "Detected DateTime"; DateTime) { Caption = 'Detected DateTime'; }
        field(6; "Hours Elapsed"; Decimal) { Caption = 'Hours Elapsed'; DecimalPlaces = 0 : 2; }
        field(7; "SLA Target Hours"; Decimal) { Caption = 'SLA Target (hours)'; DecimalPlaces = 0 : 2; }
        field(8; "Penalty Amount"; Decimal) { Caption = 'Penalty Amount'; DecimalPlaces = 2 : 2; }
        field(9; "Credit Created"; Boolean) { Caption = 'Credit Created'; }
        field(10; Notes; Text[250]) { Caption = 'Notes'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Ticket No.", "Violation Type") { }
        key(Idx2; "Contract No.") { }
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            AssignEntryNo();
    end;

    // Atribui Entry No. unico. Usa MAX+1 e, se colidir (historico deixado por
    // execucao abortada), avanca ate achar um livre. AutoIncrement NAO serve aqui:
    // o rollback do harness de teste reinicia a sequencia e o Insert seguinte
    // repete o numero ("Ja existe o registro ... Entry No.='N'").
    local procedure AssignEntryNo()
    var
        Rec2: Record "KINTO SLA Violation";
        NextNo: Integer;
    begin
        Rec2.Reset();
        Rec2.SetCurrentKey("Entry No.");
        if Rec2.FindLast() then
            NextNo := Rec2."Entry No." + 1
        else
            NextNo := 1;
        while Rec2.Get(NextNo) do
            NextNo += 1;
        "Entry No." := NextNo;
    end;
}
