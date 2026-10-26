page 50478 "KINTO Claim List"
{
    Caption = 'Claims';
    PageType = List;
    SourceTable = "KINTO Claim";
    SourceTableView = sorting("Claim No.") order(descending);
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Claim";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Claim No."; Rec."Claim No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Claim Class"; Rec."Claim Class") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Loss Ratio %"; Rec."Loss Ratio %") { ApplicationArea = All; }
                field("Total Destruction"; Rec."Total Destruction") { ApplicationArea = All; }
                field("Indemnity Amount"; Rec."Indemnity Amount") { ApplicationArea = All; }
                field("Claim Date"; Rec."Claim Date") { ApplicationArea = All; }
            }
        }
    }
}
