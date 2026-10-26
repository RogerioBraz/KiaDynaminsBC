table 50445 "KINTO Fleet Closing Snapshot"
{
    Caption = 'KINTO Fleet Closing Snapshot';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Fleet Closing Snap List";
    DrillDownPageId = "KINTO Fleet Closing Snap List";
    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Closing Month"; Date) { Caption = 'Closing Month'; }
        field(3; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(4; "License Plate"; Text[20]) { Caption = 'License Plate'; }
        field(5; VIN; Text[50]) { Caption = 'VIN'; }
        field(6; "Vehicle Status"; Enum "KINTO Vehicle Status") { Caption = 'Vehicle Status'; }
        field(7; "Contract No."; Code[20]) { Caption = 'Contract No.'; }
        field(8; "Customer No."; Code[20]) { Caption = 'Customer No.'; }
        field(9; "Odometer"; Decimal) { Caption = 'Odometer (km)'; }
        field(10; "Device No."; Code[20]) { Caption = 'Device No.'; }
        field(11; "Device Status"; Enum "KINTO Device Status") { Caption = 'Device Status'; }
        field(12; "Active Policy No."; Code[20]) { Caption = 'Active Policy No.'; }
        field(13; "Monthly Billing Amount"; Decimal) { Caption = 'Monthly Billing Amount'; }
        field(14; "Reconciled"; Boolean) { Caption = 'Reconciled'; }
        field(15; "Reconcile Issue"; Text[250]) { Caption = 'Reconcile Issue'; }
        field(16; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(17; "Snapshot DateTime"; DateTime) { Caption = 'Snapshot DateTime'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Closing Month", "Vehicle No.") { }
    }

    procedure NextEntryNo(): Integer
    var
        S: Record "KINTO Fleet Closing Snapshot";
    begin
        if S.FindLast() then
            exit(S."Entry No." + 1);
        exit(1);
    end;
}
