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
        // Acumulado aplicado NESTA varredura, por contrato. O cap precisa somar
        // as violacoes anteriores mesmo que a releitura da tabela nao as
        // encontre (relogio de gravacao x filtro, ou registros ainda nao
        // visiveis). Sem isto, cada violacao recebia o cap inteiro:
        // 158,59 x 3 = 475,77 em vez de 158,59 no total.
        AppliedInRun: Dictionary of [Code[20], Decimal];
    begin
        Ticket.Reset();
        Ticket.SetFilter(Status, '%1|%2', Ticket.Status::Open, Ticket.Status::"In Execution");
        if Ticket.FindSet() then
            repeat
                if SLA.Get(Ticket."Contract No.") and SLA.Active then begin
                    // Horas desde a abertura do ticket.
                    // DateTime em AL conta MILISSEGUNDOS: uma hora tem 3.600.000 ms.
                    // Dividir por 3.600 tratava o resultado como se fosse segundos e
                    // inflava o tempo decorrido em 1.000x — um ticket de 2 horas
                    // aparecia com 2.000 horas e violava qualquer SLA na hora.
                    HoursElapsed := Round((CurrentDateTime - Ticket."Created DateTime") / 3600000, 0.01);
                    if (SLA."Resolution Time (hours)" > 0) and (HoursElapsed > SLA."Resolution Time (hours)") then
                        if RegisterViolation(Ticket, SLA, HoursElapsed, ViolationType::"Resolution Breach", AppliedInRun) then
                            Count += 1;
                end;
            until Ticket.Next() = 0;
        exit(Count);
    end;

    local procedure RegisterViolation(var Ticket: Record "KINTO Maintenance Ticket"; var SLA: Record "KINTO Service Level";
        HoursElapsed: Decimal; ViolationType: Enum "KINTO SLA Violation Type";
        var AppliedInRun: Dictionary of [Code[20], Decimal]): Boolean
    var
        Violation: Record "KINTO SLA Violation";
        Penalty: Decimal;
        Cap: Decimal;
        CapPercent: Decimal;
        MonthRevenue: Decimal;
        MonthPenalties: Decimal;
        RunPenalties: Decimal;
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
                // Acumulado = o que a tabela tem OU o que esta varredura ja
                // aplicou, o que for MAIOR. A releitura pode vir 0 (relogio de
                // gravacao x filtro), e sem esta salvaguarda o cap seria
                // concedido integralmente a cada violacao.
                MonthPenalties := GetMonthPenalties(Ticket."Contract No.");
                if AppliedInRun.Get(Ticket."Contract No.", RunPenalties) then begin
                    if RunPenalties > MonthPenalties then
                        MonthPenalties := RunPenalties;
                end;
                if (MonthPenalties + Penalty) > Cap then
                    Penalty := Cap - MonthPenalties;
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
            MonthPenalties, Round(Penalty, 0.01), NoCapBase), 1, 250);
        Violation.Insert(true);
        // registra no acumulado da varredura (mesmo que a linha ainda nao esteja
        // visivel para o filtro da releitura)
        if AppliedInRun.Get(Ticket."Contract No.", RunPenalties) then
            AppliedInRun.Set(Ticket."Contract No.", RunPenalties + Round(Penalty, 0.01))
        else
            AppliedInRun.Add(Ticket."Contract No.", Round(Penalty, 0.01));
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
        Amount: Decimal;
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        // MES INTEIRO, nao um dia exato: o projeto grava "Billing Month" ora no
        // 1o dia ('<-CM>', convencao do Billing Job Queue), ora no ultimo
        // ('<CM>', convencao do harness de teste). Comparar igualdade so
        // funciona em uma delas e a base do cap vinha 0 na outra.
        BillingLine.SetFilter("Billing Month", '>=%1&<=%2',
            CalcDate('<-CM>', BillingMonth), CalcDate('<CM>', BillingMonth));
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        if not BillingLine.IsEmpty() then begin
            BillingLine.CalcSums(Amount);
            exit(BillingLine.Amount);
        end;

        // Mes corrente ainda nao faturado: ultimo mes faturado do contrato.
        // Delegado: a logica de faixa vive em um lugar so.
        exit(GetLastBilledRevenue(ContractNo, BillingMonth));
    end;

    // Penalidades ja aplicadas ao contrato no mes corrente (acumulado do cap)
    local procedure GetMonthPenalties(ContractNo: Code[20]): Decimal
    var
        Violation: Record "KINTO SLA Violation";
    begin
        Violation.SetRange("Contract No.", ContractNo);
        // Penalidades ja aplicadas ao contrato no MES CORRENTE.
        // Atencao as duas bordas:
        //   '<-CM>' = PRIMEIRO dia do mes   (limite inferior)
        //   '<CM>'  = ULTIMO dia do mes     (limite superior)
        // Usar '<CM>' como limite INFERIOR (erro de uma versao anterior) filtra
        // a partir de 31/10 e deixa as violacoes de hoje de fora: acumulado 0 e
        // cada violacao recebe o cap inteiro (158,59 x 3 = 475,77).
        Violation.SetFilter("Detected DateTime", '>=%1&<=%2',
            CreateDateTime(CalcDate('<-CM>', WorkDate()), 0T),
            CreateDateTime(CalcDate('<CM>', WorkDate()), 235959T));
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
        BillingLine.SetFilter("Billing Month", '<%1', CalcDate('<-CM>', BeforeMonth));
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        BillingLine.SetCurrentKey("Billing Month");
        if BillingLine.FindLast() then begin
            LastMonth := BillingLine."Billing Month";
            BillingLine.Reset();
            BillingLine.SetRange("Contract No.", ContractNo);
            // mesma logica de faixa, aplicada ao mes encontrado
            BillingLine.SetFilter("Billing Month", '>=%1&<=%2',
                CalcDate('<-CM>', LastMonth), CalcDate('<CM>', LastMonth));
            BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
            if not BillingLine.IsEmpty() then begin
                BillingLine.CalcSums(Amount);
                exit(BillingLine.Amount);
            end;
        end;
        exit(0);
    end;
}
