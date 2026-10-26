page 50481 "KINTO Portal Sync Entries"
{
    Caption = 'Portal Sync Entries';
    PageType = List;
    SourceTable = "KINTO Portal Sync Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Event Type"; Rec."Event Type") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Sale No."; Rec."Sale No.") { ApplicationArea = All; }
                field("Sync Status"; Rec."Sync Status") { ApplicationArea = All; StyleExpr = StatusStyle; }
                field("Created DateTime"; Rec."Created DateTime") { ApplicationArea = All; }
                field("Sent DateTime"; Rec."Sent DateTime") { ApplicationArea = All; }
                field("Retry Count"; Rec."Retry Count") { ApplicationArea = All; }
                field("Error Message"; Rec."Error Message") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowPayload)
            {
                Caption = 'Show Payload (JSON)';
                ApplicationArea = All;
                Image = ExportMessage;
                trigger OnAction()
                begin
                    Message(Rec.GetPayload());
                end;
            }
            action(ProcessPending)
            {
                Caption = 'Process Pending Entries';
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                var
                    PortalIntegration: Codeunit "KINTO Portal Integration";
                    Processed: Integer;
                begin
                    Processed := PortalIntegration.ProcessPendingEntries();
                    Message(StrSubstNo('%1 entry(ies) processed.', Processed));
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec."Sync Status" of
            Rec."Sync Status"::Sent:
                StatusStyle := 'Favorable';
            Rec."Sync Status"::Error:
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
