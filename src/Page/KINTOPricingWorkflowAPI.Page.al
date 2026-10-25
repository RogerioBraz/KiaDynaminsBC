page 50122 "KINTO Pricing Workflow API"
{
    Caption = 'KINTO Pricing Workflow API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'pricingWorkflow';
    EntitySetName = 'pricingWorkflows';
    SourceTable = "KINTO Quote Header";
    DelayedInsert = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = "Quote No.";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; }
                field(pricingStatus; Rec."Pricing Status") { ApplicationArea = All; }
                field(approvalClassification; Rec."Approval Classification") { ApplicationArea = All; }
                field(calculatedMonthlyFee; Rec."Calculated Monthly Fee") { ApplicationArea = All; }
                field(kintoIRR; Rec."KINTO IRR") { ApplicationArea = All; }
                field(calculatedROI; Rec."Calculated ROI") { ApplicationArea = All; }
                field(ebt; Rec.EBT) { ApplicationArea = All; }
                field(errorMessage; Rec."Error Message") { ApplicationArea = All; }
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
                [ServiceEnabled]
                [Scope('Cloud')]
                trigger OnAction()
                var
                    PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
                begin
                    PricingEngine.RunPricing(Rec);
                    Modify();
                end;
            }
            action(Approve)
            {
                Caption = 'Approve Quote';
                ApplicationArea = All;
                [ServiceEnabled]
                [Scope('Cloud')]
                trigger OnAction()
                var
                    QuoteHeader: Record "KINTO Quote Header";
                begin
                    QuoteHeader.Get(Rec."Quote No.");
                    QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::Approved;
                    QuoteHeader.Modify(true);
                end;
            }
            action(CreateContract)
            {
                Caption = 'Create Contract from Quote';
                ApplicationArea = All;
                [ServiceEnabled]
                [Scope('Cloud')]
                trigger OnAction() ContractNo: Code[20]
                var
                    QuoteHeader: Record "KINTO Quote Header";
                    BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
                begin
                    QuoteHeader.Get(Rec."Quote No.");
                    ContractNo := BillingMgt.CreateContractFromQuote(QuoteHeader);
                end;
            }
            action(GenerateBilling)
            {
                Caption = 'Generate Monthly Billing';
                ApplicationArea = All;
                [ServiceEnabled]
                [Scope('Cloud')]
                trigger OnAction()
                var
                    Contract: Record "KINTO Vehicle Contract";
                    BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
                begin
                    Contract.SetRange("Quote No.", Rec."Quote No.");
                    if Contract.FindFirst() then
                        BillingMgt.GenerateBillingForContract(Contract, CalcDate('<-CM>', WorkDate()));
                end;
            }
        }
    }
}