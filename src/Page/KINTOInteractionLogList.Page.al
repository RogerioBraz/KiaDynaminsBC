page 60312 "KINTO Interaction Log List"
{
    Caption = 'KINTO Interaction Log';
    PageType = List;
    SourceTable = "KINTO Interaction Log";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Interaction Date"; Rec."Interaction Date") { ApplicationArea = All; }
                field("Interaction Type"; Rec."Interaction Type") { ApplicationArea = All; }
                field("Subject"; Rec."Subject") { ApplicationArea = All; }
                field("Contact Name"; Rec."Contact Name") { ApplicationArea = All; }
                field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; }
                field("Next Step"; Rec."Next Step") { ApplicationArea = All; }
                field("Next Step Date"; Rec."Next Step Date") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
            }
        }
    }
}
