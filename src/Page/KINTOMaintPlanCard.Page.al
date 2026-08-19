page 50134 "KINTO Maint. Plan Card"
{
    Caption = 'KINTO Maintenance Plan';
    PageType = Card;
    SourceTable = "KINTO Maintenance Plan Header";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Plan ID"; Rec."Plan ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Vehicle Model No."; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Discount %"; Rec."Discount %") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
            part(Lines; "KINTO Maint. Plan Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }
    }
}