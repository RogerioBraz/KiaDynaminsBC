codeunit 50204 "KINTO Maintenance Management"
{
    Permissions = tabledata "KINTO Maintenance Ticket" = RIMD,
                  tabledata "KINTO Maint Ticket Line" = RIMD,
                  tabledata "KINTO Billing Line" = RIMD,
                  tabledata "KINTO Vehicle Contract" = RIMD;

    // ============================================================
    // FASE 3 — TICKET → BILLING (D1 PP-03/PP-06: adicional ao cliente)
    // ============================================================
    procedure BillTicketToCustomer(var Ticket: Record "KINTO Maintenance Ticket")
    var
        TicketLine: Record "KINTO Maint Ticket Line";
        BillingLine: Record "KINTO Billing Line";
        Contract: Record "KINTO Vehicle Contract";
        FinancialProduct: Record "KINTO Financial Product";
        TotalBillable: Decimal;
        AlreadyErr: Label 'Ticket %1 already has a billing line.';
        NothingErr: Label 'Ticket %1 has no billable lines.';
        NotClosedErr: Label 'Ticket %1 must be closed before billing.';
    begin
        if Ticket.Status in [Ticket.Status::Open, Ticket.Status::"In Analysis",
            Ticket.Status::"Pending Approval", Ticket.Status::Approved, Ticket.Status::"In Execution"]
        then
            Error(NotClosedErr, Ticket."Ticket No.");
        if Ticket."Billing Line Entry No." <> 0 then
            Error(AlreadyErr, Ticket."Ticket No.");

        // Garante a taxa HH vigente ANTES de apurar o total a faturar: se a
        // tabela de taxas foi corrigida entre a execucao e o faturamento, o
        // cliente e cobrado pelo valor certo, e nao pelo que estava na linha.
        ApplyLaborRates(Ticket);

        TicketLine.SetRange("Ticket No.", Ticket."Ticket No.");
        TicketLine.SetRange("Bill to Customer", true);
        if TicketLine.FindSet() then
            repeat
                if TicketLine."Customer Price" > 0 then
                    TotalBillable += TicketLine."Customer Price" * TicketLine.Quantity
                else
                    TotalBillable += TicketLine.Amount;
            until TicketLine.Next() = 0;

        if TotalBillable <= 0 then
            Error(NothingErr, Ticket."Ticket No.");

        Contract.Get(Ticket."Contract No.");

        // Produto ADD-SERVICE (seed no install) — fatura separada do aluguel
        if not FinancialProduct.Get('ADD-SERVICE') then begin
            FinancialProduct.Init();
            FinancialProduct."Product Code" := 'ADD-SERVICE';
            FinancialProduct.Description := 'Additional Service (Maintenance)';
            FinancialProduct."Product Type" := FinancialProduct."Product Type"::"Additional Service";
            FinancialProduct."Separate Invoice" := true;
            FinancialProduct.Insert(true);
        end;

        BillingLine.Init();
        BillingLine."Contract No." := Ticket."Contract No.";
        BillingLine."Billing Month" := CalcDate('<-CM>', Ticket."Service Date");
        BillingLine."Condition ID" := '';
        BillingLine."Financial Product Code" := 'ADD-SERVICE';
        BillingLine."Product Type" := BillingLine."Product Type"::"Additional Service";
        BillingLine.Description := CopyStr(StrSubstNo('Maintenance ticket %1 — %2', Ticket."Ticket No.", Ticket.Description), 1, MaxStrLen(BillingLine.Description));
        BillingLine.Quantity := 1;
        BillingLine."Days Billed" := 30;
        BillingLine."Unit Price" := TotalBillable;
        BillingLine.Amount := TotalBillable;
        BillingLine."Billing Period From" := CalcDate('<-CM>', Ticket."Service Date");
        BillingLine."Billing Period To" := CalcDate('<CM>', Ticket."Service Date");
        BillingLine."Currency Code" := Contract."Currency Code";
        BillingLine."Cost Center Code" := Contract."Cost Center Code";
        BillingLine."Origin Description" := CopyStr(StrSubstNo('Ticket %1', Ticket."Ticket No."), 1, MaxStrLen(BillingLine."Origin Description"));
        BillingLine.Status := BillingLine.Status::Open;
        BillingLine.Insert(true);

        Ticket."Billing Line Entry No." := BillingLine."Entry No.";
        Ticket."Billing Month" := BillingLine."Billing Month";
        Ticket.Status := Ticket.Status::Closed;
        Ticket.Modify(true);
    end;

    // ============================================================
    // FASE 3 — CRIAÇÃO DE TICKET A PARTIR DO CONTRATO
    // ============================================================
    procedure CreateTicketFromContract(ContractNo: Code[20]; TicketType: Enum "KINTO Maint Ticket Type"; Description: Text[250]; ServiceDate: Date; Odometer: Decimal): Code[20]
    var
        Ticket: Record "KINTO Maintenance Ticket";
        Contract: Record "KINTO Vehicle Contract";
        NotActiveErr: Label 'Contract %1 is not active.';
    begin
        Contract.Get(ContractNo);
        if not (Contract.Status in [Contract.Status::Active, Contract.Status::Extended]) then
            Error(NotActiveErr, ContractNo);

        Ticket.Init();
        Ticket."Ticket No." := '';
        Ticket."Ticket Type" := TicketType;
        Ticket."Contract No." := ContractNo;
        Ticket."Vehicle No." := Contract."Vehicle No.";
        Ticket."Customer No." := Contract."Customer No.";
        Ticket.Description := Description;
        Ticket."Service Date" := ServiceDate;
        Ticket."Odometer at Service" := Odometer;
        Ticket.Insert(true);
        exit(Ticket."Ticket No.");
    end;

    // ============================================================
    // FASE 3 — VALIDAÇÃO DE VALOR vs PREÇO PADRÃO (D1 PP-05, RN-021)
    // ============================================================
    // D1 — aplica a taxa hora-homem do fornecedor em TODAS as linhas de mao de
    // obra do ticket. Usa a Data de Servico do ticket (nao a data de hoje), para
    // que reprocessar um ticket antigo traga a taxa que valia na epoca.
    //
    // Devolve a quantidade de linhas efetivamente atualizadas.
    procedure ApplyLaborRates(var Ticket: Record "KINTO Maintenance Ticket"): Integer
    var
        TicketLine: Record "KINTO Maint Ticket Line";
        Applied: Integer;
        ServiceDate: Date;
    begin
        if Ticket."Vendor No." = '' then
            exit(0);

        ServiceDate := Ticket."Service Date";
        if ServiceDate = 0D then
            ServiceDate := Today();

        TicketLine.SetRange("Ticket No.", Ticket."Ticket No.");
        if TicketLine.FindSet(true) then
            repeat
                if TicketLine.ApplyLaborRate(Ticket."Vendor No.", ServiceDate) then begin
                    TicketLine.Modify(true);
                    Applied += 1;
                end;
            until TicketLine.Next() = 0;
        exit(Applied);
    end;

    procedure ValidateTicketPrices(var Ticket: Record "KINTO Maintenance Ticket"): Decimal
    var
        TicketLine: Record "KINTO Maint Ticket Line";
        MaxDeviation: Decimal;
    begin
        // Compara cada linha contra o preço padrão do plano de manutenção (se houver).
        // Deviation > 0 = cobrado acima do padrão → exige quote review (RN-034).
        TicketLine.SetRange("Ticket No.", Ticket."Ticket No.");
        if TicketLine.FindSet() then
            repeat
                if TicketLine."Price Deviation %" > MaxDeviation then
                    MaxDeviation := TicketLine."Price Deviation %";
            until TicketLine.Next() = 0;
        exit(MaxDeviation);
    end;
}