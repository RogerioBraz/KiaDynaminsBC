codeunit 50153 "KINTO Test Cash Flow"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestGenerateCashFlowMonthZero()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        CFData: Record "KINTO Cash Flow Data";
        CFCalc: Codeunit "KINTO Cash Flow Calculator";
    begin
        // [Scenario] Generate cash flow and verify month zero entries
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        // Calculate purchase price
        QuoteItem."Purchase Price" := QuoteItem.CalculatePurchasePrice();
        QuoteItem.Modify(true);

        // [When] Generate cash flow
        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        // [Then] Verify month zero entries exist
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetRange("Month No.", 0);
        Assert.IsTrue(CFData.FindSet(), 'Month zero entries should exist');

        // Verify purchase price entry
        CFData.SetRange("Component ID", 'PURCHASE_PRICE');
        Assert.IsTrue(CFData.FindFirst(), 'Purchase price entry should exist in month zero');
        Assert.AreEqual(-QuoteItem."Purchase Price", CFData."Signed Amount", 'Purchase price should be negative');
    end;

    [Test]
    procedure TestGenerateCashFlowMonthlyEntries()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        CFData: Record "KINTO Cash Flow Data";
        CFCalc: Codeunit "KINTO Cash Flow Calculator";
    begin
        // [Scenario] Generate cash flow and verify monthly tariff entries
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem."Purchase Price" := QuoteItem.CalculatePurchasePrice();
        QuoteItem."Monthly Tariff" := 5269.22;
        QuoteItem.Modify(true);

        // [When] Generate cash flow
        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        // [Then] Verify month 1 has monthly tariff
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetRange("Month No.", 1);
        CFData.SetRange("Component ID", 'MONTHLY_TARIFF');
        Assert.IsTrue(CFData.FindFirst(), 'Monthly tariff should exist in month 1');
        Assert.AreEqual(5269.22, CFData."Signed Amount", 'Monthly tariff amount should match');

        // Verify PIS/COFINS on tariff
        CFData.SetRange("Component ID", 'PIS_COFINS_TARIFF');
        Assert.IsTrue(CFData.FindFirst(), 'PIS/COFINS should exist in month 1');
        Assert.IsTrue(CFData."Signed Amount" < 0, 'PIS/COFINS should be negative');
    end;

    [Test]
    procedure TestGenerateCashFlowEndOfContract()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        CFData: Record "KINTO Cash Flow Data";
        CFCalc: Codeunit "KINTO Cash Flow Calculator";
        TotalMonths: Integer;
    begin
        // [Scenario] Generate cash flow and verify end-of-contract resale
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem."Purchase Price" := QuoteItem.CalculatePurchasePrice();
        QuoteItem."Final Resale Price" := QuoteItem.CalculateFinalResalePrice();
        QuoteItem."Monthly Tariff" := 5269.22;
        QuoteItem.Modify(true);

        // [When] Generate cash flow
        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        // [Then] Verify resale price in last month
        TotalMonths := QuoteItem."Contract Term (Months)" + QuoteItem."Extended Analysis Months";
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetRange("Month No.", TotalMonths);
        CFData.SetRange("Component ID", 'RESALE_PRICE');
        Assert.IsTrue(CFData.FindFirst(), 'Resale price should exist in last month');
        Assert.AreEqual(QuoteItem."Final Resale Price", CFData."Signed Amount", 'Resale price should match');
    end;
}