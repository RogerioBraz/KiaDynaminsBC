page 60000 "KINTO Vendor Labor Rate List"
{
    Caption = 'KINTO Vendor Labor Rates';
    PageType = List;
    SourceTable = "KINTO Vendor Labor Rate";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = true;
    CardPageId = "KINTO Vendor Labor Rate Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Vendor Name"; Rec."Vendor Name") { ApplicationArea = All; }
                field("Service Type"; Rec."Service Type") { ApplicationArea = All; }
                field("Valid From"; Rec."Valid From") { ApplicationArea = All; }
                field("HH Rate"; Rec."HH Rate") { ApplicationArea = All; }
                field("Minimum Hours"; Rec."Minimum Hours") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}
