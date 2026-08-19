codeunit 50158 "KINTO Test Pre-Approval"
{
    Caption = 'KINTO Test: Pre-Approval Classification';
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestStandardClassification()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
    begin
        // [Scenario] Quote with all standard parameters should be classified Standard
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        // Standard parameters
        QuoteHeader."Credit Score" := 'A';
        QuoteHeader."Negotiation Buffer %" := 2.0;
        QuoteHeader.Modify(true);

        QuoteItem."Payment Allowance (days)" := 30;
        QuoteItem."Contingency Amount" := 0;
        QuoteItem.Modify(true);

        // [When] Run pricing
        PricingEngine.RunPricing(QuoteHeader);

        // [Then] Should be Standard
        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.AreEqual(
            QuoteHeader."Approval Classification"::Standard,
            QuoteHeader."Approval Classification",
            'Should be Standard with all standard parameters');
    end;

    [Test]
    procedure TestNonStandardCreditScore()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
    begin
        // [Scenario] Quote with credit score D should be Non-Standard
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteHeader."Credit Score" := 'D';
        QuoteHeader.Modify(true);

        // [When] Run pricing
        PricingEngine.RunPricing(QuoteHeader);

        // [Then] Should be Non-Standard
        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.AreEqual(
            QuoteHeader."Approval Classification"::"Non-Standard",
            QuoteHeader."Approval Classification",
            'Credit score D should be Non-Standard');
    end;

    [Test]
    procedure TestNonStandardPaymentAllowance()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
    begin
        // [Scenario] Payment allowance > 30 days should be Non-Standard
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem."Payment Allowance (days)" := 45;
        QuoteItem.Modify(true);

        // [When] Run pricing
        PricingEngine.RunPricing(QuoteHeader);

        // [Then] Should be Non-Standard
        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.AreEqual(
            QuoteHeader."Approval Classification"::"Non-Standard",
            QuoteHeader."Approval Classification",
            'Payment allowance > 30 should be Non-Standard');
    end;
}