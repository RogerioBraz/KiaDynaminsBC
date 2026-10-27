page 60009 "KINTO Vehicle Downtime List"
{
    Caption = 'Vehicle Downtime';
    PageType = List;
    SourceTable = "KINTO Vehicle Downtime";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Start DateTime"; Rec."Start DateTime") { ApplicationArea = All; }
                field("End DateTime"; Rec."End DateTime") { ApplicationArea = All; }
                field(Reason; Rec.Reason) { ApplicationArea = All; }
                field("Days Lost"; Rec."Days Lost") { ApplicationArea = All; }
                field("Service Credit Created"; Rec."Service Credit Created") { ApplicationArea = All; }
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateServiceCredits)
            {
                Caption = 'Create Service Credits';
                ApplicationArea = All;
                Image = Process;
                trigger OnAction()
                var
                    DowntimeMgt: Codeunit "KINTO Downtime Mgt.";
                    Count: Integer;
                begin
                    Count := DowntimeMgt.CreateServiceCredits(Today);
                    Message('Créditos de serviço criados: %1', Count);
                end;
            }
        }
    }
}
