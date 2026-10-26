codeunit 50155 "KINTO E2E Termination Test"
{
    Subtype = Test;

    // ============================================================
    // TESTE E2E 6 — TERMINAÇÃO: terminate → return → danos → cobrança
    // ============================================================
    [Test]
    procedure TestTerminateAndCreateReturn()
    var
        Contract: Record "KINTO Vehicle Contract";
        VehicleReturn: Record "KINTO Vehicle Return";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        TermMgt: Codeunit "KINTO Termination Management";
        ContractNo: Code[20];
        ReturnNo: Code[20];
    begin
        // [GIVEN] Contrato ativo
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);

        // [WHEN] Terminar + criar devolução
        Contract.Get(ContractNo);
        Contract.Terminate("KINTO Termination Type"::"End of Term", WorkDate());
        ReturnNo := TermMgt.CreateReturnFromContract(ContractNo, WorkDate(), 'São Paulo — pátio central');

        // [THEN] Return criado vinculado, com moeda herdada do contrato
        VehicleReturn.Get(ReturnNo);
        LibraryAssert.AreEqual(ContractNo, VehicleReturn."Contract No.", 'Return deve vincular ao contrato');
        LibraryAssert.AreEqual(Contract."Currency Code", VehicleReturn."Currency Code",
            'Return deve herdar a moeda do contrato');
        LibraryAssert.AreEqual(Format(VehicleReturn.Status::Scheduled), Format(VehicleReturn.Status),
            'Return deve nascer Scheduled');
    end;

    [Test]
    procedure TestReturnRequiresTerminatedContract()
    var
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        TermMgt: Codeunit "KINTO Termination Management";
        ContractNo: Code[20];
    begin
        // [GIVEN] Contrato ATIVO (não terminado)
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);

        // [WHEN/THEN] Create Return deve falhar (RN: exige contrato terminado)
        asserterror TermMgt.CreateReturnFromContract(ContractNo, WorkDate(), 'SP');
        LibraryAssert.ExpectedError('terminated');
    end;

    [Test]
    procedure TestDamageApprovalAndCustomerBilling()
    var
        VehicleReturn: Record "KINTO Vehicle Return";
        DamageLine: Record "KINTO Damage Line";
        BillingLine: Record "KINTO Billing Line";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        TermMgt: Codeunit "KINTO Termination Management";
        ContractNo: Code[20];
        ReturnNo: Code[20];
    begin
        // [GIVEN] Contrato terminado + return com dano do cliente (má uso, R$ 1.500)
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Seed.TerminateContract(ContractNo);
        ReturnNo := TermMgt.CreateReturnFromContract(ContractNo, WorkDate(), 'SP');
        Seed.AddDamageLine(ReturnNo, 'Riscos no para-choque', "KINTO Damage Class"::"Misuse",
            "KINTO Damage Payer"::Customer, 1500);

        // [WHEN] Checklist completo + cobrança dos danos
        VehicleReturn.Get(ReturnNo);
        VehicleReturn."Odometer at Return" := 52000;
        VehicleReturn."Return Date" := WorkDate();
        VehicleReturn.CompleteChecklist();
        VehicleReturn.FinishReturn();
        VehicleReturn.Get(ReturnNo);
        VehicleReturn.BillDamagesToCustomer();

        // [THEN] Billing Line DAMAGE com o valor do dano aprovado
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Financial Product Code", 'DAMAGE');
        LibraryAssert.RecordIsNotEmpty(BillingLine);
        BillingLine.FindFirst();
        LibraryAssert.AreEqual(1500, BillingLine.Amount, 'Billing line deve ter o valor do dano');
    end;

    [Test]
    procedure TestTotalLossCreatesRecoveryCase()
    var
        RecoveryCase: Record "KINTO Recovery Case";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        TermMgt: Codeunit "KINTO Termination Management";
        ContractNo: Code[20];
    begin
        // [GIVEN] Contrato terminado por Total Loss (D5: salvage + recovery automático)
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Seed.TerminateContract(ContractNo, "KINTO Termination Type"::"Total Loss");

        // [WHEN] HandleTotalLoss
        Contract.Get(ContractNo);
        TermMgt.HandleTotalLoss(Contract);

        // [THEN] Recovery case aberto automaticamente (risco alto)
        RecoveryCase.SetRange("Contract No.", ContractNo);
        LibraryAssert.RecordIsNotEmpty(RecoveryCase);
        RecoveryCase.FindFirst();
        LibraryAssert.AreEqual(Format(RecoveryCase."Risk Level"::High), Format(RecoveryCase."Risk Level"),
            'Total loss deve abrir recovery case de alto risco');
    end;
}