page 50473 "KINTO Settlement"
{
    Caption = 'Settlement';
    PageType = Card;
    SourceTable = "KINTO Settlement";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Settlement No."; Rec."Settlement No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Settlement Type"; Rec."Settlement Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = StatusStyle; }
                field("Settlement Date"; Rec."Settlement Date") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
            group(Balances)
            {
                Caption = 'Balances';
                field("Open Billing Balance"; Rec."Open Billing Balance") { ApplicationArea = All; }
                field("Damage Balance"; Rec."Damage Balance") { ApplicationArea = All; }
                field("Fine Balance"; Rec."Fine Balance") { ApplicationArea = All; }
                field("Mileage Excess Charge"; Rec."Mileage Excess Charge") { ApplicationArea = All; }
                field("Deductible Amount"; Rec."Deductible Amount") { ApplicationArea = All; }
                field("Insurance Recovery Amount"; Rec."Insurance Recovery Amount") { ApplicationArea = All; }
                field("Total Amount"; Rec."Total Amount") { ApplicationArea = All; Style = Strong; }
            }
            group(Approval)
            {
                Caption = 'Approval & Invoice';
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; }
                field("Approved DateTime"; Rec."Approved DateTime") { ApplicationArea = All; }
                field("Invoice No."; Rec."Invoice No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Submit)
            {
                Caption = 'Submit for Approval';
                ApplicationArea = All;
                Image = SendApprovalRequest;
                trigger OnAction()
                var
                    SetMgt: Codeunit "KINTO Settlement Mgt.";
                begin
                    SetMgt.SubmitForApproval(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                var
                    SetMgt: Codeunit "KINTO Settlement Mgt.";
                begin
                    SetMgt.Approve(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(Invoice)
            {
                Caption = 'Invoice Settlement';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    SetMgt: Codeunit "KINTO Settlement Mgt.";
                begin
                    SetMgt.InvoiceSettlement(Rec);
                    CurrPage.Update(true);
                end;
            }
        }
        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(Submit_P; Submit) { }
                actionref(Approve_P; Approve) { }
                actionref(Invoice_P; Invoice) { }
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Approved, Rec.Status::Invoiced:
                StatusStyle := 'Favorable';
            Rec.Status::Cancelled:
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
