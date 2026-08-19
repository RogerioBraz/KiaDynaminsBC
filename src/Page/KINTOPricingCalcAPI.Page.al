page 50120 "KINTO Pricing Calc API"
{
    Caption = 'KINTO Pricing Calculation API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'pricingCalculation';
    EntitySetName = 'pricingCalculations';
    SourceTable = "KINTO Quote Header";
    DelayedInsert = true;
    ODataKeyFields = "Quote No.";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; }
                field(customerNo; Rec."Customer No.") { ApplicationArea = All; }
                field(customerName; Rec."Customer Name") { ApplicationArea = All; Editable = false; }
                field(dealerNo; Rec."Dealer No.") { ApplicationArea = All; }
                field(countryCode; Rec."Country Code") { ApplicationArea = All; }
                field(currencyCode; Rec."Currency Code") { ApplicationArea = All; }
                field(pricingStatus; Rec."Pricing Status") { ApplicationArea = All; Editable = false; }
                field(pricingMethodology; Rec."Pricing Methodology") { ApplicationArea = All; }
                field(targetROI; Rec."Target ROI %") { ApplicationArea = All; }
                field(negotiatedMonthlyPrice; Rec."Negotiated Monthly Price") { ApplicationArea = All; }
                field(calculatedMonthlyFee; Rec."Calculated Monthly Fee") { ApplicationArea = All; Editable = false; }
                field(approvalClassification; Rec."Approval Classification") { ApplicationArea = All; Editable = false; }
                field(totalMSRP; Rec."Total MSRP") { ApplicationArea = All; Editable = false; }
                field(totalPurchasePrice; Rec."Total Purchase Price") { ApplicationArea = All; Editable = false; }
                field(totalMonthlyFee; Rec."Total Monthly Fee") { ApplicationArea = All; Editable = false; }
                field(kintoIRR; Rec."KINTO IRR") { ApplicationArea = All; Editable = false; }
                field(referenceIRR; Rec."Reference IRR") { ApplicationArea = All; Editable = false; }
                field(calculatedROI; Rec."Calculated ROI") { ApplicationArea = All; Editable = false; }
                field(ebt; Rec."EBT") { ApplicationArea = All; Editable = false; }
                field(pat; Rec."PAT") { ApplicationArea = All; Editable = false; }
                field(kintoFCF; Rec."KINTO FCF") { ApplicationArea = All; Editable = false; }
                field(paymentAllowanceDays; Rec."Payment Allowance Days") { ApplicationArea = All; }
                field(extendedAnalysisMonths; Rec."Extended Analysis Months") { ApplicationArea = All; Editable = false; }
                field(creditScore; Rec."Credit Score") { ApplicationArea = All; }
                field(creditRiskFactor; Rec."Credit Risk Factor %") { ApplicationArea = All; }
                field(expirationDate; Rec."Expiration Date") { ApplicationArea = All; Editable = false; }
                field(errorMessage; Rec."Error Message") { ApplicationArea = All; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunPricing)
            {
                Caption = 'Run Pricing Calculation';
                ApplicationArea = All;
                trigger OnAction()
                var
                    PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
                begin
                    PricingEngine.RunPricing(Rec);
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.InitFromCountrySetup();
    end;
}