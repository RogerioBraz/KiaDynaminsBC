codeunit 50150 "KINTO E2E Pricing Test"
{
    Subtype = Test;

    // ============================================================
    // TESTE E2E 1 — PRICING: cotação → RunPricing → indicadores
    // ============================================================
    [Test]
    procedure TestQuoteRunPricingCalculatesIndicators()
    var
        Quote: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        QuoteNo: Code[20];
    begin
        // [GIVEN] Cotação com item válido dentro da faixa da RV Matrix
        QuoteNo := Seed.CreateQuoteWithItem('BR', 24, 1500, 3.4);

        // [WHEN] Run Pricing
        Quote.Get(QuoteNo);
        RunPricingOnQuote(Quote);

        // [THEN] Item calculado com tarifa > 0 e status Calculated
        QuoteItem.SetRange("Quote No.", QuoteNo);
        QuoteItem.FindFirst();
        LibraryAssert.IsTrue(QuoteItem."Monthly Tariff" > 0, 'Tarifa deve ser > 0');
        LibraryAssert.AreEqual(Format(QuoteItem."Pricing Status"::Calculated), Format(QuoteItem."Pricing Status"),
            'Item deve ficar Calculated');

        // [THEN] Header agregou os resultados
        Quote.Get(QuoteNo);
        LibraryAssert.AreEqual(Format(Quote."Pricing Status"::Calculated), Format(Quote."Pricing Status"),
            'Header deve ficar Calculated');
        LibraryAssert.AreEqual(QuoteItem."Monthly Tariff", Quote."Calculated Monthly Fee",
            'Header deve agregar a tarifa do item');
    end;

    [Test]
    procedure TestQuoteOutsideRVMatrixFails()
    var
        Quote: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        QuoteNo: Code[20];
    begin
        // [GIVEN] Cotação FORA da faixa da RV Matrix (36 meses × 3000 km = 108.000 km)
        QuoteNo := Seed.CreateQuoteWithItem('BR', 36, 3000, 3.4);

        // [WHEN] Run Pricing
        Quote.Get(QuoteNo);
        asserterror RunPricingOnQuote(Quote);

        // [THEN] Erro de residual value (RN-016: faixa obrigatória)
        LibraryAssert.ExpectedError('residual value');
    end;

    [Test]
    procedure TestApproveRequiresCalculated()
    var
        Quote: Record "KINTO Quote Header";
        LibraryAssert: Codeunit "Library Assert";
        Seed: Codeunit "KINTO Demo Data Seed";
        QuoteNo: Code[20];
    begin
        // [GIVEN] Cotação calculada
        QuoteNo := Seed.CreateQuoteWithItem('BR', 24, 1500, 3.4);
        Quote.Get(QuoteNo);
        RunPricingOnQuote(Quote);

        // [WHEN] Approve
        Quote."Pricing Status" := Quote."Pricing Status"::Approved;
        Quote.Modify(true);
        Quote.Get(QuoteNo);

        // [THEN] Status Approved (condição p/ criar contrato)
        LibraryAssert.AreEqual(Format(Quote."Pricing Status"::Approved), Format(Quote."Pricing Status"),
            'Quote deve ficar Approved');
    end;

    local procedure RunPricingOnQuote(var Quote: Record "KINTO Quote Header")
    var
        Engine: Codeunit "KINTO Pricing Engine Mgt.";
    begin
        Engine.RunPricing(Quote);
    end;
}