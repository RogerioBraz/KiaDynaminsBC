page 50161 "KINTO Service Package List"
{
    Caption = 'KINTO Service Packages';
    PageType = List;
    SourceTable = "KINTO Service Package";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Package ID"; Rec."Package ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field("Billing Frequency"; Rec."Billing Frequency") { ApplicationArea = All; }
                field("Related Accessory No."; Rec."Related Accessory No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}