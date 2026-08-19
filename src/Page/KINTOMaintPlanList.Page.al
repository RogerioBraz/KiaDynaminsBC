page 50133 "KINTO Maint. Plan List"
{
    Caption = 'KINTO Maintenance Plans';
    PageType = List;
    SourceTable = "KINTO Maintenance Plan Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Maint. Plan Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Plan ID"; Rec."Plan ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Vehicle Model No."; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Discount %"; Rec."Discount %") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
        }
    }
}

