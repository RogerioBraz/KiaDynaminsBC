page 50202 "KINTO Contract Condition List"
{
    Caption = 'KINTO Contract Conditions';
    PageType = List;
    SourceTable = "KINTO Contract Condition";
    UsageCategory = Lists;
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Condition ID"; Rec."Condition ID") { ApplicationArea = All; Editable = false; }
                field("Revision No."; Rec."Revision No.") { ApplicationArea = All; }
                field("Financial Product Code"; Rec."Financial Product Code") { ApplicationArea = All; }
                field("Product Type"; Rec."Product Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Monthly Amount"; Rec."Monthly Amount") { ApplicationArea = All; }
                field("Daily Amount"; Rec."Daily Amount") { ApplicationArea = All; }
                field("Valid From"; Rec."Valid From") { ApplicationArea = All; }
                field("Valid To"; Rec."Valid To") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Price Index Code"; Rec."Price Index Code") { ApplicationArea = All; }
            }
        }
    }
}