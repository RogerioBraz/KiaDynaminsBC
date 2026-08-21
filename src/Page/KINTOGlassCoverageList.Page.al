page 50155 "KINTO Glass Coverage List"
{
    Caption = 'KINTO Glass Coverage Packages';
    PageType = List;
    SourceTable = "KINTO Glass Coverage Package";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Glass Coverage Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Package ID"; Rec."Package ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Deductible"; Rec."Deductible") { ApplicationArea = All; }
                field("Coverage Limit"; Rec."Coverage Limit") { ApplicationArea = All; }
                field("Balance Uses"; Rec."Balance Uses") { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field(Armoring; Rec.Armoring) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}