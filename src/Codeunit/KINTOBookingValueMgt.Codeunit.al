codeunit 50107 "KINTO Booking Value Mgt."
{
    var
        VehicleNotAvailableErr: Label 'Vehicle %1 cannot be reserved because its current status is %2. Release the vehicle or select an available vehicle before continuing.';

    procedure InitializeBookingValue(var InventoryVehicle: Record "KINTO Inventory Vehicle"; InitialValue: Decimal)
    begin
        InventoryVehicle."Booking Value" := InitialValue;
        InventoryVehicle.Modify(true);
    end;

    procedure MonthlyDepreciation(var InventoryVehicle: Record "KINTO Inventory Vehicle"; MonthlyAmount: Decimal)
    begin
        InventoryVehicle."Booking Value" -= MonthlyAmount;
        if InventoryVehicle."Booking Value" < 0 then
            InventoryVehicle."Booking Value" := 0;
        InventoryVehicle.Modify(true);
    end;

    procedure FreezeBookingValue(var InventoryVehicle: Record "KINTO Inventory Vehicle")
    begin
        InventoryVehicle."Frozen Booking Value" := InventoryVehicle."Booking Value";
        InventoryVehicle.Status := InventoryVehicle.Status::Returned;
        InventoryVehicle.Modify(true);
    end;

    procedure GetFrozenBookingValue(var InventoryVehicle: Record "KINTO Inventory Vehicle"): Decimal
    begin
        exit(InventoryVehicle."Frozen Booking Value");
    end;

    procedure SoftReserveVehicle(var InventoryVehicle: Record "KINTO Inventory Vehicle"; QuoteNo: Code[20])
    begin
        if InventoryVehicle.Status <> InventoryVehicle.Status::Available then
            Error(VehicleNotAvailableErr,
                  InventoryVehicle."Vehicle No.", InventoryVehicle.Status);

        InventoryVehicle.Status := InventoryVehicle.Status::"Soft Reserved";
        InventoryVehicle."Soft Reserved by Quote" := QuoteNo;
        InventoryVehicle."Reservation Date" := Today;
        InventoryVehicle.Modify(true);
    end;

    procedure ReleaseReservation(var InventoryVehicle: Record "KINTO Inventory Vehicle")
    begin
        if InventoryVehicle.Status = InventoryVehicle.Status::"Soft Reserved" then begin
            InventoryVehicle.Status := InventoryVehicle.Status::Available;
            InventoryVehicle."Soft Reserved by Quote" := '';
            InventoryVehicle."Reservation Date" := 0D;
            InventoryVehicle.Modify(true);
        end;
    end;
}