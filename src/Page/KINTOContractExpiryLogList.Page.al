page 60007 "KINTO Contract Expiry Log List"
{
    Caption = 'Contract Expiry Log';
    PageType = List;
    SourceTable = "KINTO Contract Expiry Log";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Action Date"; Rec."Action Date") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Action Type"; Rec."Action Type") { ApplicationArea = All; }
                field("Days to Expiry"; Rec."Days to Expiry") { ApplicationArea = All; }
                field("Log Message"; Rec."Log Message") { ApplicationArea = All; }
            }
        }
    }
}
