codeunit 50161 "KINTO Fleet Management"
{
    // D7 Fleet Control — motor de movimentação. Todo caminho passa aqui:
    // mudança de status, troca de placa, dispositivo, desmobilização,
    // sanitização e fechamento mensal. Comportamento por país vem do
    // Country Setup (Fleet Behavior + SLAs + reconciliação).

    var
        CountryNotFoundErr: Label 'Country setup %1 not found.';
        DeviceNotInStockErr: Label 'Device %1 is not in stock.';
        DeviceNotInstalledErr: Label 'Device %1 is not installed in a vehicle.';
        PlateSameErr: Label 'New plate equals the current one.';
        DemobNotBRLabel: Label 'Demobilization workflow applies to Brazil behavior only.';

    // ---------- STATUS ----------
    procedure ChangeVehicleStatus(VehicleNo: Code[20]; NewStatus: Enum "KINTO Vehicle Status"; ReasonCode: Code[20]; Description: Text)
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Ledger: Record "KINTO Fleet Movement Ledger";
    begin
        Vehicle.Get(VehicleNo);
        Ledger.LogMovement(VehicleNo, "KINTO Movement Type"::"Status Change",
            Vehicle.Status, NewStatus, WorkDate(), Vehicle."Last Contract No.", Description);
        Vehicle.Status := NewStatus;
        Vehicle.Modify(true);
    end;

    // ---------- TROCA DE PLACA (mesmo chassi, sem duplicar) ----------
    procedure ChangePlate(VehicleNo: Code[20]; NewPlate: Text[20]; ReasonCode: Code[20])
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Ledger: Record "KINTO Fleet Movement Ledger";
    begin
        Vehicle.Get(VehicleNo);
        if NewPlate = Vehicle."License Plate" then
            Error(PlateSameErr);

        Ledger.LogMovement(VehicleNo, "KINTO Movement Type"::"Plate Change",
            Vehicle.Status, Vehicle.Status, WorkDate(), Vehicle."Last Contract No.",
            StrSubstNo('Plate changed %1 -> %2', Vehicle."License Plate", NewPlate));
        Vehicle."License Plate" := NewPlate;
        Vehicle.Modify(true);
    end;

    // ---------- DISPOSITIVO TELEMÁTICO ----------
    procedure InstallDevice(DeviceNo: Code[20]; VehicleNo: Code[20]; ContractNo: Code[20])
    var
        Device: Record "KINTO Telematic Device";
        Vehicle: Record "KINTO Inventory Vehicle";
        History: Record "KINTO Device History";
        Ledger: Record "KINTO Fleet Movement Ledger";
    begin
        Device.Get(DeviceNo);
        if Device.Status <> Device.Status::"In Stock" then
            Error(DeviceNotInStockErr, DeviceNo);
        Vehicle.Get(VehicleNo);

        Device.Status := Device.Status::Installed;
        Device."Installed Vehicle No." := VehicleNo;
        Device."Install Date" := WorkDate();
        Device."Install Count" += 1;
        Device.UpdateAging(GetDeviceAgingThreshold(Device."Country Code"));
        Device.Modify(true);

        History.Init();
        History."Entry No." := History.NextEntryNo();
        History."Device No." := DeviceNo;
        History.Event := History.Event::Installed;
        History."Event Date" := WorkDate();
        History."Vehicle No." := VehicleNo;
        History."Contract No." := ContractNo;
        History."Vendor No." := Device."Vendor No.";
        History."User ID" := CopyStr(UserId, 1, MaxStrLen(History."User ID"));
        History.Insert(false);

        Ledger.LogMovement(VehicleNo, "KINTO Movement Type"::"Device Install",
            Vehicle.Status, Vehicle.Status, WorkDate(), ContractNo,
            StrSubstNo('Device %1 installed', DeviceNo));
    end;

    procedure RemoveDevice(DeviceNo: Code[20])
    var
        Device: Record "KINTO Telematic Device";
        History: Record "KINTO Device History";
        Ledger: Record "KINTO Fleet Movement Ledger";
        VehicleNo: Code[20];
    begin
        Device.Get(DeviceNo);
        if Device.Status <> Device.Status::Installed then
            Error(DeviceNotInstalledErr, DeviceNo);
        VehicleNo := Device."Installed Vehicle No.";

        Device.Status := Device.Status::"In Stock";
        Device."Removal Date" := WorkDate();
        Device."Installed Vehicle No." := '';
        Device.UpdateAging(GetDeviceAgingThreshold(Device."Country Code"));
        Device.Modify(true);

        History.Init();
        History."Entry No." := History.NextEntryNo();
        History."Device No." := DeviceNo;
        History.Event := History.Event::Removed;
        History."Event Date" := WorkDate();
        History."Vehicle No." := VehicleNo;
        History."Vendor No." := Device."Vendor No.";
        History."User ID" := CopyStr(UserId, 1, MaxStrLen(History."User ID"));
        History.Insert(false);

        if VehicleNo <> '' then
            Ledger.LogMovement(VehicleNo, "KINTO Movement Type"::"Device Remove",
                "KINTO Vehicle Status"::"In Contract", "KINTO Vehicle Status"::"In Contract",
                WorkDate(), '', StrSubstNo('Device %1 removed', DeviceNo));
    end;

    local procedure GetDeviceAgingThreshold(CountryCode: Code[10]): Integer
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CountrySetup.Get(CountryCode) then
            exit(CountrySetup."Device Aging Charge Days");
        exit(60);
    end;

    // ---------- DESMOBILIZAÇÃO (BR: guardião fora de contrato) ----------
    procedure StartDemobilization(VehicleNo: Code[20]; ReasonCode: Code[20])
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        CountrySetup: Record "KINTO Country Setup";
        Ledger: Record "KINTO Fleet Movement Ledger";
    begin
        Vehicle.Get(VehicleNo);
        if Vehicle."Country Code" <> '' then begin
            if not CountrySetup.Get(Vehicle."Country Code") then
                Error(CountryNotFoundErr, Vehicle."Country Code");
        end else
            if not CountrySetup.Get('BR') then
                Error(CountryNotFoundErr, 'BR');
        if CountrySetup."Fleet Behavior" <> CountrySetup."Fleet Behavior"::Brazil then
            Error(DemobNotBRLabel);

        Ledger.LogMovement(VehicleNo, "KINTO Movement Type"::"Demobilization Start",
            Vehicle.Status, Vehicle.Status::Inactive, WorkDate(), Vehicle."Last Contract No.",
            StrSubstNo('Demobilization started (SLA lot %1 / wash %2 / salvage %3 days)',
                CountrySetup."Demob. SLA Days (Lot)", CountrySetup."Demob. SLA Days (Wash)",
                CountrySetup."Demob. SLA Days (Save)"));
        Vehicle.Status := Vehicle.Status::Inactive;
        Vehicle.Modify(true);
    end;

    // ---------- SANITIZAÇÃO (One/Share) ----------
    procedure LogSanitization(VehicleNo: Code[20]; Description: Text)
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Ledger: Record "KINTO Fleet Movement Ledger";
    begin
        Vehicle.Get(VehicleNo);
        Ledger.LogMovement(VehicleNo, "KINTO Movement Type"::Sanitization,
            Vehicle.Status, Vehicle.Status, WorkDate(), Vehicle."Last Contract No.",
            CopyStr(Description, 1, 100));
    end;

    // ---------- FECHAMENTO MENSAL ----------
    procedure RunMonthlyClosing(ClosingMonth: Date; CountryCode: Code[10])
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Device: Record "KINTO Telematic Device";
        Policy: Record "KINTO Insurance Policy";
        Contract: Record "KINTO Vehicle Contract";
        Snapshot: Record "KINTO Fleet Closing Snapshot";
        CountrySetup: Record "KINTO Country Setup";
        BillingLine: Record "KINTO Billing Line";
        MonthStart: Date;
        MonthEnd: Date;
    begin
        if not CountrySetup.Get(CountryCode) then
            Error(CountryNotFoundErr, CountryCode);

        MonthStart := CalcDate('<-CM>', ClosingMonth);
        MonthEnd := CalcDate('<CM>', ClosingMonth);

        Vehicle.SetRange("Country Code", CountryCode);
        if Vehicle.FindSet() then
            repeat
                Snapshot.Init();
                Snapshot."Entry No." := Snapshot.NextEntryNo();
                Snapshot."Closing Month" := MonthStart;
                Snapshot."Vehicle No." := Vehicle."Vehicle No.";
                Snapshot."License Plate" := Vehicle."License Plate";
                Snapshot.VIN := Vehicle.VIN;
                Snapshot."Vehicle Status" := Vehicle.Status;
                Snapshot."Country Code" := CountryCode;
                Snapshot."Snapshot DateTime" := CurrentDateTime;

                if Contract.Get(Vehicle."Last Contract No.") then begin
                    Snapshot."Contract No." := Contract."Contract No.";
                    Snapshot."Customer No." := Contract."Customer No.";
                end;
                Snapshot."Odometer" := Vehicle."Current Odometer";

                Device.SetRange("Installed Vehicle No.", Vehicle."Vehicle No.");
                Device.SetRange(Status, Device.Status::Installed);
                if Device.FindFirst() then begin
                    Snapshot."Device No." := Device."Device No.";
                    Snapshot."Device Status" := Device.Status;
                end;

                Policy.SetRange("Vehicle No.", Vehicle."Vehicle No.");
                Policy.SetRange(Status, Policy.Status::Active);
                if Policy.FindFirst() then
                    Snapshot."Active Policy No." := Policy."Policy No.";

                BillingLine.SetRange("Contract No.", Vehicle."Last Contract No.");
                BillingLine.SetRange("Billing Month", MonthStart);
                BillingLine.CalcSums(Amount);
                Snapshot."Monthly Billing Amount" := BillingLine.Amount;

                // Reconciliação por país (BR: VIN; AR: VIN e placa)
                Snapshot.Reconciled := true;
                if CountrySetup."Closing Reconcile By VIN" and (Snapshot.VIN = '') then begin
                    Snapshot.Reconciled := false;
                    Snapshot."Reconcile Issue" := 'VIN missing';
                end;
                if CountrySetup."Closing Reconcile By Plate" and (Snapshot."License Plate" = '') then begin
                    Snapshot.Reconciled := false;
                    if Snapshot."Reconcile Issue" <> '' then
                        Snapshot."Reconcile Issue" += '; ';
                    Snapshot."Reconcile Issue" += 'Plate missing';
                end;

                Snapshot.Insert(false);
            until Vehicle.Next() = 0;
    end;
}
