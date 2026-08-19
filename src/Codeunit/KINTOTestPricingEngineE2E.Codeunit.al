codeunit 50155 "KINTO Test Pricing Engine E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestFullPricingRunBR()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        CFData: Record "KINTO Cash Flow Data";
        Snapshot: Record "KINTO Simulation Snapshot";
        PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
    begin
        // [Scenario] Full pricing run for BR with Corolla Cross XRE
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        // [When] Run pricing engine
        PricingEngine.RunPricing(QuoteHeader);

        // [Then] Verify status is Calculated
        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.AreEqual(
            QuoteHeader."Pricing Status"::Calculated,
            QuoteHeader."Pricing Status",
            'Pricing status should be Calculated');

        // Verify quote item has results
        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        Assert.IsTrue(QuoteItem."Monthly Tariff" > 0, 'Monthly tariff should be calculated');
        Assert.IsTrue(QuoteItem."Purchase Price" > 0, 'Purchase price should be calculated');
        Assert.IsTrue(QuoteItem."Final Resale Price" > 0, 'Final resale price should be calculated');
        Assert.IsTrue(QuoteItem."KINTO IRR" > 0, 'KINTO IRR should be calculated');
        Assert.IsTrue(QuoteItem."Calculated ROI" > 0, 'ROI should be calculated');

        // Verify cash flow data exists
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        Assert.IsTrue(CFData.Count > 0, 'Cash flow data should exist');

        // Verify snapshot exists
        Assert.IsTrue(QuoteHeader."Snapshot ID" <> 0, 'Snapshot ID should be set');
        Snapshot.Get(QuoteHeader."Snapshot ID");
        Assert.AreEqual(QuoteHeader."Quote No.", Snapshot."Quote No.", 'Snapshot should reference quote');

        // Verify approval classification
        Assert.IsTrue(
            QuoteHeader."Approval Classification" in [
                QuoteHeader."Approval Classification"::Standard,
                QuoteHeader."Approval Classification"::"Non-Standard"],
            'Approval classification should be set');
    end;

    [Test]
    procedure TestFullPricingRunAR()
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
        // [Scenario] Full pricing run for AR with KINTO Fee methodology
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupAR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);

        QuoteHeader.Init();
        QuoteHeader."Quote No." := 'TEST-AR-001';
        QuoteHeader."Country Code" := 'AR';
        QuoteHeader."Payment Allowance Days" := 30;
        QuoteHeader."Credit Score" := 'B';
        QuoteHeader.Insert(true);

        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");
        QuoteItem."Contract Term (Months)" := 12;
        QuoteItem."Monthly Mileage (km)" := 800;
        QuoteItem."Payment Allowance (days)" := 30;
        QuoteItem."Lead Time (days)" := 3;
        QuoteItem.Modify(true);

        // [When] Run pricing engine
        PricingEngine.RunPricing(QuoteHeader);

        // [Then] Verify status and methodology
        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.AreEqual(
            QuoteHeader."Pricing Status"::Calculated,
            QuoteHeader."Pricing Status",
            'Pricing status should be Calculated');

        Assert.AreEqual(
            QuoteHeader."Pricing Methodology"::"KINTO Fee",
            QuoteHeader."Pricing Methodology",
            'AR should use KINTO Fee methodology');

        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        Assert.IsTrue(QuoteItem."Monthly Tariff" > 0, 'Monthly tariff should be calculated with KINTO Fee');
    end;

    [Test]
    procedure TestEmergencyStopBlocksPricing()
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
        // [Scenario] Emergency stop blocks pricing execution
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        // Enable emergency stop
        CountrySetup.Get('BR');
        CountrySetup."Emergency Stop" := true;
        CountrySetup.Modify(true);

        // [When] Run pricing — should error
        asserterror PricingEngine.RunPricing(QuoteHeader);

        // [Then] Error expected
        Assert.ExpectedError('Pricing Engine is stopped');
    end;
}