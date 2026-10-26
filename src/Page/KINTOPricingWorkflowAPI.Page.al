page 50184 "KINTO Pricing Workflow API"
{
    Caption = 'KINTO Pricing Workflow API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'pricingWorkflow';
    EntitySetName = 'pricingWorkflows';
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
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; Editable = false; }
                field(pricingStatus; Rec."Pricing Status") { ApplicationArea = All; Editable = false; }
                field(approvalClassification; Rec."Approval Classification") { ApplicationArea = All; Editable = false; }
                field(calculatedMonthlyFee; Rec."Calculated Monthly Fee") { ApplicationArea = All; Editable = false; }
                field(kintoIRR; Rec."KINTO IRR") { ApplicationArea = All; Editable = false; }
                field(calculatedROI; Rec."Calculated ROI") { ApplicationArea = All; Editable = false; }
                field(ebt; Rec.EBT) { ApplicationArea = All; Editable = false; }
                field(errorMessage; Rec."Error Message") { ApplicationArea = All; Editable = false; }
                field(createdContractNo; Rec."Created Contract No.") { ApplicationArea = All; Editable = false; }

                // Campos-gatilho: PATCH com true executa a ação no OnValidate
                // (padrao de integracao BC — actions de page nao sao invocaveis via REST
                // e o atributo ServiceEnabled nao e aceito em trigger OnAction pelo compilador)
                field(runPricingTrigger; Rec."Run Pricing Trigger")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
                    begin
                        if Rec."Run Pricing Trigger" then begin
                            PricingEngine.RunPricing(Rec);
                            Rec."Run Pricing Trigger" := false;
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(approveTrigger; Rec."Approve Quote Trigger")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        if Rec."Approve Quote Trigger" then begin
                            Rec."Pricing Status" := Rec."Pricing Status"::Approved;
                            Rec."Approve Quote Trigger" := false;
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(createContractTrigger; Rec."Create Contract Trigger")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
                    begin
                        if Rec."Create Contract Trigger" then begin
                            Rec."Created Contract No." := BillingMgt.CreateContractFromQuote(Rec);
                            Rec."Create Contract Trigger" := false;
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(generateBillingTrigger; Rec."Generate Billing Trigger")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        Contract: Record "KINTO Vehicle Contract";
                        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
                    begin
                        if Rec."Generate Billing Trigger" then begin
                            Contract.SetRange("Quote No.", Rec."Quote No.");
                            if Contract.FindFirst() then
                                BillingMgt.GenerateBillingForContract(Contract, CalcDate('<-CM>', WorkDate()));
                            Rec."Generate Billing Trigger" := false;
                            Rec.Modify(true);
                        end;
                    end;
                }
            }
        }
    }
}
