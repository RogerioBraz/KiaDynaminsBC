codeunit 50153 "KINTO Test Cash Flow"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestSetup: Codeunit "KINTO Test Setup";

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
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        QuoteItem."Monthly Tariff" := 5269.22;
        QuoteItem.Modify(true);

        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        TotalMonths := QuoteItem."Contract Term (Months)" + QuoteItem."Extended Analysis Months";
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetRange("Month No.", TotalMonths);
        CFData.SetRange("Component ID", 'RESALE_PRICE');
        Assert.IsTrue(CFData.FindFirst(), 'Resale price should exist in last month');
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
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        QuoteItem."Monthly Tariff" := 5269.22;
        QuoteItem.Modify(true);

        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetRange("Month No.", 1);
        CFData.SetRange("Component ID", 'MONTHLY_TARIFF');
        Assert.IsTrue(CFData.FindFirst(), 'Monthly tariff should exist in month 1');
        Assert.AreEqual(5269.22, CFData."Signed Amount", 'Monthly tariff amount should match');

        CFData.SetRange("Component ID", 'PIS_COFINS_TARIFF');
        Assert.IsTrue(CFData.FindFirst(), 'PIS/COFINS should exist in month 1');
        Assert.IsTrue(CFData."Signed Amount" < 0, 'PIS/COFINS should be negative');

        CFData.SetRange("Component ID", 'BODY_INSURANCE');
        Assert.IsTrue(CFData.FindFirst(), 'Body insurance should be posted monthly');
    end;

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
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        // Purchase Price já foi auto-calculado pelo OnValidate
        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        Assert.IsTrue(QuoteItem."Purchase Price" > 0, 'Purchase Price should be auto-calculated');

        // [When] Generate cash flow
        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        // [Then] Verify month zero entries exist
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetRange("Month No.", 0);
        Assert.IsTrue(CFData.FindSet(), 'Month zero entries should exist');

        CFData.SetRange("Component ID", 'PURCHASE_PRICE');
        Assert.IsTrue(CFData.FindFirst(), 'Purchase price entry should exist in month zero');
        Assert.AreEqual(-QuoteItem."Purchase Price", CFData."Signed Amount", 'Purchase price should be negative');

        CFData.SetRange("Component ID", 'BODY_INSURANCE');
        Assert.IsTrue(not CFData.FindFirst(), 'Body insurance should not be posted in month zero');
    end;

    [Test]
    procedure TestOnModifyInvalidatesCashFlow()
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
        // [Scenario] Modifying Quote Item after calculation invalidates cash flow
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        QuoteItem."Monthly Tariff" := 5269.22;
        QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Calculated;
        QuoteItem.Modify(true);

        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        // Verify cash flow exists
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        Assert.IsTrue(CFData.Count > 0, 'Cash flow should exist after generation');

        // Modify the Quote Item — should invalidate cash flow
        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        QuoteItem."Monthly Tariff" := 6000;
        QuoteItem.Modify(true);


        // Verify cash flow was deleted
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        Assert.AreEqual(0, CFData.Count, 'Cash flow should be invalidated after modify');

        // Verify status reverted to Draft
        QuoteItem.Get(QuoteHeader."Quote No.", 10000);
        Assert.AreEqual(
            QuoteItem."Pricing Status"::Draft,
            QuoteItem."Pricing Status",
            'Status should revert to Draft after modify');
    end;


    [Test]
    procedure TestOnValidateAutoCalculatesPurchasePrice()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        ExpectedPurchasePrice: Decimal;
    begin
        // [Scenario] Setting MSRP and Discount auto-calculates Purchase Price
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');

        QuoteItem.Init();
        QuoteItem."Quote No." := QuoteHeader."Quote No.";
        QuoteItem."Line No." := 10000;
        QuoteItem."Item No." := 'CC-XRE';

        QuoteItem.Validate(MSRP, 100000);
        QuoteItem.Validate("Discount Rate %", 10);
        QuoteItem.Validate("Equipment Price", 5000);

        QuoteItem.Insert(true);

        // Recarrega o registro salvo
        QuoteItem.Get(QuoteHeader."Quote No.", 10000);

        // Purchase Price = 100000 * 0.90 + 5000 = 95000
        ExpectedPurchasePrice := 95000;

        Assert.AreEqual(
            ExpectedPurchasePrice,
            QuoteItem."Purchase Price",
            'Purchase Price should be auto-calculated on validate');
    end;
}