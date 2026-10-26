codeunit 50215 "KINTO Service Credit Mgt."
{
    // D6: créditos de dias sem serviço — limitados a 2% do faturamento
    // do contrato no período. Origem: downtime com SLA (D3d), greve/
    // calamidade, etc. Credit line no billing do mês.

    var
        CapExceededMsg: Label 'Credit %1 exceeds the 2%% cap (%2). Credit limited to %3.';
        NoBillingErr: Label 'Contract %1 has no billing lines in month %2.';

    procedure RequestServiceCredit(ContractNo: Code[20]; BillingMonth: Date; DaysWithoutService: Decimal; Reason: Text[250]): Decimal
    var
        Contract: Record "KINTO Vehicle Contract";
        BillingLine: Record "KINTO Billing Line";
        CreditAmount: Decimal;
        CapAmount: Decimal;
        MonthRevenue: Decimal;
    begin
        Contract.Get(ContractNo);
        if DaysWithoutService <= 0 then
            exit(0);

        // Base de cálculo: faturamento do mês (linhas não canceladas)
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        if BillingLine.IsEmpty() then
            Error(NoBillingErr, ContractNo, BillingMonth);
        BillingLine.CalcSums(Amount);
        MonthRevenue := BillingLine.Amount;

        // Crédito = dias sem serviço × (mensalidade/30) — preço diário RN
        CreditAmount := Round(DaysWithoutService * (Contract."Monthly Rent" / 30), 0.01);

        // Cap 2% do faturamento do mês
        CapAmount := Round(MonthRevenue * 0.02, 0.01);
        if CreditAmount > CapAmount then begin
            CreditAmount := CapAmount;
            // registra que o cap aplicou (na linha de crédito criada abaixo)
        end;

        CreateCreditLine(Contract, BillingMonth, DaysWithoutService, CreditAmount,
            (CreditAmount = CapAmount) and (DaysWithoutService > 0), Reason);
        exit(CreditAmount);
    end;

    local procedure CreateCreditLine(Contract: Record "KINTO Vehicle Contract"; BillingMonth: Date; Days: Decimal; Amount: Decimal; CapApplied: Boolean; Reason: Text[250])
    var
        BillingLine: Record "KINTO Billing Line";
        FinancialProduct: Record "KINTO Financial Product";
    begin
        BillingLine.Init();
        BillingLine."Contract No." := Contract."Contract No.";
        BillingLine."Billing Month" := BillingMonth;
        BillingLine."Customer No." := Contract."Customer No.";
        BillingLine."Vehicle No." := Contract."Vehicle No.";
        BillingLine."Condition ID" := 'SVC-CREDIT';
        BillingLine."Financial Product Code" := 'SVC-CREDIT';
        BillingLine."Product Type" := FinancialProduct."Product Type"::Service;
        BillingLine.Description := CopyStr(StrSubstNo('Crédito %1 dias sem serviço: %2', Days, Reason), 1, 100);
        BillingLine.Quantity := Days;
        BillingLine."Unit Price" := -Round(Amount / Days, 0.01);
        BillingLine.Amount := -Amount;
        BillingLine.Status := BillingLine.Status::Pending;
        BillingLine."Service Credit Days" := Days;
        BillingLine."Service Credit Cap Applied" := CapApplied;
        BillingLine."Cost Center Code" := Contract."Cost Center Code";
        BillingLine."Currency Code" := Contract."Currency Code";
        BillingLine."Billing Period From" := BillingMonth;
        BillingLine."Billing Period To" := CalcDate('<CM>', BillingMonth);
        BillingLine."Created By" := CopyStr(UserId, 1, 50);
        BillingLine."Created DateTime" := CurrentDateTime;
        BillingLine.Insert(true);
    end;
}
