codeunit 60002 "KINTO Downtime Mgt."
{
    // ============================================================
    // D3 — DOWNTIME -> SERVICE CREDIT + SLA
    // Converte dias de indisponibilidade em credito ao cliente
    // (via KINTO Service Credit Mgt.) e apura violacoes de SLA.
    // ============================================================

    procedure CreateServiceCredits(AsOfDate: Date): Integer
    var
        Downtime: Record "KINTO Vehicle Downtime";
        Contract: Record "KINTO Vehicle Contract";
        CreditMgt: Codeunit "KINTO Service Credit Mgt.";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        BillingMonth: Date;
        Created: Integer;
        Days: Decimal;
        CreditAmount: Decimal;
    begin
        BillingMonth := CalcDate('<-CM>', AsOfDate);
        Downtime.Reset();
        Downtime.SetRange("Service Credit Created", false);
        Downtime.SetFilter("Chargeable to KINTO", '%1', true);
        Downtime.SetFilter("End DateTime", '<>%1', 0DT);
        if Downtime.FindSet() then
            repeat
                Days := Downtime."Days Lost";
                if Contract.Get(Downtime."Contract No.") and (Contract.Status = Contract.Status::Active) and
                   (Days > 0) and HasBilling(Contract."Contract No.", BillingMonth) then begin
                    CreditAmount := CreditMgt.RequestServiceCredit(Contract."Contract No.", BillingMonth,
                        Days, StrSubstNo('Downtime %1 (%2 days)', Downtime.Reason, Days));
                    if CreditAmount > 0 then begin
                        Downtime."Service Credit Created" := true;
                        Downtime.Modify(false);
                        Created += 1;
                    end;
                end;
            until Downtime.Next() = 0;
        exit(Created);
    end;

    local procedure HasBilling(ContractNo: Code[20]; BillingMonth: Date): Boolean
    var
        BillingLine: Record "KINTO Billing Line";
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        exit(not BillingLine.IsEmpty());
    end;

    // ============================================================
    // SLA — apuracao de violacoes de tempo de resposta/resolucao
    // ============================================================
    procedure CheckSLAViolations(AsOfDate: Date): Integer
    var
        Ticket: Record "KINTO Maintenance Ticket";
        SLA: Record "KINTO Service Level";
        Violation: Record "KINTO SLA Violation";
        ViolationType: Enum "KINTO SLA Violation Type";
        HoursElapsed: Decimal;
        Count: Integer;
    begin
        Ticket.Reset();
        Ticket.SetFilter(Status, '%1|%2', Ticket.Status::Open, Ticket.Status::"In Execution");
        if Ticket.FindSet() then
            repeat
                if SLA.Get(Ticket."Contract No.") and SLA.Active then begin
                    // Horas desde a abertura do ticket
                    HoursElapsed := Round((CurrentDateTime - Ticket."Created DateTime") / 3600, 0.01);
                    if (SLA."Resolution Time (hours)" > 0) and (HoursElapsed > SLA."Resolution Time (hours)") then
                        if RegisterViolation(Ticket, SLA, HoursElapsed, ViolationType::"Resolution Breach") then
                            Count += 1;
                end;
            until Ticket.Next() = 0;
        exit(Count);
    end;

    local procedure RegisterViolation(var Ticket: Record "KINTO Maintenance Ticket"; var SLA: Record "KINTO Service Level";
        HoursElapsed: Decimal; ViolationType: Enum "KINTO SLA Violation Type"): Boolean
    var
        Violation: Record "KINTO SLA Violation";
        Penalty: Decimal;
        Cap: Decimal;
        CapPercent: Decimal;
        MonthRevenue: Decimal;
        NoCapBase: Boolean;
    begin
        Violation.SetRange("Ticket No.", Ticket."Ticket No.");
        Violation.SetRange("Violation Type", ViolationType);
        if not Violation.IsEmpty() then
            exit(false);

        Penalty := SLA."Penalty Per Hour" * (HoursElapsed - SLA."Resolution Time (hours)");

        // CAP SOBRE O FATURAMENTO DO MES (decisao Rogerio 27/10) — mesmo criterio
        // do service credit: base = linhas de billing do mes, sem as canceladas.
        // O cap vale sobre o ACUMULADO de penalidades do contrato no mes, nao por
        // violacao: senao N violacoes furariam o cap.
        CapPercent := SLA."Penalty Cap %";
        if CapPercent = 0 then
            CapPercent := GetDefaultPenaltyCap(Ticket."Contract No.");
        if CapPercent > 0 then begin
            MonthRevenue := GetCapBase(Ticket."Contract No.");
            if MonthRevenue <= 0 then
                // Sem NENHUMA base (nem faturamento, nem mensalidade): nao capa
                // e registra o motivo — penalidade integral, nunca zerada em
                // silencio (zerar esconderia a violacao).
                NoCapBase := true
            else begin
                Cap := Round(MonthRevenue * CapPercent / 100, 0.01);
                if (GetMonthPenalties(Ticket."Contract No.") + Penalty) > Cap then
                    Penalty := Cap - GetMonthPenalties(Ticket."Contract No.");
                if Penalty < 0 then
                    Penalty := 0;
            end;
        end;

        Violation.Init();
        Violation."Ticket No." := Ticket."Ticket No.";
        Violation."Contract No." := Ticket."Contract No.";
        Violation."Violation Type" := ViolationType;
        Violation."Detected DateTime" := CurrentDateTime;
        Violation."Hours Elapsed" := HoursElapsed;
        Violation."SLA Target Hours" := SLA."Resolution Time (hours)";
        Violation."Penalty Amount" := Round(Penalty, 0.01);
        // Auditoria do calculo: fica gravado como o valor foi apurado e limitado
        Violation.Notes := CopyStr(StrSubstNo(
            'Hours %1 - target %2 = %3h x %4/h = base %5 | base %6, cap %7%% = %8, already %9, applied %10, noBase %11',
            HoursElapsed, SLA."Resolution Time (hours)",
            HoursElapsed - SLA."Resolution Time (hours)", SLA."Penalty Per Hour",
            SLA."Penalty Per Hour" * (HoursElapsed - SLA."Resolution Time (hours)"),
            MonthRevenue, CapPercent, Cap,
            GetMonthPenalties(Ticket."Contract No."), Round(Penalty, 0.01), NoCapBase), 1, 250);
        Violation.Insert(true);
        exit(true);
    end;

    // Faturamento de referencia para o cap de penalidade — mesma base do service
    // credit (linhas de billing nao canceladas do Billing Month).
    // Ordem: mes corrente; se ainda nao foi faturado, o ULTIMO mes faturado do
    // contrato. A penalidade e detectada durante o mes, muitas vezes ANTES de o
    // billing rodar — olhar so o mes corrente zeraria a penalidade por um motivo
    // que nao tem relacao com o SLA.
    local procedure GetRevenueOfMonth(ContractNo: Code[20]; BillingMonth: Date): Decimal
    var
        BillingLine: Record "KINTO Billing Line";
        LastBilledMonth: Date;
        Amount: Decimal;
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        if not BillingLine.IsEmpty() then begin
            BillingLine.CalcSums(Amount);
            exit(BillingLine.Amount);
        end;

        // Mes corrente ainda nao faturado: usa o ultimo mes faturado do contrato
        BillingLine.Reset();
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        BillingLine.SetFilter("Billing Month", '<%1', BillingMonth);
        BillingLine.SetCurrentKey("Billing Month");
        if BillingLine.FindLast() then begin
            LastBilledMonth := BillingLine."Billing Month";
            BillingLine.Reset();
            BillingLine.SetRange("Contract No.", ContractNo);
            BillingLine.SetRange("Billing Month", LastBilledMonth);
            BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
            if BillingLine.IsEmpty() then
                exit(0);
            BillingLine.CalcSums(Amount);
            // CalcSums agrega NO CAMPO, nao na variavel local
            exit(BillingLine.Amount);
        end;
        exit(0);
    end;

    // Penalidades ja aplicadas ao contrato no mes corrente (acumulado do cap)
    local procedure GetMonthPenalties(ContractNo: Code[20]): Decimal
    var
        Violation: Record "KINTO SLA Violation";
        Amount: Decimal;
    begin
        Violation.SetRange("Contract No.", ContractNo);
        Violation.SetFilter("Detected DateTime", '>=%1', CreateDateTime(CalcDate('<CM>', WorkDate()), 0T));
        Violation.CalcSums("Penalty Amount");
        exit(Violation."Penalty Amount");
    end;

    // Cap de penalidade default do pais (usado quando o SLA do contrato nao define)
    local procedure GetDefaultPenaltyCap(ContractNo: Code[20]): Decimal
    var
        Contract: Record "KINTO Vehicle Contract";
        CountrySetup: Record "KINTO Country Setup";
    begin
        if not Contract.Get(ContractNo) then
            exit(0);
        if CountrySetup.GetForCompanyOr(Contract."Country Code") then
            exit(CountrySetup."SLA Penalty Cap %");
        exit(0);
    end;

    // Base do cap de penalidade. Ordem:
    //  1. faturamento do mes corrente
    //  2. faturamento do ultimo mes faturado do contrato
    //  3. mensalidade contratual (Monthly Rent) — o mes ainda nao foi faturado
    // A penalidade e detectada DURANTE o mes, antes do billing rodar; sem o
    // passo 3 ela ficaria sem base e seria zerada por um motivo alheio ao SLA.
    procedure GetCapBase(ContractNo: Code[20]): Decimal
    var
        Contract: Record "KINTO Vehicle Contract";
        Revenue: Decimal;
    begin
        Revenue := GetRevenueOfMonth(ContractNo, CalcDate('<CM>', WorkDate()));
        if Revenue > 0 then
            exit(Revenue);
        Revenue := GetLastBilledRevenue(ContractNo, CalcDate('<CM>', WorkDate()));
        if Revenue > 0 then
            exit(Revenue);
        if Contract.Get(ContractNo) then
            exit(Contract."Monthly Rent");
        exit(0);
    end;

    local procedure GetLastBilledRevenue(ContractNo: Code[20]; BeforeMonth: Date): Decimal
    var
        BillingLine: Record "KINTO Billing Line";
        LastMonth: Date;
        Amount: Decimal;
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetFilter("Billing Month", '<%1', BeforeMonth);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        BillingLine.SetCurrentKey("Billing Month");
        if BillingLine.FindLast() then begin
            LastMonth := BillingLine."Billing Month";
            BillingLine.Reset();
            BillingLine.SetRange("Contract No.", ContractNo);
            BillingLine.SetRange("Billing Month", LastMonth);
            BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
            if not BillingLine.IsEmpty() then begin
                BillingLine.CalcSums(Amount);
                exit(BillingLine.Amount);
            end;
        end;
        exit(0);
    end;
}
