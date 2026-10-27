codeunit 60006 "KINTO Entry No. Sequencer"
{
    // ============================================================
    // Entrega Entry No. para as tabelas de documento/log.
    // Por que existe:
    //  - AutoIncrement nao serve: o rollback da transacao de teste reinicia a
    //    sequencia e o Insert seguinte repete o numero;
    //  - MAX+1 sozinho tambem nao basta: dois Inserts na MESMA transacao leem
    //    o mesmo MAX (o segundo ainda nao esta visivel para o FindLast em
    //    alguns caminhos), e ambos escolhem o mesmo numero.
    // Solucao: SingleInstance guarda o ultimo numero ENTREGUE na sessao e
    // sempre devolve o maior entre (MAX+1 da tabela) e (ultimo entregue + 1).
    // ============================================================

    SingleInstance = true;

    var
        LastDocument: Integer;
        LastTelematic: Integer;
        LastDowntime: Integer;
        LastSLAViolation: Integer;
        LastExpiryLog: Integer;

    procedure NextDocumentEntryNo(): Integer
    var
        Rec: Record "KINTO Vehicle Document";
        TableMax: Integer;
    begin
        TableMax := MaxEntryNoDocument(Rec);
        LastDocument := NextFrom(TableMax, LastDocument);
        exit(LastDocument);
    end;

    procedure NextTelematicEntryNo(): Integer
    var
        Rec: Record "KINTO Telematic Event";
        TableMax: Integer;
    begin
        TableMax := MaxEntryNoTelematic(Rec);
        LastTelematic := NextFrom(TableMax, LastTelematic);
        exit(LastTelematic);
    end;

    procedure NextDowntimeEntryNo(): Integer
    var
        Rec: Record "KINTO Vehicle Downtime";
        TableMax: Integer;
    begin
        TableMax := MaxEntryNoDowntime(Rec);
        LastDowntime := NextFrom(TableMax, LastDowntime);
        exit(LastDowntime);
    end;

    procedure NextSLAViolationEntryNo(): Integer
    var
        Rec: Record "KINTO SLA Violation";
        TableMax: Integer;
    begin
        TableMax := MaxEntryNoViolation(Rec);
        LastSLAViolation := NextFrom(TableMax, LastSLAViolation);
        exit(LastSLAViolation);
    end;

    procedure NextExpiryLogEntryNo(): Integer
    var
        Rec: Record "KINTO Contract Expiry Log";
        TableMax: Integer;
    begin
        TableMax := MaxEntryNoExpiryLog(Rec);
        LastExpiryLog := NextFrom(TableMax, LastExpiryLog);
        exit(LastExpiryLog);
    end;

    local procedure NextFrom(TableMax: Integer; LastIssued: Integer): Integer
    var
        Candidate: Integer;
    begin
        Candidate := TableMax + 1;
        if LastIssued >= Candidate then
            Candidate := LastIssued + 1;
        if Candidate < 1 then
            Candidate := 1;
        exit(Candidate);
    end;

    local procedure MaxEntryNoDocument(var Rec: Record "KINTO Vehicle Document"): Integer
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Entry No.");
        if Rec.FindLast() then
            exit(Rec."Entry No.");
        exit(0);
    end;

    local procedure MaxEntryNoTelematic(var Rec: Record "KINTO Telematic Event"): Integer
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Entry No.");
        if Rec.FindLast() then
            exit(Rec."Entry No.");
        exit(0);
    end;

    local procedure MaxEntryNoDowntime(var Rec: Record "KINTO Vehicle Downtime"): Integer
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Entry No.");
        if Rec.FindLast() then
            exit(Rec."Entry No.");
        exit(0);
    end;

    local procedure MaxEntryNoViolation(var Rec: Record "KINTO SLA Violation"): Integer
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Entry No.");
        if Rec.FindLast() then
            exit(Rec."Entry No.");
        exit(0);
    end;

    local procedure MaxEntryNoExpiryLog(var Rec: Record "KINTO Contract Expiry Log"): Integer
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Entry No.");
        if Rec.FindLast() then
            exit(Rec."Entry No.");
        exit(0);
    end;
}
