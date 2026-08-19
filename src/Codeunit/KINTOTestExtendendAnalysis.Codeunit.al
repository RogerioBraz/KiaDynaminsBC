codeunit 50157 "KINTO Test Extended Analysis"
{
    Caption = 'KINTO Test: Extended Analysis Period';
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestExtendedAnalysis30Days()
    var
        QuoteHeader: Record "KINTO Quote Header";
    begin
        // [Scenario] 30 days payment allowance = 1 extended month
        TestSetup.CleanupTestData();
        TestSetup.SetupCountrySetupBR(QuoteHeader);

        // [When] Calculate extended analysis for 30 days
        // [Then] Should be 1 month
        Assert.AreEqual(1, QuoteHeader.CalcExtendedAnalysisMonths(30), '30 days should yield 1 month');
    end;

    [Test]
    procedure TestExtendedAnalysis40Days()
    begin
        // [Scenario] 40 days = 2 extended months
        Assert.AreEqual(2, CalcMonths(40), '40 days should yield 2 months');
    end;

    [Test]
    procedure TestExtendedAnalysis60Days()
    begin
        // [Scenario] 60 days = 2 extended months
        Assert.AreEqual(2, CalcMonths(60), '60 days should yield 2 months');
    end;

    [Test]
    procedure TestExtendedAnalysis65Days()
    begin
        // [Scenario] 65 days = 3 extended months
        Assert.AreEqual(3, CalcMonths(65), '65 days should yield 3 months');
    end;

    [Test]
    procedure TestExtendedAnalysis90Days()
    begin
        // [Scenario] 90 days = 3 extended months
        Assert.AreEqual(3, CalcMonths(90), '90 days should yield 3 months');
    end;

    local procedure CalcMonths(Days: Integer): Integer
    var
        QuoteHeader: Record "KINTO Quote Header";
    begin
        exit(QuoteHeader.CalcExtendedAnalysisMonths(Days));
    end;
}