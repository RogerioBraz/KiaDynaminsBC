page 50460 "KINTO Remarketing Sale"
{
    Caption = 'Remarketing Sale';
    PageType = Card;
    SourceTable = "KINTO Remarketing Sale";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Sale No."; Rec."Sale No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Offer No."; Rec."Offer No.") { ApplicationArea = All; }
                field("Buyer Type"; Rec."Buyer Type") { ApplicationArea = All; }
                field("Buyer No."; Rec."Buyer No.") { ApplicationArea = All; }
                field("Buyer Name"; Rec."Buyer Name") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = StatusStyle; }
            }
            group(Pricing)
            {
                Caption = 'Pricing & Costs';
                field("Sale Price"; Rec."Sale Price") { ApplicationArea = All; }
                field("Preparation Cost"; Rec."Preparation Cost") { ApplicationArea = All; }
                field("Doc/Fees Cost"; Rec."Doc/Fees Cost") { ApplicationArea = All; }
                field("Other Cost"; Rec."Other Cost") { ApplicationArea = All; }
                field("Total Cost"; Rec."Total Cost") { ApplicationArea = All; }
                field("Gross Margin"; Rec."Gross Margin") { ApplicationArea = All; }
                field("Margin %"; Rec."Margin %") { ApplicationArea = All; }
                field("Commission Amount"; Rec."Commission Amount") { ApplicationArea = All; }
            }
            group(Dates)
            {
                Caption = 'Dates & Approval';
                field("Sale Date"; Rec."Sale Date") { ApplicationArea = All; }
                field("Payment Due Date"; Rec."Payment Due Date") { ApplicationArea = All; }
                field("Payment Date"; Rec."Payment Date") { ApplicationArea = All; }
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; }
                field("Approved DateTime"; Rec."Approved DateTime") { ApplicationArea = All; }
                field("Invoice No."; Rec."Invoice No.") { ApplicationArea = All; }
                field("Asset Written Off"; Rec."Asset Written Off") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApprovePrice)
            {
                Caption = 'Approve Price (4-eyes)';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                var
                    RemMgt: Codeunit "KINTO Remarketing Mgt.";
                begin
                    RemMgt.ApproveSalePrice(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(Invoice)
            {
                Caption = 'Invoice Sale';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    RemMgt: Codeunit "KINTO Remarketing Mgt.";
                begin
                    RemMgt.InvoiceSale(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(RegisterPayment)
            {
                Caption = 'Register Payment';
                ApplicationArea = All;
                Image = Payment;
                trigger OnAction()
                var
                    RemMgt: Codeunit "KINTO Remarketing Mgt.";
                begin
                    RemMgt.RegisterPayment(Rec, WorkDate());
                    CurrPage.Update(true);
                end;
            }
            action(Complete)
            {
                Caption = 'Complete (write off asset)';
                ApplicationArea = All;
                Image = Close;
                trigger OnAction()
                var
                    RemMgt: Codeunit "KINTO Remarketing Mgt.";
                begin
                    RemMgt.CompleteSale(Rec);
                    CurrPage.Update(true);
                end;
            }
        }
        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(ApprovePrice_P; ApprovePrice) { }
                actionref(Invoice_P; Invoice) { }
                actionref(RegisterPayment_P; RegisterPayment) { }
                actionref(Complete_P; Complete) { }
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Paid, Rec.Status::Completed:
                StatusStyle := 'Favorable';
            Rec.Status::Cancelled:
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
