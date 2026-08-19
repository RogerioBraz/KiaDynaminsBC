page 50111 "KINTO Quote Item Subform"
{
    Caption = 'Quote Items';
    PageType = ListPart;
    SourceTable = "KINTO Quote Item";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Vehicle Condition"; Rec."Vehicle Condition") { ApplicationArea = All; }
                field("Usage Type"; Rec."Usage Type") { ApplicationArea = All; }
                field("Contract Term (Months)"; Rec."Contract Term (Months)") { ApplicationArea = All; }
                field("Monthly Mileage (km)"; Rec."Monthly Mileage (km)") { ApplicationArea = All; }
                field("Payment Allowance (days)"; Rec."Payment Allowance (days)") { ApplicationArea = All; }
                field("Lead Time (days)"; Rec."Lead Time (days)") { ApplicationArea = All; }
                field(MSRP; Rec.MSRP) { ApplicationArea = All; }
                field("Discount Rate %"; Rec."Discount Rate %") { ApplicationArea = All; }
                field("Purchase Price"; Rec."Purchase Price") { ApplicationArea = All; }
                field("Monthly Tariff"; Rec."Monthly Tariff") { ApplicationArea = All; }
                field("Final Resale Price"; Rec."Final Resale Price") { ApplicationArea = All; }
                field("KINTO IRR"; Rec."KINTO IRR") { ApplicationArea = All; }
                field("Calculated ROI"; Rec."Calculated ROI") { ApplicationArea = All; }
                field("Pricing Status"; Rec."Pricing Status") { ApplicationArea = All; }
            }
        }
    }
}