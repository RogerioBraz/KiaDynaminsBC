
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
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        // Quote No. deve ser auto-gerado pelo Number Series
        Assert.IsTrue(QuoteHeader."Quote No." <> '', 'Quote No. should be auto-generated');

        PricingEngine.RunPricing(QuoteHeader);

        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.AreEqual(
            QuoteHeader."Pricing Status"::Calculated,
            QuoteHeader."Pricing Status",
            'Pricing status should be Calculated');

        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        Assert.IsTrue(QuoteItem."Monthly Tariff" > 0, 'Monthly tariff should be calculated');
        Assert.IsTrue(QuoteItem."Purchase Price" > 0, 'Purchase price should be calculated');
        Assert.IsTrue(QuoteItem."Final Resale Price" > 0, 'Final resale price should be calculated');
        Assert.IsTrue(QuoteItem."KINTO IRR" > 0, 'KINTO IRR should be calculated');
        Assert.IsTrue(QuoteItem."Calculated ROI" > 0, 'ROI should be calculated');

        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        Assert.IsTrue(CFData.Count > 0, 'Cash flow data should exist');

<<<<<<< HEAD
        // Snapshot ID deve ser auto-gerado via Number Series
        Assert.IsTrue(QuoteHeader."Snapshot ID" <> '', 'Snapshot ID should be auto-generated');
        Assert.IsTrue(Snapshot.Get(QuoteHeader."Snapshot ID"), 'Snapshot should be retrievable');
=======
        // Verify snapshot exists
        Assert.IsTrue(QuoteHeader."Snapshot ID" <> '', 'Snapshot ID should be set');
        Snapshot.Get(QuoteHeader."Snapshot ID");
>>>>>>> ca8b58c48f66f7af5ac5e37f077b7348ddf9dad1
        Assert.AreEqual(QuoteHeader."Quote No.", Snapshot."Quote No.", 'Snapshot should reference quote');

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
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupAR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);

        QuoteHeader.Init();
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

        PricingEngine.RunPricing(QuoteHeader);

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
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        CountrySetup.Get('BR');
        CountrySetup."Emergency Stop" := true;
        CountrySetup.Modify(true);

        asserterror PricingEngine.RunPricing(QuoteHeader);

        Assert.ExpectedError('Pricing Engine is stopped');
    end;

    [Test]
    procedure TestQuoteHeaderOnModifyInvalidatesResults()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        CFData: Record "KINTO Cash Flow Data";
        PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
    begin
        // [Scenario] Modifying Quote Header after calculation invalidates all results
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        PricingEngine.RunPricing(QuoteHeader);

        // Verify results exist
        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.IsTrue(QuoteHeader."Calculated Monthly Fee" > 0, 'Monthly fee should be calculated');

        // Modify the Quote Header
        QuoteHeader."Target ROI %" := 3.0;
        QuoteHeader.Modify(true);

        // Verify results were invalidated
        QuoteHeader.Get(QuoteHeader."Quote No.");
        Assert.AreEqual(0, QuoteHeader."Calculated Monthly Fee", 'Monthly fee should be reset');
        Assert.AreEqual(0, QuoteHeader."KINTO IRR", 'IRR should be reset');
        Assert.AreEqual(
            QuoteHeader."Pricing Status"::Draft,
            QuoteHeader."Pricing Status",
            'Status should revert to Draft');

        // Verify cash flow was deleted
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        Assert.AreEqual(0, CFData.Count, 'Cash flow should be deleted');
    end;
}