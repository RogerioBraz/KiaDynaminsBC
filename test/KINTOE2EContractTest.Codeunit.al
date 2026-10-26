codeunit 50151 "KINTO E2E Contract Test"
{
    Subtype = Test;

    // ============================================================
    // TESTE E2E 2 — CONTRATO: quote aprovada → contrato + condições
    // ============================================================
    [Test]
    procedure TestCreateContractFromApprovedQuote()
    var
        Quote: Record "KINTO Quote Header";
        Contract: Record "KINTO Vehicle Contract";
        ContractCondition: Record "KINTO Contract Condition";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        QuoteNo: Code[20];
        ContractNo: Code[20];
    begin
        // [GIVEN] Cotação calculada e aprovada
        QuoteNo := Seed.CreateQuoteWithItem('BR', 24, 1500, 3.4);
        Quote.Get(QuoteNo);
        Seed.RunPricing(Quote);
        Quote."Pricing Status" := Quote."Pricing Status"::Approved;
        Quote.Modify(true);

        // [WHEN] Create Contract
        ContractNo := BillingMgt.CreateContractFromQuote(Quote);

        // [THEN] Contrato criado com número da série
        LibraryAssert.IsTrue(ContractNo <> '', 'Contrato deve ser criado');
        Contract.Get(ContractNo);
        LibraryAssert.AreEqual(QuoteNo, Contract."Quote No.", 'Contrato deve vincular à cotação');

        // [THEN] Condição criada (Condition ID versionado)
        ContractCondition.SetRange("Contract No.", ContractNo);
        LibraryAssert.RecordIsNotEmpty(ContractCondition);
    end;

    [Test]
    procedure TestCreateContractRequiresApprovedQuote()
    var
        Quote: Record "KINTO Quote Header";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        QuoteNo: Code[20];
    begin
        // [GIVEN] Cotação apenas calculada (não aprovada)
        QuoteNo := Seed.CreateQuoteWithItem('BR', 24, 1500, 3.4);
        Quote.Get(QuoteNo);
        Seed.RunPricing(Quote);

        // [WHEN/THEN] Create Contract deve falhar (RN: exige Approved)
        Quote.Get(QuoteNo);
        asserterror BillingMgt.CreateContractFromQuote(Quote);
        LibraryAssert.ExpectedError('Approved');
    end;
}