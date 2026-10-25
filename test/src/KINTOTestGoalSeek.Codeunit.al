codeunit 50154 "KINTO Test Goal Seek"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestGoalSeekConvergence()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        GoalSeekMgt: Codeunit "KINTO Goal Seek Mgt.";
        CFCalc: Codeunit "KINTO Cash Flow Calculator";
    begin
        // [Scenario] Goal seek should converge to a monthly fee that achieves target ROI
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');
        TestSetup.SetupMaintenancePlan(MaintHeader, MaintLine);
        TestSetup.SetupQuoteHeader(QuoteHeader, 'BR');
        TestSetup.SetupQuoteItem(QuoteItem, QuoteHeader."Quote No.");

        QuoteItem."Purchase Price" := QuoteItem.CalculatePurchasePrice();
        QuoteItem."Final Resale Price" := QuoteItem.CalculateFinalResalePrice();
        QuoteItem.Modify(true);

        // [When] Run goal seek
        GoalSeekMgt.CalculateMonthlyFeeByROI(QuoteHeader, QuoteItem);

        // [Then] Monthly fee should be positive and ROI should be close to target
        Assert.IsTrue(QuoteItem."Monthly Tariff" > 0, 'Monthly tariff should be positive');
        Assert.IsTrue(QuoteItem."Calculated ROI" > 0, 'Calculated ROI should be positive');

        Assert.IsTrue(
            Abs(QuoteItem."Calculated ROI" - QuoteItem."Target ROI %") < 0.01,
            'Calculated ROI should match the target ROI in percentage points');
    end;
}