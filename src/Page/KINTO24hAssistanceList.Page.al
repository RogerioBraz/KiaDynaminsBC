page 50157 "KINTO 24h Assistance List"
{
    Caption = 'KINTO 24h Assistance Packages';
    PageType = List;
    SourceTable = "KINTO 24h Assistance Package";
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
                field("Number of Uses"; Rec."Number of Uses") { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field("Enable Pool"; Rec."Enable Pool") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}
