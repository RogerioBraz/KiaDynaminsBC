codeunit 50161 "KINTO Test Package Pricing"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestUsedVehicleMaintenanceRequiresInventoryVehicle()
    var
        CountrySetup: Record "KINTO Country Setup";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        PackagePricing: Codeunit "KINTO Package Pricing Calc";
        MonthlyCost: Decimal;
    begin
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem."Vehicle Condition" := QuoteItem."Vehicle Condition"::Used;
        QuoteItem.Modify(true);

        asserterror MonthlyCost := PackagePricing.GetMaintenanceMonthly(QuoteItem);
        Assert.ExpectedError('An inventory vehicle is required');
    end;

    [Test]
    procedure TestGlassCoverageMonthlyCost()
    var
        GlassPkg: Record "KINTO Glass Coverage Package";
        MonthlyCost: Decimal;
    begin
        GlassPkg.Init();
        GlassPkg."Package ID" := 'TEST-GLASS';
        GlassPkg.Cost := 600;
        GlassPkg."Markup %" := 10;
        GlassPkg.Insert(true);

        MonthlyCost := GlassPkg.GetMonthlyCost(12);

        // Expected: (600 * 1.10) / 12 = 55
        Assert.AreEqual(55, MonthlyCost, 'Glass coverage monthly cost should be 55');
    end;

    [Test]
    procedure Test24hAssistanceMonthlyCost()
    var
        AssistPkg: Record "KINTO 24h Assistance Package";
        MonthlyCost: Decimal;
    begin
        AssistPkg.Init();
        AssistPkg."Package ID" := 'TEST-24H';
        AssistPkg.Cost := 360;
        AssistPkg."Markup %" := 0;
        AssistPkg.Insert(true);

        MonthlyCost := AssistPkg.GetMonthlyCost(12);

        Assert.AreEqual(30, MonthlyCost, '24h assistance monthly cost should be 30');
    end;

    [Test]
    procedure TestReplacementVehicleCost()
    var
        ReplPkg: Record "KINTO Replacement Vehicle Pkg";
        MonthlyCost: Decimal;
    begin
        ReplPkg.Init();
        ReplPkg."Package ID" := 'TEST-REPL';
        ReplPkg.Cost := 100;
        ReplPkg."Markup %" := 10;
        ReplPkg."Default Uses" := 3;
        ReplPkg.Insert(true);

        // 3 uses * 100 * 1.10 = 330, / 12 months = 27.5
        MonthlyCost := ReplPkg.GetMonthlyCost(3, 12);

        Assert.AreEqual(27.5, MonthlyCost, 'Replacement vehicle monthly cost should be 27.5');
    end;

    [Test]
    procedure TestTirePackageCost()
    var
        TirePkg: Record "KINTO Tire Package";
        MonthlyCost: Decimal;
    begin
        TirePkg.Init();
        TirePkg."Package ID" := 'TEST-TIRE';
        TirePkg."Cost per Tire" := 400;
        TirePkg."Markup %" := 5;
        TirePkg."Default Quantity" := 4;
        TirePkg.Insert(true);

        // 4 tires * 400 * 1.05 = 1680, / 12 = 140
        MonthlyCost := TirePkg.GetMonthlyCost(4, 12);

        Assert.AreEqual(140, MonthlyCost, 'Tire package monthly cost should be 140');
    end;

    [Test]
    procedure TestServicePackageBillingFreq()
    var
        ServicePkg: Record "KINTO Service Package";
        MonthlyCost: Decimal;
    begin
        // Monthly billing
        ServicePkg.Init();
        ServicePkg."Package ID" := 'TEST-SVC-M';
        ServicePkg.Cost := 90;
        ServicePkg."Markup %" := 0;
        ServicePkg."Billing Frequency" := ServicePkg."Billing Frequency"::Monthly;
        MonthlyCost := ServicePkg.GetMonthlyCost();
        Assert.AreEqual(90, MonthlyCost, 'Monthly service cost should be 90');

        // Annual billing → 90/12 = 7.5
        ServicePkg."Billing Frequency" := ServicePkg."Billing Frequency"::Annual;
        MonthlyCost := ServicePkg.GetMonthlyCost();
        Assert.AreEqual(7.5, MonthlyCost, 'Annual service monthly cost should be 7.5');
    end;

    [Test]
    procedure TestInsuranceCoverageLimit()
    var
        CoverageLimit: Record "KINTO Insurance Coverage Limit";
        Premium: Decimal;
    begin
        // Coverage % = 5% of vehicle value, markup = 10%
        CoverageLimit.Init();
        CoverageLimit."Insurance Package ID" := 1;
        CoverageLimit."Coverage Category" := CoverageLimit."Coverage Category"::"Property Damage";
        CoverageLimit."Coverage %" := 5;
        CoverageLimit."Markup %" := 10;
        CoverageLimit.Insert(true);

        // Vehicle value = 100.000
        // Premium = 100.000 * 5% * 1.10 = 5.500
        Premium := CoverageLimit.CalculatePremium(100000);

        Assert.AreEqual(5500, Premium, 'Insurance premium should be 5500');
    end;

    [Test]
    procedure TestItemVersionHistoryPricingValue()
    var
        VersionHist: Record "KINTO Item Version History";
        PricingValue: Decimal;
    begin
        VersionHist.Init();
        VersionHist."Item No." := 'TEST-ITEM';
        VersionHist.Cost := 1000;
        VersionHist."Markup %" := 15;
        VersionHist."Active Start Date" := Today;
        VersionHist.Insert(true);

        // Pricing Value = 1000 * 1.15 = 1150
        Assert.AreEqual(1150, VersionHist."Pricing Value", 'Pricing value should be 1150');

        // Test lookup
        PricingValue := VersionHist.GetCurrentPricingValue('TEST-ITEM', Today);
        Assert.AreEqual(1150, PricingValue, 'Current pricing value lookup should return 1150');
    end;
}