page 50479 "KINTO Claim Events"
{
    Caption = 'Claim Events (log)';
    PageType = List;
    SourceTable = "KINTO Claim Event";
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
                field("Claim No."; Rec."Claim No.") { ApplicationArea = All; }
                field("Event Date"; Rec."Event Date") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
            }
        }
    }
}
