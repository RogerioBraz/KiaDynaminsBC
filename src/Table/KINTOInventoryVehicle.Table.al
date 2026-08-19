table 50102 "KINTO Inventory Vehicle"
{
    Caption = 'KINTO Inventory Vehicle';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Vehicle No."; Code[20]) { Caption = 'Vehicle No.'; }
        field(2; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item; }
        field(3; "License Plate"; Text[20]) { Caption = 'License Plate'; }
        field(4; "VIN"; Text[50]) { Caption = 'VIN'; }
        field(5; "Vehicle Model No."; Code[20]) { Caption = 'Vehicle Model'; TableRelation = "KINTO Vehicle Model"; }
        field(6; "Vehicle Condition"; Enum "KINTO Vehicle Condition") { Caption = 'Condition'; }
        field(7; "Current Odometer"; Decimal) { Caption = 'Current Odometer (km)'; }
        field(8; "Age in Months"; Integer) { Caption = 'Age in Months'; }
        field(9; "Fixed Asset No."; Code[20]) { Caption = 'Fixed Asset No.'; TableRelation = "Fixed Asset"; }
        field(10; "Status"; Enum "KINTO Vehicle Status") { Caption = 'Status'; }
        field(11; "Soft Reserved by Quote"; Code[20]) { Caption = 'Soft Reserved by Quote'; TableRelation = "KINTO Quote Header"; }
        field(12; "Reservation Date"; Date) { Caption = 'Reservation Date'; }
        field(13; "Booking Value"; Decimal) { Caption = 'Current Booking Value'; }
        field(14; "Frozen Booking Value"; Decimal) { Caption = 'Frozen Booking Value'; }
        field(15; "Last Contract No."; Code[20]) { Caption = 'Last Contract No.'; }
        field(16; "Color Code"; Code[10]) { Caption = 'Color Code'; }
        field(17; "Acquisition Date"; Date) { Caption = 'Acquisition Date'; }
        field(18; "Acquisition Cost"; Decimal) { Caption = 'Acquisition Cost'; }
    }

    keys
    {
        key(PK; "Vehicle No.") { Clustered = true; }
        key(Idx1; "License Plate") { }
        key(Idx2; "Item No.") { }
        key(Idx3; "Status", "Soft Reserved by Quote") { }
    }

    trigger OnInsert()
    begin
        if "Vehicle Condition" = "Vehicle Condition"::New then
            "Status" := "Status"::Available;
    end;
}
