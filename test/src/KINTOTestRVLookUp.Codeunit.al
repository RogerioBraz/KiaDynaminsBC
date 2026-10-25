codeunit 50152 "KINTO Test RV Lookup"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestRVLookupBasic()
    var
        RVMatrix: Record "KINTO RV Matrix";
        VehicleModel: Record "KINTO Vehicle Model";
        QuoteItem: Record "KINTO Quote Item";
        RVLookupMgt: Codeunit "KINTO RV Lookup Mgt.";
        Result: Decimal;
    begin
        // [Scenario] Lookup RV for a vehicle with matching matrix entry
        // [Given] RV Matrix with entry for item
        TestSetup.CleanupTestData();
        TestSetup.SetupVehicleModel(VehicleModel);
        TestSetup.SetupRVMatrix(RVMatrix, 'CC-XRE');

        // [When] Lookup residual value
        QuoteItem.Init();
        QuoteItem."Item No." := 'CC-XRE';
        QuoteItem."Usage Type" := QuoteItem."Usage Type"::Normal;
        QuoteItem."Monthly Mileage (km)" := 1000;
        QuoteItem."Contract Term (Months)" := 12;
        Result := RVLookupMgt.LookupResidualValue(QuoteItem);

        // [Then] Should return the configured RV %
        Assert.IsTrue(Result > 0, 'RV should be greater than 0');
    end;

    [Test]
    procedure TestRVLookupNoMatch()
    var
        QuoteItem: Record "KINTO Quote Item";
        RVLookupMgt: Codeunit "KINTO RV Lookup Mgt.";
        Result: Decimal;
    begin
        // [Scenario] Lookup RV for a vehicle with no matching matrix entry
        TestSetup.CleanupTestData();

        QuoteItem.Init();
        QuoteItem."Item No." := 'NONEXISTENT';
        QuoteItem."Usage Type" := QuoteItem."Usage Type"::Normal;
        QuoteItem."Monthly Mileage (km)" := 1000;
        QuoteItem."Contract Term (Months)" := 12;

        // [When] Lookup — should error
        asserterror Result := RVLookupMgt.LookupResidualValue(QuoteItem);

        // [Then] Error expected
        Assert.ExpectedError('No Residual Value found');
    end;
}