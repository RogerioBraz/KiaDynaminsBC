table 50441 "KINTO Fleet Movement Ledger"
{
    Caption = 'KINTO Fleet Movement Ledger';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Fleet Movement Ledger";
    DrillDownPageId = "KINTO Fleet Movement Ledger";

    // Histórico integral do veículo (D7): toda mudança de estado gera
    // um movimento. "Qual contrato/placa/motorista em qualquer data" =
    // filtrar por Vehicle No. + Posting Date.

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(3; "Posting Date"; Date) { Caption = 'Posting Date'; }
        field(4; "Movement Type"; Enum "KINTO Movement Type") { Caption = 'Movement Type'; }
        field(5; "From Status"; Enum "KINTO Vehicle Status") { Caption = 'From Status'; }
        field(6; "To Status"; Enum "KINTO Vehicle Status") { Caption = 'To Status'; }
        field(7; "Reason Code"; Code[20]) { Caption = 'Reason Code'; }
        field(8; Description; Text[100]) { Caption = 'Description'; }
        field(9; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(10; "Quote No."; Code[20]) { Caption = 'Quote No.'; }
        field(11; "Driver Name"; Text[100]) { Caption = 'Driver Name'; }
        field(12; "License Plate"; Text[20]) { Caption = 'License Plate'; }
        field(13; "VIN"; Text[50]) { Caption = 'VIN'; }
        field(14; "Odometer"; Decimal) { Caption = 'Odometer (km)'; }
        field(15; "Location Code"; Code[20]) { Caption = 'Location'; }
        field(16; "SLA Due Date"; Date) { Caption = 'SLA Due Date'; }
        field(17; "SLA Met"; Boolean) { Caption = 'SLA Met'; }
        field(18; "User ID"; Code[50]) { Caption = 'User ID'; }
        field(19; "Device No."; Code[20])
        {
            Caption = 'Device No.';
            TableRelation = "KINTO Telematic Device";
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Vehicle No.", "Posting Date") { }
        key(Idx2; "Contract No.") { }
        key(Idx3; "Movement Type", "Posting Date") { }
    }

    procedure NextEntryNo(): Integer
    var
        L: Record "KINTO Fleet Movement Ledger";
    begin
        if L.FindLast() then
            exit(L."Entry No." + 1);
        exit(1);
    end;

    procedure LogMovement(VehicleNo: Code[20]; MovementType: Enum "KINTO Movement Type"; FromStatus: Enum "KINTO Vehicle Status"; ToStatus: Enum "KINTO Vehicle Status"; PostingDate: Date; ContractNo: Code[20]; Description: Text)
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        L: Record "KINTO Fleet Movement Ledger";
    begin
        L.Init();
        L."Entry No." := L.NextEntryNo();
        L."Vehicle No." := VehicleNo;
        L."Posting Date" := PostingDate;
        L."Movement Type" := MovementType;
        L."From Status" := FromStatus;
        L."To Status" := ToStatus;
        L."Contract No." := ContractNo;
        L.Description := CopyStr(Description, 1, MaxStrLen(L.Description));
        L."User ID" := CopyStr(UserId, 1, MaxStrLen(L."User ID"));
        if Vehicle.Get(VehicleNo) then begin
            L."License Plate" := Vehicle."License Plate";
            L.VIN := Vehicle.VIN;
            L."Odometer" := Vehicle."Current Odometer";
        end;
        L.Insert(false);
    end;
}
