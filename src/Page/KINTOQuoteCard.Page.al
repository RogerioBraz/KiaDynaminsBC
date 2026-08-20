page 50110 "KINTO Quote Card"
{
    Caption = 'KINTO Quote';
    PageType = Card;
    SourceTable = "KINTO Quote Header";
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            group(Header)
            {
                Caption = 'Quote Header';
                field("Quote No."; Rec."Quote No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Dealer No."; Rec."Dealer No.") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Pricing Status"; Rec."Pricing Status") { ApplicationArea = All; }
                field("Pricing Methodology"; Rec."Pricing Methodology") { ApplicationArea = All; }
                field("Approval Classification"; Rec."Approval Classification") { ApplicationArea = All; }
            }
            group(Parameters)
            {
                Caption = 'Pricing Parameters';
                field("Target ROI %"; Rec."Target ROI %") { ApplicationArea = All; }
                field("Negotiation Buffer %"; Rec."Negotiation Buffer %") { ApplicationArea = All; }
                field("Payment Allowance Days"; Rec."Payment Allowance Days") { ApplicationArea = All; }
                field("Extended Analysis Months"; Rec."Extended Analysis Months") { ApplicationArea = All; }
                field("Credit Score"; Rec."Credit Score") { ApplicationArea = All; }
                field("Credit Risk Factor %"; Rec."Credit Risk Factor %") { ApplicationArea = All; }
                field("Contract Start Month"; Rec."Contract Start Month") { ApplicationArea = All; }
            }
            group(Results)
            {
                Caption = 'Results';
                field("Calculated Monthly Fee"; Rec."Calculated Monthly Fee") { ApplicationArea = All; }
                field("Negotiated Monthly Price"; Rec."Negotiated Monthly Price") { ApplicationArea = All; }
                field("Total MSRP"; Rec."Total MSRP") { ApplicationArea = All; }
                field("Total Purchase Price"; Rec."Total Purchase Price") { ApplicationArea = All; }
                field("Total Monthly Fee"; Rec."Total Monthly Fee") { ApplicationArea = All; }
                field("KINTO IRR"; Rec."KINTO IRR") { ApplicationArea = All; }
                field("Reference IRR"; Rec."Reference IRR") { ApplicationArea = All; }
                field("Calculated ROI"; Rec."Calculated ROI") { ApplicationArea = All; }
                field("EBT"; Rec."EBT") { ApplicationArea = All; }
                field("PAT"; Rec."PAT") { ApplicationArea = All; }
                field("KINTO FCF"; Rec."KINTO FCF") { ApplicationArea = All; }
            }
            part(QuoteItems; "KINTO Quote Item Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Quote No." = field("Quote No.");
            }
        }
        area(FactBoxes)
        {
            part(CashFlowFactBox; "KINTO Cash Flow FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Quote No." = field("Quote No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunPricing)
            {
                Caption = 'Run Pricing';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                var
                    PricingEngine: Codeunit "KINTO Pricing Engine Mgt.";
                begin
                    PricingEngine.RunPricing(Rec);
                    Message('Pricing calculation completed. Status: %1', Rec."Pricing Status");
                end;
            }
            action(ActSubmitForApproval)
            {
                Caption = 'Submit for Approval';
                ApplicationArea = All;
                Image = SendApprovalRequest;
                trigger OnAction()
                begin
                    SubmitForApproval(Rec);
                end;
            }
            action(ViewCashFlow)
            {
                Caption = 'View Cash Flow';
                ApplicationArea = All;
                Image = CashFlow;
                trigger OnAction()
                var
                    CFData: Record "KINTO Cash Flow Data";
                begin
                    CFData.SetRange("Quote No.", Rec."Quote No.");
                    Page.Run(Page::"KINTO Cash Flow Data List", CFData);
                end;
            }
            action(ViewSnapshot)
            {
                Caption = 'View Snapshot';
                ApplicationArea = All;
                Image = Copy;
                trigger OnAction()
                var
                    Snapshot: Record "KINTO Simulation Snapshot";
                begin
                    if Rec."Snapshot ID" <> '' then begin
                        Snapshot.Get(Rec."Snapshot ID");
                        Page.Run(Page::"KINTO Snapshot Card", Snapshot);
                    end;
                end;
            }
            action(ViewCustomer)
            {
                Caption = 'Ver Cliente';
                ApplicationArea = All;
                Image = Customer;
                Visible = Rec."Customer No." <> '';
                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if Customer.Get(Rec."Customer No.") then
                        Page.Run(Page::"Customer Card", Customer);
                end;
            }
            action(ViewDealer)
            {
                Caption = 'Ver Dealer';
                ApplicationArea = All;
                Image = Vendor;
                Visible = Rec."Dealer No." <> '';
                trigger OnAction()
                var
                    Vendor: Record Vendor;
                begin
                    if Vendor.Get(Rec."Dealer No.") then
                        Page.Run(Page::"Vendor Card", Vendor);
                end;
            }
            action(ViewCountrySetup)
            {
                Caption = 'Ver Configuração do País';
                ApplicationArea = All;
                Image = Setup;
                Visible = Rec."Country Code" <> '';
                trigger OnAction()
                var
                    CountrySetup: Record "KINTO Country Setup";
                begin
                    if CountrySetup.Get(Rec."Country Code") then
                        Page.Run(Page::"KINTO Country Setup Card", CountrySetup);
                end;
            }
            action(ViewApprovalRequest)
            {
                Caption = 'Ver Solicitação de Aprovação';
                ApplicationArea = All;
                Image = Approval;
                Visible = Rec."Approval Request ID" <> '';
                trigger OnAction()
                var
                    ApprovalReq: Record "KINTO Approval Request";
                begin
                    if Rec."Approval Request ID" <> '' then
                        if ApprovalReq.Get(Rec."Approval Request ID") then
                            Page.Run(Page::"KINTO Approval Request Card", ApprovalReq);
                end;
            }
            action(ViewInsuranceQuote)
            {
                Caption = 'Ver Cotação de Seguro';
                ApplicationArea = All;
                Image = Insurance;
                trigger OnAction()
                var
                    InsQuote: Record "KINTO Insurance Quote";
                begin
                    InsQuote.SetRange("KINTO Quote No.", Rec."Quote No.");
                    if InsQuote.FindFirst() then
                        Page.Run(Page::"KINTO Insurance Quote Card", InsQuote)
                    else
                        Message('Nenhuma cotação de seguro vinculada a esta cotação.');
                end;
            }
        }
    }

    local procedure SubmitForApproval(var QuoteHeader: Record "KINTO Quote Header")
    var
        ApprovalReq: Record "KINTO Approval Request";
    begin
        ApprovalReq.Init();
        ApprovalReq."Request ID" := Format(QuoteHeader."Quote No.") + '-APP';
        ApprovalReq."Quote No." := QuoteHeader."Quote No.";
        ApprovalReq.Classification := QuoteHeader."Approval Classification";
        ApprovalReq.Insert(true);

        QuoteHeader."Approval Request ID" := ApprovalReq."Request ID";
        QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::"Pre-Approved";
        QuoteHeader.Modify(true);

        Message('Approval request %1 created. Classification: %2',
                ApprovalReq."Request ID", ApprovalReq.Classification);
    end;
}