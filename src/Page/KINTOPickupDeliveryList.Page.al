page 50158 "KINTO Pickup Delivery List"
{
    Caption = 'KINTO Pick-up and Delivery Packages';
    PageType = List;
    SourceTable = "KINTO Pickup Delivery Package";
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
                field("Coverage Km"; Rec."Coverage Km") { ApplicationArea = All; }
                field("Cost per Excess Km"; Rec."Cost per Excess Km") { ApplicationArea = All; }
                field("Number of Uses"; Rec."Number of Uses") { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}
