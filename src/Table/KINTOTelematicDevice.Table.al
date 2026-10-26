table 50442 "KINTO Telematic Device"
{
    Caption = 'KINTO Telematic Device';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Telematic Device List";
    DrillDownPageId = "KINTO Telematic Device List";

    fields
    {
        field(1; "Device No."; Code[20]) { Caption = 'Device No.'; }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; Description; Text[100]) { Caption = 'Description'; }
        field(4; "Serial Number"; Text[50]) { Caption = 'Serial Number'; }
        field(5; "IMEI"; Text[20]) { Caption = 'IMEI'; }
        field(6; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(7; "Device Model"; Text[50]) { Caption = 'Device Model'; }
        field(8; Status; Enum "KINTO Device Status") { Caption = 'Status'; }
        field(9; "Installed Vehicle No."; Code[20])
        {
            Caption = 'Installed Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(10; "Install Date"; Date) { Caption = 'Install Date'; }
        field(11; "Removal Date"; Date) { Caption = 'Removal Date'; }
        field(12; "Install Count"; Integer) { Caption = 'Install Count (reuse)'; }
        field(13; "Aging Days"; Integer) { Caption = 'Aging (days)'; Editable = false; }
        field(14; "Aging Charge Vendor"; Boolean) { Caption = 'Aging charge to vendor'; Editable = false; }
        field(15; "Paid Plan Code"; Code[20]) { Caption = 'Paid Plan Code'; }
        field(16; "Paid Plan Monthly Fee"; Decimal) { Caption = 'Paid Plan Monthly Fee'; }
        field(17; "Last Communication"; DateTime) { Caption = 'Last Communication'; }
        field(18; "Country Code"; Code[10]) { Caption = 'Country Code'; }
    }

    keys
    {
        key(PK; "Device No.") { Clustered = true; }
        key(Idx1; Status) { }
        key(Idx2; "Installed Vehicle No.") { }
        key(Idx3; "Vendor No.") { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "Device No." = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-DEV';
            "Device No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    procedure UpdateAging(ChargeThresholdDays: Integer)
    begin
        if Status <> Status::"In Stock" then begin
            "Aging Days" := 0;
            "Aging Charge Vendor" := false;
            exit;
        end;
        if "Removal Date" <> 0D then
            "Aging Days" := WorkDate() - "Removal Date"
        else
            "Aging Days" := 0;
        "Aging Charge Vendor" := "Aging Days" > ChargeThresholdDays;
    end;
}
