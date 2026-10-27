table 60001 "KINTO Telematic Event"
{
    Caption = 'KINTO Telematic Event';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Telematic Event List";
    DrillDownPageId = "KINTO Telematic Event List";

    // D1 — evento recebido da telematica que pode disparar ticket de manutencao.

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle"."Vehicle No.";
        }
        field(3; "Device No."; Code[20])
        {
            Caption = 'Device No.';
            TableRelation = "KINTO Telematic Device"."Device No.";
        }
        field(4; "Event DateTime"; DateTime) { Caption = 'Event DateTime'; }
        field(5; Trigger; Enum "KINTO Telematic Trigger") { Caption = 'Trigger'; }
        field(6; "Fault Code"; Code[20]) { Caption = 'Fault Code'; }
        field(7; "Odometer (km)"; Decimal) { Caption = 'Odometer (km)'; DecimalPlaces = 0 : 1; }
        field(8; "Raw Payload"; Text[2048]) { Caption = 'Raw Payload'; }
        field(9; "Ticket Created"; Boolean) { Caption = 'Ticket Created'; Editable = false; }
        field(10; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            TableRelation = "KINTO Maintenance Ticket"."Ticket No.";
            Editable = false;
        }
        field(11; "Processed DateTime"; DateTime) { Caption = 'Processed DateTime'; Editable = false; }
        field(12; "Process Error"; Text[250]) { Caption = 'Process Error'; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Vehicle No.", "Event DateTime") { }
        key(Idx2; "Ticket Created", Trigger) { }
    }
}
