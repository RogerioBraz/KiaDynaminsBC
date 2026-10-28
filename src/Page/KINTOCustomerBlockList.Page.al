page 60314 "KINTO Customer Block List"
{
    Caption = 'KINTO Customer Blocks';
    PageType = List;
    SourceTable = "KINTO Customer Block";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Block Date"; Rec."Block Date") { ApplicationArea = All; }
                field("Block Reason"; Rec."Block Reason") { ApplicationArea = All; }
                field("Reason Text"; Rec."Reason Text") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Released Date"; Rec."Released Date") { ApplicationArea = All; }
                field("Released By"; Rec."Released By") { ApplicationArea = All; }
                field("Blocked By"; Rec."Blocked By") { ApplicationArea = All; }
            }
        }
    }
}
