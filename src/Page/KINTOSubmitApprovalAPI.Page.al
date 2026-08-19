page 50121 "KINTO Submit Approval API"
{
    Caption = 'KINTO Submit Quotation for Approval API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'approvalRequest';
    EntitySetName = 'approvalRequests';
    SourceTable = "KINTO Approval Request";
    DelayedInsert = true;
    ODataKeyFields = "Request ID";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(requestId; Rec."Request ID") { ApplicationArea = All; }
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; }
                field(requesterId; Rec."Requester ID") { ApplicationArea = All; Editable = false; }
                field(approverId; Rec."Approver ID") { ApplicationArea = All; }
                field(requestDateTime; Rec."Request DateTime") { ApplicationArea = All; Editable = false; }
                field(approvalDateTime; Rec."Approval DateTime") { ApplicationArea = All; Editable = false; }
                field(status; Rec."Status") { ApplicationArea = All; }
                field(classification; Rec."Classification") { ApplicationArea = All; }
                field(comments; Rec."Comments") { ApplicationArea = All; }
                field(rejectionReason; Rec."Rejection Reason") { ApplicationArea = All; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        QuoteHeader: Record "KINTO Quote Header";
    begin
        if Rec."Quote No." <> '' then begin
            if QuoteHeader.Get(Rec."Quote No.") then begin
                Rec.Classification := QuoteHeader."Approval Classification";
                QuoteHeader."Approval Request ID" := Rec."Request ID";
                QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::"Pre-Approved";
                QuoteHeader.Modify(true);
            end;
        end;
    end;
}