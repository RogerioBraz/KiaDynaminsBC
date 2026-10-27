table 60007 "KINTO Vehicle Downtime"
{
    Caption = 'KINTO Vehicle Downtime';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Vehicle Downtime List";
    DrillDownPageId = "KINTO Vehicle Downtime List";

    // D3 — indisponibilidade do veiculo (base para service credit e SLA).

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle"."Vehicle No.";
        }
        field(3; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract"."Contract No.";
        }
        field(4; "Start DateTime"; DateTime) { Caption = 'Start DateTime'; }
        field(5; "End DateTime"; DateTime) { Caption = 'End DateTime'; }
        field(6; Reason; Enum "KINTO Downtime Reason") { Caption = 'Reason'; }
        field(7; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            TableRelation = "KINTO Maintenance Ticket"."Ticket No.";
        }
        field(8; "Days Lost"; Decimal) { Caption = 'Days Lost'; DecimalPlaces = 0 : 2; Editable = false; }
        field(9; "Chargeable to KINTO"; Boolean) { Caption = 'Chargeable to KINTO'; InitValue = true; }
        field(10; "Service Credit Created"; Boolean) { Caption = 'Service Credit Created'; Editable = false; }
        field(11; Notes; Text[250]) { Caption = 'Notes'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Vehicle No.", "Start DateTime") { }
        key(Idx2; "Contract No.", "Service Credit Created") { }
    }

    trigger OnInsert()
    begin
        CalcDays();
    end;

    trigger OnModify()
    begin
        CalcDays();
    end;

    procedure CalcDays()
    begin
        if (Rec."Start DateTime" <> 0DT) and (Rec."End DateTime" <> 0DT) then
            Rec."Days Lost" := Round((Rec."End DateTime" - Rec."Start DateTime") / 86400, 0.01)
        else
            Rec."Days Lost" := 0;
    end;

    procedure RegisterDowntime(VehicleNo: Code[20]; ContractNo: Code[20]; StartDT: DateTime; EndDT: DateTime; Reason: Enum "KINTO Downtime Reason"; TicketNo: Code[20]): Integer
    begin
        Init();
        Rec."Vehicle No." := VehicleNo;
        Rec."Contract No." := ContractNo;
        Rec."Start DateTime" := StartDT;
        Rec."End DateTime" := EndDT;
        Rec.Reason := Reason;
        Rec."Ticket No." := TicketNo;
        Insert(true);
        exit(Rec."Entry No.");
    end;
}
