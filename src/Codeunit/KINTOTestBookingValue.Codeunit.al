codeunit 50156 "KINTO Test Booking Value"
{
    Caption = 'KINTO Test: Booking Value';
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        TestSetup: Codeunit "KINTO Test Setup";

    [Test]
    procedure TestSoftReserveVehicle()
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        BookingMgt: Codeunit "KINTO Booking Value Mgt.";
    begin
        // [Scenario] Soft reserve an available vehicle
        TestSetup.CleanupTestData();

        InventoryVehicle.Init();
        InventoryVehicle."Vehicle No." := 'VH-001';
        InventoryVehicle."Vehicle Condition" := InventoryVehicle."Vehicle Condition"::Used;
        InventoryVehicle."Status" := InventoryVehicle."Status"::Available;
        InventoryVehicle."Booking Value" := 100000;
        InventoryVehicle.Insert(true);

        // [When] Soft reserve
        BookingMgt.SoftReserveVehicle(InventoryVehicle, 'QUOTE-001');

        // [Then] Status should be Soft Reserved
        InventoryVehicle.Get('VH-001');
        Assert.AreEqual(
            InventoryVehicle."Status"::"Soft Reserved",
            InventoryVehicle."Status",
            'Vehicle should be Soft Reserved');
        Assert.AreEqual('QUOTE-001', InventoryVehicle."Soft Reserved by Quote", 'Quote should be set');
    end;

    [Test]
    procedure TestReleaseReservation()
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        BookingMgt: Codeunit "KINTO Booking Value Mgt.";
    begin
        // [Scenario] Release a soft reservation
        TestSetup.CleanupTestData();

        InventoryVehicle.Init();
        InventoryVehicle."Vehicle No." := 'VH-002';
        InventoryVehicle."Vehicle Condition" := InventoryVehicle."Vehicle Condition"::Used;
        InventoryVehicle."Status" := InventoryVehicle."Status"::"Soft Reserved";
        InventoryVehicle."Soft Reserved by Quote" := 'QUOTE-002';
        InventoryVehicle."Booking Value" := 80000;
        InventoryVehicle.Insert(true);

        // [When] Release reservation
        BookingMgt.ReleaseReservation(InventoryVehicle);

        // [Then] Status should be Available
        InventoryVehicle.Get('VH-002');
        Assert.AreEqual(
            InventoryVehicle."Status"::Available,
            InventoryVehicle."Status",
            'Vehicle should be Available');
        Assert.AreEqual('', InventoryVehicle."Soft Reserved by Quote", 'Quote should be cleared');
    end;

    [Test]
    procedure TestFreezeBookingValue()
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        BookingMgt: Codeunit "KINTO Booking Value Mgt.";
    begin
        // [Scenario] Freeze booking value on vehicle return
        TestSetup.CleanupTestData();

        InventoryVehicle.Init();
        InventoryVehicle."Vehicle No." := 'VH-003';
        InventoryVehicle."Vehicle Condition" := InventoryVehicle."Vehicle Condition"::Used;
        InventoryVehicle."Status" := InventoryVehicle."Status"::"In Contract";
        InventoryVehicle."Booking Value" := 75000;
        InventoryVehicle.Insert(true);

        // [When] Freeze booking value
        BookingMgt.FreezeBookingValue(InventoryVehicle);

        // [Then] Frozen value should match current booking value
        InventoryVehicle.Get('VH-003');
        Assert.AreEqual(75000, InventoryVehicle."Frozen Booking Value", 'Frozen booking value should match');
        Assert.AreEqual(
            InventoryVehicle."Status"::Returned,
            InventoryVehicle."Status",
            'Vehicle should be Returned');
    end;

    [Test]
    procedure TestMonthlyDepreciation()
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        BookingMgt: Codeunit "KINTO Booking Value Mgt.";
    begin
        // [Scenario] Apply monthly depreciation to booking value
        TestSetup.CleanupTestData();

        InventoryVehicle.Init();
        InventoryVehicle."Vehicle No." := 'VH-004';
        InventoryVehicle."Vehicle Condition" := InventoryVehicle."Vehicle Condition"::Used;
        InventoryVehicle."Status" := InventoryVehicle."Status"::"In Contract";
        InventoryVehicle."Booking Value" := 100000;
        InventoryVehicle.Insert(true);

        // [When] Apply monthly depreciation of 2000
        BookingMgt.MonthlyDepreciation(InventoryVehicle, 2000);

        // [Then] Booking value should decrease
        InventoryVehicle.Get('VH-004');
        Assert.AreEqual(98000, InventoryVehicle."Booking Value", 'Booking value should be 98000');
    end;

    [Test]
    procedure TestMonthlyDepreciationFloorAtZero()
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        BookingMgt: Codeunit "KINTO Booking Value Mgt.";
    begin
        // [Scenario] Booking value should not go below zero
        TestSetup.CleanupTestData();

        InventoryVehicle.Init();
        InventoryVehicle."Vehicle No." := 'VH-005';
        InventoryVehicle."Vehicle Condition" := InventoryVehicle."Vehicle Condition"::Used;
        InventoryVehicle."Status" := InventoryVehicle."Status"::"In Contract";
        InventoryVehicle."Booking Value" := 1000;
        InventoryVehicle.Insert(true);

        // [When] Apply depreciation greater than remaining value
        BookingMgt.MonthlyDepreciation(InventoryVehicle, 2000);

        // [Then] Booking value should be 0 (floor)
        InventoryVehicle.Get('VH-005');
        Assert.AreEqual(0, InventoryVehicle."Booking Value", 'Booking value should be floored at 0');
    end;
}