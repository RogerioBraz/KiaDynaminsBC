page 50205 "KINTO Billing Line List"
{
    Caption = 'KINTO Billing Lines';
    PageType = List;
    SourceTable = "KINTO Billing Line";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Billing Month"; Rec."Billing Month") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Condition ID"; Rec."Condition ID") { ApplicationArea = All; }
                field("Financial Product Code"; Rec."Financial Product Code") { ApplicationArea = All; }
                field("Product Type"; Rec."Product Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; }
                field("Unit Price"; Rec."Unit Price") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Days Billed"; Rec."Days Billed") { ApplicationArea = All; }
                field(Prorated; Rec.Prorated) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Sales Invoice No."; Rec."Sales Invoice No.") { ApplicationArea = All; }
                field("Credit Memo No."; Rec."Credit Memo No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApproveLine)
            {
                Caption = 'Approve';
                ApplicationArea = All;
                Image = Approve;
                Enabled = Rec.Status = Rec.Status::Open;
                trigger OnAction()
                begin
                    Rec.Approve();
                    CurrPage.Update(true);
                end;
            }
            action(InvoiceApproved)
            {
                Caption = 'Invoice Approved Lines';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
                    Invoiced: Integer;
                begin
                    Invoiced := BillingMgt.InvoiceApprovedLines(Rec."Contract No.", Rec."Billing Month");
                    Message('%1 billing line(s) invoiced.', Invoiced);
                    CurrPage.Update(true);
                end;
            }
            action(CancelLine)
            {
                Caption = 'Cancel';
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                var
                    Reason: Text[250];
                begin
                    Reason := 'Cancelled by user';
                    Rec.Cancel(Reason);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}