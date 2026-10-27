page 60011 "KINTO Ticket Subtask List"
{
    Caption = 'Ticket Subtasks';
    PageType = List;
    SourceTable = "KINTO Ticket Subtask";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field("Subtask No."; Rec."Subtask No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Assigned To"; Rec."Assigned To") { ApplicationArea = All; }
                field("Due DateTime"; Rec."Due DateTime") { ApplicationArea = All; }
                field("Completed DateTime"; Rec."Completed DateTime") { ApplicationArea = All; }
                field("Depends On Subtask"; Rec."Depends On Subtask") { ApplicationArea = All; }
            }
        }
    }
}
