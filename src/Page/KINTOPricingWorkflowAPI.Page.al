page 50184 "KINTO Pricing Workflow API"
{
    Caption = 'KINTO Pricing Workflow API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'pricingWorkflow';
    EntitySetName = 'pricingWorkflows';
    SourceTable = "KINTO Workflow Command";
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
                field(pricingStatus; Rec."Pricing Status") { ApplicationArea = All; Editable = false; }
                field(approvalClassification; Rec."Approval Classification") { ApplicationArea = All; Editable = false; }
                field(calculatedMonthlyFee; Rec."Calculated Monthly Fee") { ApplicationArea = All; Editable = false; }
                field(kintoIRR; Rec."KINTO IRR") { ApplicationArea = All; Editable = false; }
                field(calculatedROI; Rec."Calculated ROI") { ApplicationArea = All; Editable = false; }
                field(ebt; Rec.EBT) { ApplicationArea = All; Editable = false; }
                field(createdContractNo; Rec."Created Contract No.") { ApplicationArea = All; Editable = false; }
                field(resultMessage; Rec."Result Message") { ApplicationArea = All; Editable = false; }
                field(lastRunDateTime; Rec."Last Run DateTime") { ApplicationArea = All; Editable = false; }

                // Comandos: PATCH com true executa a acao (OnValidate na command table —
                // o modify implicito da platform nunca toca o Quote Header)
                field(runPricingTrigger; Rec."Run Pricing Trigger") { ApplicationArea = All; }
                field(approveTrigger; Rec."Approve Quote Trigger") { ApplicationArea = All; }
                field(createContractTrigger; Rec."Create Contract Trigger") { ApplicationArea = All; }
                field(generateBillingTrigger; Rec."Generate Billing Trigger") { ApplicationArea = All; }
            }
        }
    }
}
