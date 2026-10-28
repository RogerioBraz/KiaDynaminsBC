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
        LastEvaluation: Integer;

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


    // ============================================================
    // Numero de Evaluation a prova de colisao.
    // A serie (No. Series) pode devolver numero JA usado, porque o incremento
    // dela volta com o rollback da transacao enquanto o registro gravado
    // permanece. Aqui o numero vem do MAIOR sufixo numerico existente na
    // tabela + 1, com memoria de sessao para o caso de dois Inserts na mesma
    // transacao. Preserva o prefixo ja usado (ex.: 'EV-').
    // ============================================================
    procedure NextEvaluationNo(): Code[20]
    var
        Rec: Record "KINTO Contract Evaluation";
        MaxNo: Integer;
        Num: Integer;
        Candidate: Integer;
        Prefix: Text[10];
        SeenPrefix: Text[10];
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Evaluation No.");
        if Rec.FindSet() then
            repeat
                SplitNumber(Rec."Evaluation No.", Prefix, Num);
                if Num > 0 then begin
                    if Num > MaxNo then
                        MaxNo := Num;
                    if Prefix <> '' then
                        SeenPrefix := Prefix;
                end;
            until Rec.Next() = 0;

        Candidate := MaxNo + 1;
        if LastEvaluation >= Candidate then
            Candidate := LastEvaluation + 1;
        if Candidate < 1 then
            Candidate := 1;
        LastEvaluation := Candidate;

        // So usa 'EV-' quando a tabela esta VAZIA. Se ja existem registros sem
        // prefixo, manter sem prefixo preserva o padrao em uso.
        if (SeenPrefix = '') and (MaxNo = 0) then
            SeenPrefix := 'EV-';
        exit(FormatNumber(SeenPrefix, Candidate));
    end;

    // Separa 'EV-00010' em prefixo 'EV-' e numero 10.
    local procedure SplitNumber(Code: Code[20]; var Prefix: Text[10]; var Num: Integer)
    var
        i: Integer;
        LastDash: Integer;
        Tail: Text[20];
        Value: Integer;
    begin
        Prefix := '';
        Num := 0;
        LastDash := 0;
        for i := 1 to StrLen(Code) do
            if CopyStr(Code, i, 1) = '-' then
                LastDash := i;
        if LastDash > 0 then begin
            Prefix := CopyStr(Code, 1, LastDash);
            Tail := CopyStr(Code, LastDash + 1);
        end else
            Tail := Code;
        if Tail = '' then
            exit;
        if Evaluate(Value, Tail) then
            Num := Value;
    end;

    local procedure FormatNumber(Prefix: Text[10]; Value: Integer): Code[20]
    begin
        exit(CopyStr(Prefix + Format(Value, 0, '<Integer,5><Precision,0>'), 1, 20));
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
