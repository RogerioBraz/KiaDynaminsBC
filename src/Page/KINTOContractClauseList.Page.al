page 60003 "KINTO Contract Clause List"
{
    Caption = 'Contract Clauses';
    PageType = List;
    SourceTable = "KINTO Contract Clause";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Clause Code"; Rec."Clause Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Clause Category"; Rec."Clause Category") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Is Mandatory"; Rec."Is Mandatory") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
            }
        }
    }
}
