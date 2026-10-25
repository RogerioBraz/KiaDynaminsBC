table 50211 "KINTO Maint Ticket Line"
{
    Caption = 'KINTO Maintenance Ticket Line';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Maintenance Ticket List";
    DrillDownPageId = "KINTO Maintenance Ticket List";

    fields
    {
        field(1; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            TableRelation = "KINTO Maintenance Ticket";
        }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Service Description"; Text[100]) { Caption = 'Service Description'; }
        field(4; "Part Number"; Code[20]) { Caption = 'Part Number'; }
        field(5; Quantity; Decimal) { Caption = 'Quantity'; DecimalPlaces = 0 : 2; InitValue = 1; }
        field(6; "Unit Cost"; Decimal) { Caption = 'Unit Cost (from vendor)'; DecimalPlaces = 2 : 2; }
        field(7; Amount; Decimal) { Caption = 'Amount'; DecimalPlaces = 2 : 2; }
        field(8; "Bill to Customer"; Boolean) { Caption = 'Bill to Customer'; }
        field(9; "Customer Price"; Decimal) { Caption = 'Customer Price'; DecimalPlaces = 2 : 2; }
        field(10; "Covered by Pool"; Boolean) { Caption = 'Covered by Contract Pool'; }
        field(11; "Covered by Warranty"; Boolean) { Caption = 'Covered by Warranty'; }
        field(12; "Standard Price Found"; Boolean) { Caption = 'Standard Price Matched'; Editable = false; }
        field(13; "Price Deviation %"; Decimal)
        {
            Caption = 'Price Deviation % vs Standard';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Ticket No.", "Line No.") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        if Amount = 0 then
            Amount := Round(Quantity * "Unit Cost", 0.01);
    end;

    trigger OnModify()
    begin
        if (Quantity <> 0) and ("Unit Cost" <> 0) then
            Amount := Round(Quantity * "Unit Cost", 0.01);
    end;
}