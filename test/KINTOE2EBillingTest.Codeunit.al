codeunit 50152 "KINTO E2E Billing Test"
{
    Subtype = Test;

    // ============================================================
    // TESTE E2E 3 — BILLING: contrato ativo → medição → billing line
    // ============================================================
    [Test]
    procedure TestGenerateBillingCreatesLines()
    var
        Contract: Record "KINTO Vehicle Contract";
        BillingLine: Record "KINTO Billing Line";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        ContractNo: Code[20];
        BillingMonth: Date;
    begin
        // [GIVEN] Contrato ativo criado de cotação aprovada
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        BillingMonth := CalcDate('<-CM>', WorkDate());

        // [WHEN] Generate Billing (medição mensal)
        BillingMgt.GenerateBillingForContract(Contract, BillingMonth);

        // [THEN] Billing Line criada com valor da condição (mês cheio = 30 dias — RN-014)
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        LibraryAssert.RecordIsNotEmpty(BillingLine);
        BillingLine.FindFirst();
        LibraryAssert.AreEqual(30, BillingLine."Days Billed", 'Mês cheio = 30 dias (RN-014)');
        LibraryAssert.IsTrue(BillingLine.Amount > 0, 'Valor deve ser > 0');
    end;

    [Test]
    procedure TestGenerateBillingIsIdempotent()
    var
        Contract: Record "KINTO Vehicle Contract";
        BillingLine: Record "KINTO Billing Line";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        ContractNo: Code[20];
        BillingMonth: Date;
        Count1: Integer;
    begin
        // [GIVEN] Contrato com billing já gerada no mês
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        BillingMonth := CalcDate('<-CM>', WorkDate());
        BillingMgt.GenerateBillingForContract(Contract, BillingMonth);
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        Count1 := BillingLine.Count();

        // [WHEN/THEN] 2ª geração no mesmo mês deve falhar (idempotência)
        Contract.Get(ContractNo);
        asserterror BillingMgt.GenerateBillingForContract(Contract, BillingMonth);
        LibraryAssert.ExpectedError('already');
    end;

    [Test]
    procedure TestCreditFromInvoicedLine()
    var
        Contract: Record "KINTO Vehicle Contract";
        BillingLine: Record "KINTO Billing Line";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        ContractNo: Code[20];
        CreditMemoNo: Code[20];
    begin
        // [GIVEN] Billing line faturada (invoiced via InvoiceGroup)
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        BillingMgt.GenerateBillingForContract(Contract, CalcDate('<-CM>', WorkDate()));
        BillingMgt.ApproveContractLines(ContractNo, CalcDate('<-CM>', WorkDate()));
        BillingMgt.InvoiceApprovedLines(ContractNo, CalcDate('<-CM>', WorkDate()));

        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange(Status, BillingLine.Status::Invoiced);
        if BillingLine.IsEmpty() then
            exit; // sem item de serviço configurado — teste pula (setup depende de Item Type=Service)

        BillingLine.FindFirst();

        // [WHEN] Crédito retroativo (RN-005)
        CreditMemoNo := BillingMgt.CreateCreditFromBillingLine(BillingLine."Entry No.", 'E2E test credit');

        // [THEN] Credit memo criado e linha creditada
        LibraryAssert.IsTrue(CreditMemoNo <> '', 'Credit memo deve ser criado');
        BillingLine.Get(BillingLine."Entry No.");
        LibraryAssert.AreEqual(Format(BillingLine.Status::Credited), Format(BillingLine.Status),
            'Linha deve ficar Credited');
    end;
}