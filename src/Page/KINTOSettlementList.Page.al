page 50474 "KINTO Settlement List"
{
    Caption = 'Settlements';
    PageType = List;
    SourceTable = "KINTO Settlement";
    SourceTableView = sorting("Settlement No.") order(descending);
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Settlement";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Settlement No."; Rec."Settlement No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Settlement Type"; Rec."Settlement Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Total Amount"; Rec."Total Amount") { ApplicationArea = All; }
                field("Settlement Date"; Rec."Settlement Date") { ApplicationArea = All; }
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; }
            }
        }
    }
}
