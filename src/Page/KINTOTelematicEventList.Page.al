page 60001 "KINTO Telematic Event List"
{
    Caption = 'KINTO Telematic Events';
    PageType = List;
    SourceTable = "KINTO Telematic Event";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Event DateTime"; Rec."Event DateTime") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Device No."; Rec."Device No.") { ApplicationArea = All; }
                field(Trigger; Rec.Trigger) { ApplicationArea = All; }
                field("Fault Code"; Rec."Fault Code") { ApplicationArea = All; }
                field("Odometer (km)"; Rec."Odometer (km)") { ApplicationArea = All; }
                field("Ticket Created"; Rec."Ticket Created") { ApplicationArea = All; }
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field("Processed DateTime"; Rec."Processed DateTime") { ApplicationArea = All; }
                field("Process Error"; Rec."Process Error") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessEvents)
            {
                Caption = 'Process Events (create tickets)';
                ApplicationArea = All;
                Image = Process;
                trigger OnAction()
                var
                    MaintMgr: Codeunit "KINTO Preventive Maint. Mgt.";
                    Count: Integer;
                begin
                    Count := MaintMgr.ProcessTelematicEvents(Today);
                    Message('Eventos processados: %1', Count);
                end;
            }
        }
    }
}
