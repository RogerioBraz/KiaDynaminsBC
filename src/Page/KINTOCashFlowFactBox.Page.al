page 50112 "KINTO Cash Flow FactBox"
{
    Caption = 'Cash Flow Summary';
    PageType = ListPart;
    SourceTable = "KINTO Cash Flow Data";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Month No."; Rec."Month No.") { ApplicationArea = All; }
                field("Month Date"; Rec."Month Date") { ApplicationArea = All; }
                field("Component ID"; Rec."Component ID") { ApplicationArea = All; }
                field("Component Description"; Rec."Component Description") { ApplicationArea = All; }
                field("Signed Amount"; Rec."Signed Amount") { ApplicationArea = All; }
                field("Accumulated Mileage"; Rec."Accumulated Mileage") { ApplicationArea = All; }
            }
        }
    }
}