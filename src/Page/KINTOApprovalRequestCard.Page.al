page 50137 "KINTO Approval Request Card"
{
    Caption = 'KINTO Approval Request';
    PageType = Card;
    SourceTable = "KINTO Approval Request";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Request ID"; Rec."Request ID") { ApplicationArea = All; Editable = false; }
                field("Quote No."; Rec."Quote No.") { ApplicationArea = All; Editable = false; }
                field("Requester ID"; Rec."Requester ID") { ApplicationArea = All; Editable = false; }
                field("Approver ID"; Rec."Approver ID") { ApplicationArea = All; }
                field("Request DateTime"; Rec."Request DateTime") { ApplicationArea = All; Editable = false; }
                field("Approval DateTime"; Rec."Approval DateTime") { ApplicationArea = All; Editable = false; }
                field("Status"; Rec."Status") { ApplicationArea = All; Editable = false; }
                field("Classification"; Rec."Classification") { ApplicationArea = All; Editable = false; }
            }
            group(Details)
            {
                Caption = 'Details';
                field("Comments"; Rec."Comments") { ApplicationArea = All; MultiLine = true; }
                field("Rejection Reason"; Rec."Rejection Reason") { ApplicationArea = All; MultiLine = true; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Approve)
            {
                Caption = 'Approve';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                begin
                    Rec."Status" := Rec."Status"::Approved;
                    Rec."Approval DateTime" := CurrentDateTime;
                    Rec."Approver ID" := UserId;
                    Rec.Modify(true);
                    UpdateQuoteStatus(Rec."Quote No.", true);
                    Message('Approval request %1 approved.', Rec."Request ID");
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ApplicationArea = All;
                Image = Reject;
                trigger OnAction()
                begin
                    Rec."Status" := Rec."Status"::Rejected;
                    Rec."Approval DateTime" := CurrentDateTime;
                    Rec."Approver ID" := UserId;
                    Rec.Modify(true);
                    UpdateQuoteStatus(Rec."Quote No.", false);
                    Message('Approval request %1 rejected.', Rec."Request ID");
                end;
            }

            // ====================================================
            // NOVA ACTION DE NAVEGABILIDADE
            // ====================================================

            action(ViewQuote)
            {
                Caption = 'Ver Cotação';
                ApplicationArea = All;
                Image = Document;
                Visible = Rec."Quote No." <> '';
                trigger OnAction()
                var
                    QuoteHeader: Record "KINTO Quote Header";
                begin
                    if QuoteHeader.Get(Rec."Quote No.") then
                        Page.Run(Page::"KINTO Quote Card", QuoteHeader);
                end;
            }
            action(ViewCashFlow)
            {
                Caption = 'Ver Fluxo de Caixa';
                ApplicationArea = All;
                Image = CashFlow;
                Visible = Rec."Quote No." <> '';
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
                Caption = 'Ver Snapshot';
                ApplicationArea = All;
                Image = Snapshot;
                Visible = Rec."Quote No." <> '';
                trigger OnAction()
                var
                    Snapshot: Record "KINTO Simulation Snapshot";
                begin
                    Snapshot.SetRange("Quote No.", Rec."Quote No.");
                    if Snapshot.FindFirst() then
                        Page.Run(Page::"KINTO Snapshot Card", Snapshot);
                end;
            }
        }

    }

    local procedure UpdateQuoteStatus(QuoteNo: Code[20]; Approved: Boolean)
    var
        QuoteHeader: Record "KINTO Quote Header";
    begin
        if QuoteHeader.Get(QuoteNo) then begin
            if Approved then
                QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::Approved
            else
                QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::Error;
            QuoteHeader.Modify(true);
        end;
    end;
}