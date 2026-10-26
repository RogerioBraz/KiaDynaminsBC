page 50188 "KINTO Billing Line API"
{
    Caption = 'KINTO Billing Lines';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'billingLine';
    EntitySetName = 'billingLines';
    SourceTable = "KINTO Billing Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(entryNo; Rec."Entry No.") { ApplicationArea = All; }
                field(contractNo; Rec."Contract No.") { ApplicationArea = All; }
                field(billingMonth; Rec."Billing Month") { ApplicationArea = All; }
                field(financialProductCode; Rec."Financial Product Code") { ApplicationArea = All; }
                field(description; Rec.Description) { ApplicationArea = All; }
                field(daysBilled; Rec."Days Billed") { ApplicationArea = All; }
                field(amount; Rec.Amount) { ApplicationArea = All; }
                field(status; Rec.Status) { ApplicationArea = All; }
                field(salesInvoiceNo; Rec."Sales Invoice No.") { ApplicationArea = All; }
                field(systemId; Rec.SystemId) { ApplicationArea = All; }
            }
        }
    }
}
