page 60006 "KINTO Contract Evaluation Card"
{
    Caption = 'Contract Evaluation';
    PageType = Card;
    SourceTable = "KINTO Contract Evaluation";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Evaluation No."; Rec."Evaluation No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Evaluation Date"; Rec."Evaluation Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
            group(Scores)
            {
                Caption = 'Scores';
                field("Payment Behavior Score"; Rec."Payment Behavior Score") { ApplicationArea = All; }
                field("Vehicle Care Score"; Rec."Vehicle Care Score") { ApplicationArea = All; }
                field("Violations Count"; Rec."Violations Count") { ApplicationArea = All; }
                field("Damages Amount"; Rec."Damages Amount") { ApplicationArea = All; }
                field("Overall Score"; Rec."Overall Score") { ApplicationArea = All; }
                field("Risk Rating"; Rec."Risk Rating") { ApplicationArea = All; }
            }
            group(Decision)
            {
                Caption = 'Decision';
                field("Renewal Recommendation"; Rec."Renewal Recommendation") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; MultiLine = true; }
            }
        }
    }
}
