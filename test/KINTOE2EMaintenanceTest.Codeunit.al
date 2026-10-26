codeunit 50154 "KINTO E2E Maintenance Test"
{
    Subtype = Test;

    // ============================================================
    // TESTE E2E 5 — MANUTENÇÃO: ticket → pool → cobrança adicional
    // ============================================================
    [Test]
    procedure TestTicketLifecycle()
    var
        Ticket: Record "KINTO Maintenance Ticket";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        MaintMgt: Codeunit "KINTO Maintenance Management";
        ContractNo: Code[20];
        TicketNo: Code[20];
    begin
        // [GIVEN] Contrato ativo
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);

        // [WHEN] Ciclo completo do ticket
        TicketNo := MaintMgt.CreateTicketFromContract(ContractNo,
            "KINTO Maint Ticket Type"::Corrective, 'E2E: brake service', WorkDate(), 45000);
        Ticket.Get(TicketNo);
        Ticket.StartAnalysis();
        Ticket.SubmitForApproval();
        Ticket.Approve();
        Ticket.StartExecution();
        Ticket.CloseTicket();

        // [THEN] Ticket fechado
        Ticket.Get(TicketNo);
        LibraryAssert.AreEqual(Format(Ticket.Status::"Pending Invoice"), Format(Ticket.Status),
            'Ticket fechado deve estar Pending Invoice');
    end;

    [Test]
    procedure TestOdometerSequenceValidation()
    var
        Ticket: Record "KINTO Maintenance Ticket";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        MaintMgt: Codeunit "KINTO Maintenance Management";
        ContractNo: Code[20];
        TicketNo: Code[20];
    begin
        // [GIVEN] Ticket com odômetro RETROGRADO vs ticket anterior (RN-013)
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        TicketNo := MaintMgt.CreateTicketFromContract(ContractNo,
            "KINTO Maint Ticket Type"::Preventive, 'E2E: odometer back', WorkDate(), 10000);
        Ticket.Get(TicketNo);

        // [WHEN] Validação nativa
        // [THEN] Sequência quebrada detectada
        LibraryAssert.IsFalse(Ticket.ValidateTicket(), 'Odômetro retrogrado deve falhar na validação (RN-013)');
    end;

    [Test]
    procedure TestPoolConsumeAndRestore()
    var
        Ticket: Record "KINTO Maintenance Ticket";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        MaintMgt: Codeunit "KINTO Maintenance Management";
        PoolMgt: Codeunit "KINTO Pool Management";
        ContractNo: Code[20];
        TicketNo: Code[20];
        BalanceBefore: Decimal;
        BalanceAfter: Decimal;
    begin
        // [GIVEN] Contrato com pool de dias de carro reserva (5 dias)
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        BalanceBefore := PoolMgt.GetBalance(ContractNo, 'RESERVE-DAYS');

        // [WHEN] Consumir 2 dias em um ticket e cancelá-lo (EXC-16: restauração)
        TicketNo := MaintMgt.CreateTicketFromContract(ContractNo,
            "KINTO Maint Ticket Type"::Corrective, 'E2E: pool test', WorkDate(), 50000);
        Ticket.Get(TicketNo);
        Ticket.ConsumePool('RESERVE-DAYS', 2);
        BalanceAfter := PoolMgt.GetBalance(ContractNo, 'RESERVE-DAYS');
        LibraryAssert.AreEqual(BalanceBefore - 2, BalanceAfter, 'Consumo deve reduzir o saldo em 2');

        Ticket.CancelTicket();
        BalanceAfter := PoolMgt.GetBalance(ContractNo, 'RESERVE-DAYS');

        // [THEN] Saldo restaurado (EXC-16)
        LibraryAssert.AreEqual(BalanceBefore, BalanceAfter, 'Cancelamento deve restaurar o pool (EXC-16)');
    end;
}