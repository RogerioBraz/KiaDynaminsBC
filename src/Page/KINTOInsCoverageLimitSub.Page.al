page 50154 "KINTO Ins Coverage Limit Sub"
{
    Caption = 'Coverage Limits';
    PageType = ListPart;
    SourceTable = "KINTO Insurance Coverage Limit";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Limits)
            {
                field("Coverage Category"; Rec."Coverage Category") { ApplicationArea = All; }
                field("Coverage Limit"; Rec."Coverage Limit") { ApplicationArea = All; }
                field("Coverage %"; Rec."Coverage %") { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field("Total Cost"; Rec."Total Cost") { ApplicationArea = All; Editable = false; }
                field("Premium Range"; Rec."Premium Range") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}