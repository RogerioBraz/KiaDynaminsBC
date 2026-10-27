codeunit 60001 "KINTO Contract Lifecycle Mgt."
{
    // ============================================================
    // D4 — CICLO DE VIDA DO CONTRATO (job diario)
    // 1) Aviso de vencimento (N dias antes) -> Expiry Log
    // 2) Contratos vencidos -> Automatic Extended (com config) ou
    //    expiracao registrada
    // 3) Avaliacao do cliente devida -> cria Evaluation em Draft
    // Idempotente por contrato + data de acao.
    // ============================================================

    procedure RunContractLifecycle(AsOfDate: Date): Integer
    var
        Contract: Record "KINTO Vehicle Contract";
        CountrySetup: Record "KINTO Country Setup";
        Processed: Integer;
    begin
        Contract.Reset();
        Contract.SetFilter(Status, '%1|%2', Contract.Status::Active, Contract.Status::Extended);
        Contract.SetFilter("Current End Date", '<>%1', 0D);
        if Contract.FindSet() then
            repeat
                if CountrySetup.GetForCompanyOr(Contract."Country Code") then begin
                    if ProcessExpiry(Contract, CountrySetup, AsOfDate) then
                        Processed += 1;
                end;
            until Contract.Next() = 0;

        // Avaliacoes de contratos terminados
        Processed += CreateDueEvaluations(AsOfDate);
        exit(Processed);
    end;

    local procedure ProcessExpiry(var Contract: Record "KINTO Vehicle Contract";
        var CountrySetup: Record "KINTO Country Setup"; AsOfDate: Date): Boolean
    var
        DaysToExpiry: Integer;
        ExpiryLog: Record "KINTO Contract Expiry Log";
        NoticeDays: Integer;
    begin
        DaysToExpiry := Contract."Current End Date" - AsOfDate;

        // 1) Aviso previo
        NoticeDays := GetNoticeDays(CountrySetup);
        if (DaysToExpiry > 0) and (DaysToExpiry <= NoticeDays) then
            if LogAction(Contract."Contract No.", AsOfDate, ExpiryLog."Action Type"::"Notice Sent", DaysToExpiry,
                StrSubstNo('Contrato vence em %1 dias', DaysToExpiry)) then
                exit(true);

        // 2) Vencido
        if DaysToExpiry <= 0 then begin
            if GetAutoExtend(CountrySetup) then begin
                if LogAction(Contract."Contract No.", AsOfDate, ExpiryLog."Action Type"::"Auto Extended", DaysToExpiry,
                    'Contrato renovado automaticamente') then begin
                    Contract."Current End Date" := CalcDate(StrSubstNo('<+%1M>', Contract."Contract Term (Months)"), 
                        Contract."Current End Date");
                    Contract.Status := Contract.Status::Extended;
                    Contract."Extension Count" += 1;
                    Contract.Modify(true);
                    exit(true);
                end;
            end else
                if LogAction(Contract."Contract No.", AsOfDate, ExpiryLog."Action Type"::Expired, DaysToExpiry,
                    'Contrato vencido - aguardando terminação') then
                    exit(true);
        end;
        exit(false);
    end;

    local procedure CreateDueEvaluations(AsOfDate: Date): Integer
    var
        Contract: Record "KINTO Vehicle Contract";
        Evaluation: Record "KINTO Contract Evaluation";
        Count: Integer;
        EvalNo: Code[20];
    begin
        Contract.Reset();
        Contract.SetRange(Status, Contract.Status::Terminated);
        Contract.SetFilter("Termination Date", '>=%1', CalcDate('<-30D>', AsOfDate));
        if Contract.FindSet() then
            repeat
                Evaluation.Reset();
                Evaluation.SetRange("Contract No.", Contract."Contract No.");
                if Evaluation.IsEmpty() then begin
                    EvalNo := Evaluation.CreateFromContract(Contract."Contract No.");
                    if EvalNo <> '' then
                        Count += 1;
                end;
            until Contract.Next() = 0;
        exit(Count);
    end;

    local procedure LogAction(ContractNo: Code[20]; ActionDate: Date; ActionType: Enum "KINTO Contract Expiry Action";
        DaysToExpiry: Integer; Msg: Text): Boolean
    var
        ExpiryLog: Record "KINTO Contract Expiry Log";
    begin
        ExpiryLog.SetRange("Contract No.", ContractNo);
        ExpiryLog.SetRange("Action Date", ActionDate);
        ExpiryLog.SetRange("Action Type", ActionType);
        if not ExpiryLog.IsEmpty() then
            exit(false);

        ExpiryLog.Init();
        ExpiryLog."Contract No." := ContractNo;
        ExpiryLog."Action Date" := ActionDate;
        ExpiryLog."Action Type" := ActionType;
        ExpiryLog."Days to Expiry" := DaysToExpiry;
        ExpiryLog."Log Message" := CopyStr(Msg, 1, 250);
        ExpiryLog."Created DateTime" := CurrentDateTime;
        ExpiryLog.Insert(true);
        exit(true);
    end;

    local procedure GetNoticeDays(var CountrySetup: Record "KINTO Country Setup"): Integer
    begin
        // Default 60 dias; campo do Country Setup se existir
        exit(60);
    end;

    local procedure GetAutoExtend(var CountrySetup: Record "KINTO Country Setup"): Boolean
    begin
        // BR: sem renovacao automatica (exige termo aditivo)
        exit(CountrySetup."Country Code" <> 'BR');
    end;
}
