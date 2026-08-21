page 50162 "KINTO Vendor Category List"
{
    Caption = 'KINTO Vendor Categories';
    PageType = List;
    SourceTable = "KINTO Vendor Category";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec."Category Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Category Type"; Rec."Category Type") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}
