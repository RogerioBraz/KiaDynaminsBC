page 50462 "KINTO Remark. Pricing Sources"
{
    Caption = 'Remarketing Pricing Sources';
    PageType = List;
    SourceTable = "KINTO Remark. Pricing Source";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Source Type"; Rec."Source Type") { ApplicationArea = All; }
                field("Reference Price"; Rec."Reference Price") { ApplicationArea = All; }
                field("Weight %"; Rec."Weight %") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Last Update"; Rec."Last Update") { ApplicationArea = All; }
            }
        }
    }
}
