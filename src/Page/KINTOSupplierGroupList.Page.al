page 50164 "KINTO Supplier Group List"
{
    Caption = 'KINTO Supplier Groups';
    PageType = List;
    SourceTable = "KINTO Supplier Group";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Group Code"; Rec."Group Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Category Type"; Rec."Category Type") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}
