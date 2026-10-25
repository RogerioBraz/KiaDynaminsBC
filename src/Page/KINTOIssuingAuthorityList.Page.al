page 50302 "KINTO Issuing Authority List"
{
    Caption = 'KINTO Issuing Authorities';
    PageType = List;
    SourceTable = "KINTO Issuing Authority";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field(Jurisdiction; Rec.Jurisdiction) { ApplicationArea = All; }
                field("SNE Adjustment %"; Rec."SNE Adjustment %") { ApplicationArea = All; }
                field("Grace Period Days"; Rec."Grace Period Days") { ApplicationArea = All; }
                field("Accepts Appeal"; Rec."Accepts Appeal") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}