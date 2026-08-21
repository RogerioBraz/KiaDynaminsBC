page 50159 "KINTO Repl Vehicle List"
{
    Caption = 'KINTO Replacement Vehicle Packages';
    PageType = List;
    SourceTable = "KINTO Replacement Vehicle Pkg";
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
                field("Category Code"; Rec."Category Code") { ApplicationArea = All; }
                field("Category Description"; Rec."Category Description") { ApplicationArea = All; }
                field("Default Uses"; Rec."Default Uses") { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}
