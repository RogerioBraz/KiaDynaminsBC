table 50103 "KINTO Vehicle Odometer History"
{
    Caption = 'KINTO Vehicle Odometer History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; Caption = 'Entry No.'; }
        field(2; "Vehicle No."; Code[20]) { Caption = 'Vehicle No.'; TableRelation = "KINTO Inventory Vehicle"; }
        field(3; "Reading Date"; Date) { Caption = 'Reading Date'; }
        field(4; "Odometer Reading"; Decimal) { Caption = 'Odometer Reading (km)'; }
        field(5; "Source"; Text[50]) { Caption = 'Source'; }
        field(6; "Contract No."; Code[20]) { Caption = 'Contract No.'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Vehicle No.", "Reading Date") { }
    }
}