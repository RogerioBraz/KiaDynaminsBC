page 60002 "KINTO Vendor Labor Rate Card"
{
    Caption = 'Labor Rate';
    PageType = Card;
    SourceTable = "KINTO Vendor Labor Rate";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Vendor Name"; Rec."Vendor Name") { ApplicationArea = All; }
                field("Service Type"; Rec."Service Type") { ApplicationArea = All; }
                field("Valid From"; Rec."Valid From") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
            group(Rate)
            {
                Caption = 'Rate';
                field("HH Rate"; Rec."HH Rate") { ApplicationArea = All; }
                field("Minimum Hours"; Rec."Minimum Hours") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}
