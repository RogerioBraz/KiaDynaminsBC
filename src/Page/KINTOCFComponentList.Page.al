page 50116 "KINTO CF Component List"
{
    Caption = 'Cash Flow Components';
    PageType = List;
    SourceTable = "KINTO CF Component";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Component ID"; Rec."Component ID") { ApplicationArea = All; }
                field("Description"; Rec."Description") { ApplicationArea = All; }
                field("Component Type"; Rec."Component Type") { ApplicationArea = All; }
                field("Calculation Method"; Rec."Calculation Method") { ApplicationArea = All; }
                field("Value Definition"; Rec."Value Definition") { ApplicationArea = All; }
                field("Base Reference"; Rec."Base Reference") { ApplicationArea = All; }
                field("Sign"; Rec."Sign") { ApplicationArea = All; }
                field("Frequency"; Rec."Frequency") { ApplicationArea = All; }
                field("Calculate in Month Zero"; Rec."Calculate in Month Zero") { ApplicationArea = All; }
                field("Indexation Applied"; Rec."Indexation Applied") { ApplicationArea = All; }
                field("Indexation Frequency"; Rec."Indexation Frequency") { ApplicationArea = All; }
                field("Extended Calculation"; Rec."Extended Calculation") { ApplicationArea = All; }
                field("Visible in Reports"; Rec."Visible in Reports") { ApplicationArea = All; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
            }
        }
    }
}