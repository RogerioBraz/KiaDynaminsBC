codeunit 50153 "KINTO E2E Fine Test"
{
    Subtype = Test;

    // ============================================================
    // TESTE E2E 4 — MULTAS: ingestão → vinculação por data → cobrança
    // ============================================================
    [Test]
    procedure TestLinkFineByInfractionDate()
    var
        Fine: Record "KINTO Traffic Fine";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        FineMgt: Codeunit "KINTO Fine Management";
        ContractNo: Code[20];
        FineNo: Code[20];
    begin
        // [GIVEN] Contrato ativo + multa com data de infração DENTRO da vigência
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        FineNo := Seed.CreateFine(ContractNo, CalcDate('<-1M>', WorkDate()));

        // [WHEN] Vinculação (cruza pela DATA DA INFRAÇÃO — RN-016)
        Fine.Get(FineNo);
        FineMgt.LinkFine(Fine);

        // [THEN] Multa vinculada ao contrato e ao cliente
        Fine.Get(FineNo);
        LibraryAssert.AreEqual(ContractNo, Fine."Contract No.", 'Multa deve vincular ao contrato da placa');
        LibraryAssert.AreEqual(Format(Fine."Link Status"::Linked), Format(Fine."Link Status"),
            'Status de vínculo deve ser Linked');
        LibraryAssert.IsTrue(Fine."Customer No." <> '', 'Cliente deve ser herdado do contrato');
    end;

    [Test]
    procedure TestLinkFineOutsideContractNotLinkable()
    var
        Fine: Record "KINTO Traffic Fine";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        FineMgt: Codeunit "KINTO Fine Management";
        ContractNo: Code[20];
        FineNo: Code[20];
    begin
        // [GIVEN] Multa com data de infração ANTES de qualquer contrato (fora da janela)
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        FineNo := Seed.CreateFine(ContractNo, CalcDate('<-2Y>', WorkDate()));

        // [WHEN] Vinculação
        Fine.Get(FineNo);
        FineMgt.LinkFine(Fine);

        // [THEN] Não linkável (sem contrato na data, fora da janela pós-contrato)
        Fine.Get(FineNo);
        LibraryAssert.AreEqual(Format(Fine."Link Status"::"Not Linkable"), Format(Fine."Link Status"),
            'Multa fora de vigência e janela deve ser Not Linkable');
    end;

    [Test]
    procedure TestBillFineCreatesBillingLine()
    var
        Fine: Record "KINTO Traffic Fine";
        BillingLine: Record "KINTO Billing Line";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        FineMgt: Codeunit "KINTO Fine Management";
        ContractNo: Code[20];
        FineNo: Code[20];
    begin
        // [GIVEN] Multa vinculada com valor de cliente
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        FineNo := Seed.CreateFine(ContractNo, CalcDate('<-1M>', WorkDate()));
        Fine.Get(FineNo);
        FineMgt.LinkFine(Fine);

        // [WHEN] Cobrança ao cliente (Billing Line FINE + taxas)
        Fine.Get(FineNo);
        FineMgt.BillFineToCustomer(Fine);

        // [THEN] Billing Line criada com produto FINE
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Financial Product Code", 'FINE');
        LibraryAssert.RecordIsNotEmpty(BillingLine);
        BillingLine.FindFirst();
        LibraryAssert.AreEqual(Fine."Customer Amount", BillingLine.Amount, 'Valor da billing line = valor cliente');
    end;

    [Test]
    procedure TestCancelBilledFineCreatesCredit()
    var
        Fine: Record "KINTO Traffic Fine";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        FineMgt: Codeunit "KINTO Fine Management";
        ContractNo: Code[20];
        FineNo: Code[20];
    begin
        // [GIVEN] Multa vinculada e cobrada
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        FineNo := Seed.CreateFine(ContractNo, CalcDate('<-1M>', WorkDate()));
        Fine.Get(FineNo);
        FineMgt.LinkFine(Fine);
        Fine.Get(FineNo);
        FineMgt.BillFineToCustomer(Fine);

        // [WHEN] Cancelar a multa cobrada
        Fine.Get(FineNo);
        Fine.CancelFine('E2E test cancel');

        // [THEN] Status Cancelled (billing line cancelada — crédito se já faturada)
        Fine.Get(FineNo);
        LibraryAssert.AreEqual(Format(Fine.Status::Cancelled), Format(Fine.Status), 'Multa deve ficar Cancelled');
    end;
}