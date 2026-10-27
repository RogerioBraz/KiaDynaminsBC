table 60001 "KINTO Telematic Event"
{
    Caption = 'KINTO Telematic Event';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Telematic Event List";
    DrillDownPageId = "KINTO Telematic Event List";

    // D1 — evento recebido da telematica que pode disparar ticket de manutencao.

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
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
        field(5; "Event Trigger"; Enum "KINTO Telematic Trigger") { Caption = 'Event Trigger'; }
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
        key(Idx2; "Ticket Created", "Event Trigger") { }
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            AssignEntryNo();
    end;

    procedure GetNextEntryNo(): Integer
    var
        Rec2: Record "KINTO Telematic Event";
    begin
        Rec2.Reset();
        Rec2.SetCurrentKey("Entry No.");
        if Rec2.FindLast() then
            exit(Rec2."Entry No." + 1);
        exit(1);
    end;

    // Atribui Entry No. unico. Usa MAX+1 e, se colidir (historico deixado por
    // execucao abortada), avanca ate achar um livre. AutoIncrement NAO serve aqui:
    // o rollback do harness de teste reinicia a sequencia e o Insert seguinte
    // repete o numero ("Ja existe o registro ... Entry No.='N'").
    local procedure AssignEntryNo()
    var
        Rec2: Record "KINTO Telematic Event";
        NextNo: Integer;
    begin
        Rec2.Reset();
        Rec2.SetCurrentKey("Entry No.");
        if Rec2.FindLast() then
            NextNo := Rec2."Entry No." + 1
        else
            NextNo := 1;
        while Rec2.Get(NextNo) do
            NextNo += 1;
        "Entry No." := NextNo;
    end;
}
