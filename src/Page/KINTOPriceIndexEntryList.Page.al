page 50207 "KINTO Price Index Entry List"
{
    Caption = 'KINTO Price Index Entries';
    PageType = List;
    SourceTable = "KINTO Price Index Entry";
    UsageCategory = Lists;
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Index Code"; Rec."Index Code") { ApplicationArea = All; }
                field("Valid From"; Rec."Valid From") { ApplicationArea = All; }
                field("Index Value"; Rec."Index Value") { ApplicationArea = All; }
                field("Variation %"; Rec."Variation %") { ApplicationArea = All; }
            }
        }
    }
}