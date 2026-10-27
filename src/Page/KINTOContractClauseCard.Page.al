page 60004 "KINTO Contract Clause Card"
{
    Caption = 'Contract Clause';
    PageType = Card;
    SourceTable = "KINTO Contract Clause";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Clause Code"; Rec."Clause Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Clause Category"; Rec."Clause Category") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Is Mandatory"; Rec."Is Mandatory") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
            }
            group(Text)
            {
                Caption = 'Clause Text';
                field("Clause Text"; Rec."Clause Text") { ApplicationArea = All; MultiLine = true; }
            }
        }
    }
}
