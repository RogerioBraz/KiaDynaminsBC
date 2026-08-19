codeunit 50151 "KINTO Test Country Setup"
{
    Caption = 'KINTO Test: Country Setup';
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        TestSetup: Codeunit "KINTO Test Setup";
        Any: Codeunit Any;

    [Test]
    procedure TestCreateCountrySetupBR()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        // [Scenario] Create BR country setup and verify defaults
        // [Given] Clean environment
        TestSetup.CleanupTestData();

        // [When] Create BR setup
        TestSetup.SetupCountrySetupBR(CountrySetup);

        // [Then] Verify values
        CountrySetup.Get('BR');
        Assert.AreEqual('BR', CountrySetup."Country Code", 'Country Code should be BR');
        Assert.AreEqual(CountrySetup."Pricing Methodology"::"Target ROI", CountrySetup."Pricing Methodology", 'BR should use Target ROI');
        Assert.AreEqual('BRL', CountrySetup."Currency Code", 'Currency should be BRL');
        Assert.AreEqual(CountrySetup."DLR Commission Model"::"One-Shot", CountrySetup."DLR Commission Model", 'BR should use One-Shot commission');
        Assert.AreEqual(60, CountrySetup."Tax Depreciation Period", 'Tax depreciation should be 60 months');
    end;

    [Test]
    procedure TestCreateCountrySetupAR()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        // [Scenario] Create AR country setup and verify defaults
        // [Given] Clean environment
        TestSetup.CleanupTestData();

        // [When] Create AR setup
        TestSetup.SetupCountrySetupAR(CountrySetup);

        // [Then] Verify values
        CountrySetup.Get('AR');
        Assert.AreEqual('AR', CountrySetup."Country Code", 'Country Code should be AR');
        Assert.AreEqual(CountrySetup."Pricing Methodology"::"KINTO Fee", CountrySetup."Pricing Methodology", 'AR should use KINTO Fee');
        Assert.AreEqual(CountrySetup."DLR Commission Model"::Monthly, CountrySetup."DLR Commission Model", 'AR should use Monthly commission');
        Assert.AreEqual(true, CountrySetup."Allow USD Contracts", 'AR should allow USD contracts');
    end;

    [Test]
    procedure TestEmergencyStop()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        // [Scenario] Emergency stop flag blocks pricing
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(CountrySetup);

        CountrySetup.Get('BR');
        CountrySetup."Emergency Stop" := true;
        CountrySetup.Modify(true);

        Assert.AreEqual(true, CountrySetup."Emergency Stop", 'Emergency stop should be true');
    end;
}