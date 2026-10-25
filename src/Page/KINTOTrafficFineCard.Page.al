page 50300 "KINTO Traffic Fine Card"
{
    Caption = 'KINTO Traffic Fine';
    PageType = Card;
    SourceTable = "KINTO Traffic Fine";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Fine No."; Rec."Fine No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; Editable = false; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("AIIP Code"; Rec."AIIP Code") { ApplicationArea = All; }
                field("Issuing Authority Code"; Rec."Issuing Authority Code") { ApplicationArea = All; }
                field("Jurisdiction"; Rec."Jurisdiction") { ApplicationArea = All; }
                field("Infraction Code"; Rec."Infraction Code") { ApplicationArea = All; }
                field("Infraction Description"; Rec."Infraction Description") { ApplicationArea = All; }
                field("Infraction DateTime"; Rec."Infraction DateTime") { ApplicationArea = All; }
                field("Capture DateTime"; Rec."Capture DateTime") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
            }
            group(Values)
            {
                Caption = 'Values (RN-016)';
                field("Customer Amount"; Rec."Customer Amount") { ApplicationArea = All; }
                field("Vendor Amount"; Rec."Vendor Amount") { ApplicationArea = All; }
                field("Full Amount"; Rec."Full Amount") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("SNE Adjustment %"; Rec."SNE Adjustment %") { ApplicationArea = All; }
            }
            group(Link)
            {
                Caption = 'Contract Link';
                field("Link Status"; Rec."Link Status") { ApplicationArea = All; Editable = false; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; Editable = false; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; Editable = false; }
                field("Linked DateTime"; Rec."Linked DateTime") { ApplicationArea = All; Editable = false; }
            }
            group(Payment)
            {
                Caption = 'Payment & Reconciliation';
                field("Payment Due Date"; Rec."Payment Due Date") { ApplicationArea = All; }
                field("Paid Date"; Rec."Paid Date") { ApplicationArea = All; Editable = false; }
                field("Payment Amount"; Rec."Payment Amount") { ApplicationArea = All; Editable = false; }
                field("Payment Link"; Rec."Payment Link") { ApplicationArea = All; }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.") { ApplicationArea = All; }
                field("Vendor Paid"; Rec."Vendor Paid") { ApplicationArea = All; Editable = false; }
                field("Vendor Paid Date"; Rec."Vendor Paid Date") { ApplicationArea = All; Editable = false; }
            }
            group(Seizure)
            {
                Caption = 'Seizure & Restrictions (BR)';
                field("Seizure Flag"; Rec."Seizure Flag") { ApplicationArea = All; }
                field("Registration Restriction"; Rec."Registration Restriction") { ApplicationArea = All; }
            }
            group(Other)
            {
                Caption = 'Other';
                field("Provider Code"; Rec."Provider Code") { ApplicationArea = All; }
                field("Provider Batch No."; Rec."Provider Batch No.") { ApplicationArea = All; }
                field("Evidence Attached"; Rec."Evidence Attached") { ApplicationArea = All; }
                field("Cancellation Reason"; Rec."Cancellation Reason") { ApplicationArea = All; }
                field("Refund Amount"; Rec."Refund Amount") { ApplicationArea = All; }
                field("Refund Status"; Rec."Refund Status") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LinkContract)
            {
                Caption = 'Link to Contract (by infraction date)';
                ApplicationArea = All;
                Image = Link;
                trigger OnAction()
                var
                    FineMgt: Codeunit "KINTO Fine Management";
                begin
                    FineMgt.LinkFine(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(IndicateDriver)
            {
                Caption = 'Indicate Driver';
                ApplicationArea = All;
                Image = User;
                trigger OnAction()
                var
                    DriverName: Text[100];
                    DriverCPF: Text[20];
                    DriverLicense: Text[20];
                begin
                    DriverName := 'Driver';
                    DriverCPF := '';
                    DriverLicense := '';
                    Rec.IndicateDriver(DriverName, DriverCPF, DriverLicense);
                    CurrPage.Update(true);
                end;
            }
            action(SendNIC)
            {
                Caption = 'Send NIC';
                ApplicationArea = All;
                Image = Email;
                trigger OnAction()
                begin
                    Rec.SendNIC();
                    CurrPage.Update(true);
                end;
            }
            action(MarkPenalty)
            {
                Caption = 'Mark Penalty Issued';
                ApplicationArea = All;
                Image = Warning;
                trigger OnAction()
                begin
                    Rec.MarkPenaltyIssued();
                    CurrPage.Update(true);
                end;
            }
            action(Appeal)
            {
                Caption = 'Appeal';
                ApplicationArea = All;
                Image = Document;
                trigger OnAction()
                begin
                    Rec.Appeal();
                    CurrPage.Update(true);
                end;
            }
            action(CancelFine)
            {
                Caption = 'Cancel';
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                var
                    Reason: Text[250];
                begin
                    Reason := 'Cancelled manually';
                    Rec.CancelFine(Reason);
                    CurrPage.Update(true);
                end;
            }
            action(MarkPaid)
            {
                Caption = 'Mark Paid';
                ApplicationArea = All;
                Image = Payment;
                trigger OnAction()
                begin
                    Rec.MarkPaid(WorkDate(), Rec."Customer Amount");
                    CurrPage.Update(true);
                end;
            }
            action(BillCustomer)
            {
                Caption = 'Bill to Customer';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    FineMgt: Codeunit "KINTO Fine Management";
                begin
                    FineMgt.BillFineToCustomer(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(MarkVendorPaid)
            {
                Caption = 'Mark Vendor Paid';
                ApplicationArea = All;
                Image = Ledger;
                trigger OnAction()
                var
                    FineMgt: Codeunit "KINTO Fine Management";
                begin
                    FineMgt.MarkVendorPaid(Rec, WorkDate());
                    CurrPage.Update(true);
                end;
            }
        }
    }
}