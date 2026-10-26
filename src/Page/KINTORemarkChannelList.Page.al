page 50458 "KINTO Remarketing Channel List"
{
    Caption = 'Remarketing Channels';
    PageType = List;
    SourceTable = "KINTO Remarketing Channel";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Step No."; Rec."Step No.") { ApplicationArea = All; }
                field("Channel Type"; Rec."Channel Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Duration Days"; Rec."Duration Days") { ApplicationArea = All; }
                field("Price Adj. %"; Rec."Price Adj. %") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}
