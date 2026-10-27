codeunit 60003 "KINTO Pre-Closure Mgt."
{
    // ============================================================
    // D5 — PRE-FECHAMENTO: cria a pre-closure com projecoes
    // (km excedente, multas abertas, billing aberto) e converte
    // em devolucao quando o veiculo retorna.
    // ============================================================

    procedure CreatePreClosure(ContractNo: Code[20]; PlannedReturnDate: Date): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        PreClosure: Record "KINTO Pre-Closure";
    begin
        if not Contract.Get(ContractNo) then
            exit('');
        PreClosure.Init();
        PreClosure."Contract No." := ContractNo;
        PreClosure."Planned Return Date" := PlannedReturnDate;
        PreClosure.Status := PreClosure.Status::Draft;
        PreClosure.Insert(true);
        PreClosure.CalcForecasts();
        PreClosure.Modify(true);
        exit(PreClosure."Pre-Closure No.");
    end;

    procedure ConvertToReturn(PreClosureNo: Code[20]; ActualReturnDate: Date): Code[20]
    var
        PreClosure: Record "KINTO Pre-Closure";
        TermMgt: Codeunit "KINTO Termination Management";
        ReturnNo: Code[20];
    begin
        if not PreClosure.Get(PreClosureNo) then
            exit('');
        if PreClosure."Return No." <> '' then
            exit(PreClosure."Return No.");

        ReturnNo := TermMgt.CreateReturnFromContract(PreClosure."Contract No.", ActualReturnDate, '');
        PreClosure."Return No." := ReturnNo;
        PreClosure.Status := PreClosure.Status::Converted;
        PreClosure.Modify(true);
        exit(ReturnNo);
    end;
}
