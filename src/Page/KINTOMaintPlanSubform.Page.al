page 50135 "KINTO Maint. Plan Subform"
{
    Caption = 'Maintenance Plan Lines';
    PageType = ListPart;
    SourceTable = "KINTO Maintenance Plan Line";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Plan ID"; Rec."Plan ID") { ApplicationArea = All; Visible = false; }
                field("KM Interval"; Rec."KM Interval") { ApplicationArea = All; }
                field("Maintenance Cost"; Rec."Maintenance Cost") { ApplicationArea = All; }
                field("Labor Cost"; Rec."Labor Cost") { ApplicationArea = All; }
                field("Parts Cost"; Rec."Parts Cost") { ApplicationArea = All; }
                field("Discounted Cost"; Rec."Discounted Cost") { ApplicationArea = All; }
            }
        }
    }
}