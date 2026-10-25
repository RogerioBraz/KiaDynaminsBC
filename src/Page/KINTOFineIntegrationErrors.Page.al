page 50303 "KINTO Fine Integration Errors"
{
    Caption = 'KINTO Fine Integration Errors';
    PageType = List;
    SourceTable = "KINTO Fine Integration Error";
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Provider Code"; Rec."Provider Code") { ApplicationArea = All; }
                field("Batch No."; Rec."Batch No.") { ApplicationArea = All; }
                field("Row Reference"; Rec."Row Reference") { ApplicationArea = All; }
                field("Error Message"; Rec."Error Message") { ApplicationArea = All; }
                field("Error DateTime"; Rec."Error DateTime") { ApplicationArea = All; }
                field(Resolved; Rec.Resolved) { ApplicationArea = All; }
                field("Resolved By"; Rec."Resolved By") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MarkResolved)
            {
                Caption = 'Mark Resolved';
                ApplicationArea = All;
                Image = Done;
                trigger OnAction()
                begin
                    Rec.Resolved := true;
                    Rec."Resolved By" := UserId;
                    Rec.Modify(true);
                end;
            }
        }
    }
}