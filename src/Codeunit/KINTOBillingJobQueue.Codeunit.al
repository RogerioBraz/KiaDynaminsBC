codeunit 50202 "KINTO Billing Job Queue"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Contract: Record "KINTO Vehicle Contract";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        BillingMonth: Date;
        Generated: Integer;
        Skipped: Integer;
        SummaryMsg: Label 'KINTO monthly billing: %1 contract(s) billed, %2 skipped (already billed/not due), %3 error(s).';
        ErrCount: Integer;
    begin
        // Job Queue mensal (D6 PP-03): mede e gera Billing Lines para todos os
        // contratos elegíveis no mês corrente. Idempotente por contrato/mês
        // (GenerateBillingForContract já bloqueia duplicidade).
        BillingMonth := CalcDate('<-CM>', WorkDate());

        Contract.Reset();
        Contract.SetFilter(Status, '%1|%2', Contract.Status::Active, Contract.Status::Extended);
        Contract.SetFilter("Start Date", '<=%1', CalcDate('<CM>', BillingMonth));
        if Contract.FindSet() then
            repeat
                if ContractIsDue(Contract, BillingMonth) then begin
                    if not ContractHasBilling(Contract."Contract No.", BillingMonth) then begin
                        if EvaluateContract(Contract, BillingMonth, BillingMgt) then
                            Generated += 1
                        else
                            ErrCount += 1;
                    end else
                        Skipped += 1;
                end else
                    Skipped += 1;
            until Contract.Next() = 0;

        if Rec.Status = Rec.Status::Error then
            exit;

    end;

    local procedure EvaluateContract(var Contract: Record "KINTO Vehicle Contract"; BillingMonth: Date; var BillingMgt: Codeunit "KINTO Contract Billing Mgt."): Boolean
    begin
        BillingMgt.GenerateBillingForContract(Contract, BillingMonth);
        exit(true);
    end;

    local procedure ContractIsDue(var Contract: Record "KINTO Vehicle Contract"; BillingMonth: Date): Boolean
    var
        MonthStart: Date;
        MonthEnd: Date;
    begin
        MonthStart := CalcDate('<-CM>', BillingMonth);
        MonthEnd := CalcDate('<CM>', BillingMonth);
        // Contrato deve estar vigente em algum dia do mês
        if Contract."Start Date" > MonthEnd then
            exit(false);
        if (Contract."Current End Date" <> 0D) and (Contract."Current End Date" < MonthStart) then
            exit(false);
        // Terminado antes do início do mês não fatura
        if (Contract."Termination Date" <> 0D) and (Contract."Termination Date" < MonthStart) then
            exit(false);
        exit(true);
    end;

    local procedure ContractHasBilling(ContractNo: Code[20]; BillingMonth: Date): Boolean
    var
        BillingLine: Record "KINTO Billing Line";
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        exit(not BillingLine.IsEmpty());
    end;


}