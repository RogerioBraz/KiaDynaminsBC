page 50122 "KINTO Pricing Validation API"
{
    Caption = 'KINTO Pricing Validation API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'pricingValidation';
    EntitySetName = 'pricingValidations';
    SourceTable = "KINTO Quote Header";
    ODataKeyFields = "Quote No.";
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; }
                field(valid; Rec."Pricing Status") { ApplicationArea = All; }
                field(status; Rec."Pricing Status") { ApplicationArea = All; }
                field(expirationDate; Rec."Expiration Date") { ApplicationArea = All; }
                field(monthlyFee; Rec."Calculated Monthly Fee") { ApplicationArea = All; }
                field(currencyCode; Rec."Currency Code") { ApplicationArea = All; }
                field(approvalClassification; Rec."Approval Classification") { ApplicationArea = All; }
                field(countryCode; Rec."Country Code") { ApplicationArea = All; }
                field(customerNo; Rec."Customer No.") { ApplicationArea = All; }
                field(kintoIRR; Rec."KINTO IRR") { ApplicationArea = All; }
                field(calculatedROI; Rec."Calculated ROI") { ApplicationArea = All; }
            }
        }
    }
}