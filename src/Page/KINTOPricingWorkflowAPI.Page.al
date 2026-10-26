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
                        FreshQuote: Record "KINTO Quote Header";
                    begin
                        if Rec."Run Pricing Trigger" then begin
                            // Re-lê do banco: o Rec da page pode estar desatualizado
                            // e o Modify final sobrescreveria o resultado com valores velhos
                            FreshQuote.Get(Rec."Quote No.");
                            PricingEngine.RunPricing(FreshQuote);
                            Rec := FreshQuote;
                            Rec."Run Pricing Trigger" := false;
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(approveTrigger; Rec."Approve Quote Trigger")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        FreshQuote: Record "KINTO Quote Header";
                    begin
                        if Rec."Approve Quote Trigger" then begin
                            FreshQuote.Get(Rec."Quote No.");
                            FreshQuote."Pricing Status" := FreshQuote."Pricing Status"::Approved;
                            FreshQuote."Approve Quote Trigger" := false;
                            FreshQuote.Modify(true);
                            Rec := FreshQuote;
                        end;
                    end;
                }
                field(createContractTrigger; Rec."Create Contract Trigger")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
                        FreshQuote: Record "KINTO Quote Header";
                    begin
                        if Rec."Create Contract Trigger" then begin
                            FreshQuote.Get(Rec."Quote No.");
                            FreshQuote."Created Contract No." := BillingMgt.CreateContractFromQuote(FreshQuote);
                            FreshQuote."Create Contract Trigger" := false;
                            FreshQuote.Modify(true);
                            Rec := FreshQuote;
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
                        FreshQuote: Record "KINTO Quote Header";
                    begin
                        if Rec."Generate Billing Trigger" then begin
                            FreshQuote.Get(Rec."Quote No.");
                            Contract.SetRange("Quote No.", FreshQuote."Quote No.");
                            if Contract.FindFirst() then
                                BillingMgt.GenerateBillingForContract(Contract, CalcDate('<-CM>', WorkDate()));
                            FreshQuote."Generate Billing Trigger" := false;
                            FreshQuote.Modify(true);
                            Rec := FreshQuote;
                        end;
                    end;
                }
            }
        }
    }
}
