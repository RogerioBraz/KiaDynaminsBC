codeunit 50211 "KINTO Price Adjustment Sch."
{
    // D6: reajuste por índice — agendamento por frequência do contrato
    // (Monthly/Quarterly/Annually), cap % do contrato, exceção com carta
    // prévia (retroativo). Idempotente por contrato/mês (Adjustment Ledger).

    var
        NoIndexErr: Label 'Contract %1 has no price index configured.';
        AlreadyAdjustedErr: Label 'Contract %1 already adjusted for month %2.';

    procedure RunAdjustments(AdjustmentMonth: Date): Integer
    var
        Contract: Record "KINTO Vehicle Contract";
        Adjusted: Integer;
    begin
        Contract.Reset();
        Contract.SetFilter(Status, '%1|%2', Contract.Status::Active, Contract.Status::Extended);
        Contract.SetFilter("Price Index Code", '<>%1', '');
        if Contract.FindSet() then
            repeat
                if IsDue(Contract, AdjustmentMonth) then
                    if TryAdjust(Contract, AdjustmentMonth) then
                        Adjusted += 1;
            until Contract.Next() = 0;
        exit(Adjusted);
    end;

    local procedure IsDue(Contract: Record "KINTO Vehicle Contract"; AdjustmentMonth: Date): Boolean
    var
        AdjustmentLedger: Record "KINTO Adjustment Ledger";
        StartDate: Date;
    begin
        // Idempotência: já ajustado neste mês?
        AdjustmentLedger.SetRange("Contract No.", Contract."Contract No.");
        AdjustmentLedger.SetRange("Adjustment Month", AdjustmentMonth);
        if not AdjustmentLedger.IsEmpty() then
            exit(false);

        // Frequência: mês de vigência do índice
        case Contract."Index Frequency" of
            Contract."Index Frequency"::Monthly:
                exit(true);
            Contract."Index Frequency"::Quarterly:
                begin
                    StartDate := CalcDate('<-CQ>', AdjustmentMonth);
                    exit(Date2DMY(AdjustmentMonth, 2) = Date2DMY(StartDate, 2));
                end;
            Contract."Index Frequency"::Annually:
                begin
                    // Aniversário do contrato (mês do Start Date)
                    exit(Date2DMY(AdjustmentMonth, 2) = Date2DMY(Contract."Start Date", 2));
                end;
            else
                exit(false);
        end;
    end;

    [TryFunction]
    local procedure TryAdjust(var Contract: Record "KINTO Vehicle Contract"; AdjustmentMonth: Date): Boolean
    begin
        ApplyAdjustment(Contract, AdjustmentMonth, false);
        exit(true);
    end;

    procedure ApplyAdjustment(var Contract: Record "KINTO Vehicle Contract"; AdjustmentMonth: Date; PriorLetter: Boolean)
    var
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        IndexEntry: Record "KINTO Price Index Entry";
        AdjustmentLedger: Record "KINTO Adjustment Ledger";
        AppliedCount: Integer;
    begin
        if Contract."Price Index Code" = '' then
            Error(NoIndexErr, Contract."Contract No.");

        // Variação do índice vigente no mês anterior
        IndexEntry.SetRange("Index Code", Contract."Price Index Code");
        IndexEntry.SetFilter("Valid From", '<%1', CalcDate('<-CM>', AdjustmentMonth));
        if not IndexEntry.FindLast() then
            exit; // sem entrada de índice ainda: nada a fazer

        // Aplica via motor existente (revisões de condição com cap)
        BillingMgt.ApplyPriceAdjustment(Contract, AdjustmentMonth);

        AdjustmentLedger.Init();
        AdjustmentLedger."Contract No." := Contract."Contract No.";
        AdjustmentLedger."Adjustment Month" := AdjustmentMonth;
        AdjustmentLedger."Index Code" := Contract."Price Index Code";
        AdjustmentLedger."Index Variation %" := IndexEntry."Variation %";
        AdjustmentLedger."Cap Applied %" := Contract."Index Cap %";
        AdjustmentLedger."Prior Letter" := PriorLetter;
        AdjustmentLedger."Created By" := CopyStr(UserId, 1, 50);
        AdjustmentLedger.Insert(false);

        // Conta condições ajustadas (revisões criadas neste mês)
        AppliedCount := CountRevisionsCreated(Contract, AdjustmentMonth);
        AdjustmentLedger."Conditions Adjusted" := AppliedCount;
        AdjustmentLedger.Modify(false);
    end;

    local procedure CountRevisionsCreated(Contract: Record "KINTO Vehicle Contract"; AdjustmentMonth: Date): Integer
    var
        Condition: Record "KINTO Contract Condition";
    begin
        Condition.SetRange("Contract No.", Contract."Contract No.");
        Condition.SetFilter("Valid From", '%1', CalcDate('<CM+1D>', AdjustmentMonth));
        exit(Condition.Count());
    end;
}
