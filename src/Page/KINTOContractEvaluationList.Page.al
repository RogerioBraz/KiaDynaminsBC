page 60005 "KINTO Contract Evaluation List"
{
    Caption = 'Contract Evaluations';
    PageType = List;
    SourceTable = "KINTO Contract Evaluation";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Contract Evaluation Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Evaluation No."; Rec."Evaluation No.") { ApplicationArea = All; }
                field("Evaluation Date"; Rec."Evaluation Date") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Overall Score"; Rec."Overall Score") { ApplicationArea = All; }
                field("Risk Rating"; Rec."Risk Rating") { ApplicationArea = All; }
                field("Renewal Recommendation"; Rec."Renewal Recommendation") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}
