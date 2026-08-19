page 50123 "KINTO Quote Items API"
{
    Caption = 'KINTO Quote Items API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'quoteItem';
    EntitySetName = 'quoteItems';
    SourceTable = "KINTO Quote Item";
    DelayedInsert = true;
    ODataKeyFields = "Quote No.", "Line No.";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; }
                field(lineNo; Rec."Line No.") { ApplicationArea = All; }
                field(itemNo; Rec."Item No.") { ApplicationArea = All; }
                field(description; Rec.Description) { ApplicationArea = All; }
                field(vehicleModelNo; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field(vehicleVariant; Rec."Vehicle Variant") { ApplicationArea = All; }
                field(usageType; Rec."Usage Type") { ApplicationArea = All; }
                field(vehicleCondition; Rec."Vehicle Condition") { ApplicationArea = All; }
                field(inventoryVehicleNo; Rec."Inventory Vehicle No.") { ApplicationArea = All; }
                field(contractTerm; Rec."Contract Term (Months)") { ApplicationArea = All; }
                field(monthlyMileage; Rec."Monthly Mileage (km)") { ApplicationArea = All; }
                field(paymentAllowance; Rec."Payment Allowance (days)") { ApplicationArea = All; }
                field(leadTime; Rec."Lead Time (days)") { ApplicationArea = All; }
                field(targetROI; Rec."Target ROI %") { ApplicationArea = All; }
                field(msrp; Rec.MSRP) { ApplicationArea = All; }
                field(discountRate; Rec."Discount Rate %") { ApplicationArea = All; }
                field(purchasePrice; Rec."Purchase Price") { ApplicationArea = All; Editable = false; }
                field(monthlyTariff; Rec."Monthly Tariff") { ApplicationArea = All; Editable = false; }
                field(finalResalePrice; Rec."Final Resale Price") { ApplicationArea = All; Editable = false; }
                field(kintoIRR; Rec."KINTO IRR") { ApplicationArea = All; Editable = false; }
                field(calculatedROI; Rec."Calculated ROI") { ApplicationArea = All; Editable = false; }
                field(ebt; Rec.EBT) { ApplicationArea = All; Editable = false; }
                field(pat; Rec.PAT) { ApplicationArea = All; Editable = false; }
                field(kintoFCF; Rec."KINTO FCF") { ApplicationArea = All; Editable = false; }
                field(pricingStatus; Rec."Pricing Status") { ApplicationArea = All; Editable = false; }
                field(errorMessage; Rec."Error Message") { ApplicationArea = All; Editable = false; }
            }
        }
    }
}