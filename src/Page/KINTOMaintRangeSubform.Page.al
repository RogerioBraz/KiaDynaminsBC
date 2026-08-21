page 50151 "KINTO Maint Range Subform"
{
    Caption = 'Maintenance Ranges';
    PageType = ListPart;
    SourceTable = "KINTO Maintenance Range";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Ranges)
            {
                field("Range No."; Rec."Range No.") { ApplicationArea = All; }
                field("Mileage Threshold"; Rec."Mileage Threshold") { ApplicationArea = All; }
                field("Age Threshold (Months)"; Rec."Age Threshold (Months)") { ApplicationArea = All; }
                field("Refresh Basis"; Rec."Refresh Basis") { ApplicationArea = All; }
                field("Range Description"; Rec."Range Description") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}