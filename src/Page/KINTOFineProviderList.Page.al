page 50304 "KINTO Fine Provider List"
{
    Caption = 'KINTO Fine Providers';
    PageType = List;
    SourceTable = "KINTO Fine Provider";
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
                field("Integration Type"; Rec."Integration Type") { ApplicationArea = All; }
                field("Endpoint URL"; Rec."Endpoint URL") { ApplicationArea = All; }
                field("Default Fee Product"; Rec."Default Fee Product") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}