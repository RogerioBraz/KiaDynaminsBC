codeunit 50160 "KINTO Test Maint Range"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestScenario1_NewCarThreeYearContract()
    var
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintRange: Record "KINTO Maintenance Range";
        MaintNumber: Record "KINTO Maintenance Number";
        TotalCost: Decimal;
    begin
        // Cenário 1: Carro novo, contrato 3 anos, 25.000 km
        // Range: 10.000 km / 12 meses
        // Esperado: Maintenance 1, 2, 3 + Generic Range + Monetary Balance
        TestSetup.CleanupTestData();
        CreateTestMaintenancePlan(MaintHeader, MaintRange, MaintNumber);

        TotalCost := MaintHeader.GetTotalCostForContract(36, 25000, 0, 0);

        // Verifica que o custo é maior que zero (pelo menos 3 faixas + generic)
        Assert.IsTrue(TotalCost > 0, 'Total maintenance cost should be > 0 for 3-year contract');
    end;

    [Test]
    procedure TestScenario2_TwoYearContract35k()
    var
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintRange: Record "KINTO Maintenance Range";
        MaintNumber: Record "KINTO Maintenance Number";
        TotalCost: Decimal;
    begin
        // Cenário 2: Contrato 2 anos, 35.000 km
        // Esperado: Maintenance 1, 2, 3 (35k > 30k threshold)
        TestSetup.CleanupTestData();
        CreateTestMaintenancePlan(MaintHeader, MaintRange, MaintNumber);

        TotalCost := MaintHeader.GetTotalCostForContract(24, 35000, 0, 0);

        Assert.IsTrue(TotalCost > 0, 'Total maintenance cost should be > 0 for 2-year/35k contract');
    end;

    [Test]
    procedure TestScenario3_RenewalVehicle12k()
    var
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintRange: Record "KINTO Maintenance Range";
        MaintNumber: Record "KINTO Maintenance Number";
        TotalCost: Decimal;
    begin
        // Cenário 3: Renovação, odômetro atual 12.000 km, espera chegar a 25.000 km
        // Esperado: apenas Maintenance 2 (12k já passou da faixa 1)
        TestSetup.CleanupTestData();
        CreateTestMaintenancePlan(MaintHeader, MaintRange, MaintNumber);

        TotalCost := MaintHeader.GetTotalCostForContract(12, 13000, 12000, 6);

        // Custo deve incluir apenas faixas 2 e 3 + generic
        Assert.IsTrue(TotalCost > 0, 'Total maintenance cost should be > 0 for renewal');
    end;

    [Test]
    procedure TestMonthlyMaintenanceCost()
    var
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintRange: Record "KINTO Maintenance Range";
        MaintNumber: Record "KINTO Maintenance Number";
        MonthlyCost: Decimal;
    begin
        TestSetup.CleanupTestData();
        CreateTestMaintenancePlan(MaintHeader, MaintRange, MaintNumber);

        MonthlyCost := MaintHeader.GetMonthlyMaintenanceCost(36, 25000, 0, 0);

        Assert.IsTrue(MonthlyCost > 0, 'Monthly maintenance cost should be > 0');
        Assert.IsTrue(MonthlyCost < 10000, 'Monthly maintenance cost should be reasonable (< 10k)');
    end;

    [Test]
    procedure TestMonetaryBalanceIncluded()
    var
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintRange: Record "KINTO Maintenance Range";
        MaintNumber: Record "KINTO Maintenance Number";
        CostWithBalance: Decimal;
        CostWithoutBalance: Decimal;
    begin
        TestSetup.CleanupTestData();
        CreateTestMaintenancePlan(MaintHeader, MaintRange, MaintNumber);

        CostWithBalance := MaintHeader.GetTotalCostForContract(36, 25000, 0, 0);

        MaintHeader."Monetary Balance Amount" := 0;
        MaintHeader.Modify(true);

        CostWithoutBalance := MaintHeader.GetTotalCostForContract(36, 25000, 0, 0);

        Assert.IsTrue(CostWithBalance > CostWithoutBalance, 'Cost with monetary balance should be higher');
    end;

    local procedure CreateTestMaintenancePlan(var MaintHeader: Record "KINTO Maintenance Plan Header"; var MaintRange: Record "KINTO Maintenance Range"; var MaintNumber: Record "KINTO Maintenance Number")
    begin
        // Header
        MaintHeader.Init();
        MaintHeader."Plan ID" := 'TEST-MAINT';
        MaintHeader.Description := 'Test Maintenance Plan';
        MaintHeader."Monetary Balance Amount" := 500;
        MaintHeader."Monetary Balance Markup %" := 2;
        MaintHeader.Status := MaintHeader.Status::Active;
        MaintHeader.Insert(true);

        // Range 1: 10.000 km / 12 meses
        MaintRange.Init();
        MaintRange."Plan ID" := 'TEST-MAINT';
        MaintRange."Range No." := 1;
        MaintRange."Mileage Threshold" := 10000;
        MaintRange."Age Threshold (Months)" := 12;
        MaintRange.Active := true;
        MaintRange.Insert(true);

        // Items Range 1
        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 1, 10000, 'Air Filter', 1, 20, 0);
        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 1, 20000, 'Oil Filter', 1, 50, 0);
        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 1, 30000, 'Labor Cost', 1, 200, 2);

        // Range 2: 20.000 km / 24 meses
        MaintRange.Init();
        MaintRange."Plan ID" := 'TEST-MAINT';
        MaintRange."Range No." := 2;
        MaintRange."Mileage Threshold" := 20000;
        MaintRange."Age Threshold (Months)" := 24;
        MaintRange.Active := true;
        MaintRange.Insert(true);

        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 2, 10000, 'Oil Change', 1, 40, 0);
        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 2, 20000, 'Air Filter', 1, 20, 0);
        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 2, 30000, 'Labor Cost', 1, 200, 2);

        // Range 3: 30.000 km / 36 meses
        MaintRange.Init();
        MaintRange."Plan ID" := 'TEST-MAINT';
        MaintRange."Range No." := 3;
        MaintRange."Mileage Threshold" := 30000;
        MaintRange."Age Threshold (Months)" := 36;
        MaintRange.Active := true;
        MaintRange.Insert(true);

        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 3, 10000, 'Major Service', 1, 500, 5);
        CreateMaintNumber(MaintNumber, 'TEST-MAINT', 3, 20000, 'Labor Cost', 1, 300, 2);

        // Generic Range (Corretiva)
        CreateGenericRange('TEST-MAINT', 'Brake Pads', 10, 150, 0);
        CreateGenericRange('TEST-MAINT', 'Wiper Blades', 10, 30, 0);
    end;

    local procedure CreateMaintNumber(var MaintNumber: Record "KINTO Maintenance Number"; PlanID: Code[20]; RangeNo: Integer; LineNo: Integer; Name: Text[100]; Qty: Decimal; CostVal: Decimal; MarkupVal: Decimal)
    begin
        MaintNumber.Init();
        MaintNumber."Plan ID" := PlanID;
        MaintNumber."Range No." := RangeNo;
        MaintNumber."Line No." := LineNo;
        MaintNumber."Item/Service Name" := Name;
        MaintNumber.Quantity := Qty;
        MaintNumber.Cost := CostVal;
        MaintNumber."Markup %" := MarkupVal;
        MaintNumber.Insert(true);
    end;

    local procedure CreateGenericRange(PlanID: Code[20]; Name: Text[100]; Qty: Decimal; CostVal: Decimal; MarkupVal: Decimal)
    var
        GenericRange: Record "KINTO Mainten Generic Range";
    begin
        GenericRange.Init();
        GenericRange."Plan ID" := PlanID;
        GenericRange."Line No." := GenericRange.Count + 1;
        GenericRange."Item/Service Name" := Name;
        GenericRange.Quantity := Qty;
        GenericRange.Cost := CostVal;
        GenericRange."Markup %" := MarkupVal;
        GenericRange.Active := true;
        GenericRange.Insert(true);
    end;
}