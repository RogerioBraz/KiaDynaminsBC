page 50209 "KINTO Pool Types"
{
    Caption = 'KINTO Pool Types';
    PageType = List;
    SourceTable = "KINTO Pool Type";
    UsageCategory = Lists;
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Unit of Measure"; Rec."Unit of Measure") { ApplicationArea = All; }
                field("Shared Across Vehicles"; Rec."Shared Across Vehicles") { ApplicationArea = All; }
                field(Monetary; Rec.Monetary) { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}