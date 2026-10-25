page 50213 "KINTO Maintenance Ticket Card"
{
    Caption = 'KINTO Maintenance Ticket';
    PageType = Card;
    SourceTable = "KINTO Maintenance Ticket";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field("Ticket Type"; Rec."Ticket Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; Editable = false; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Service Date"; Rec."Service Date") { ApplicationArea = All; }
                field("Warranty Status"; Rec."Warranty Status") { ApplicationArea = All; }
                field("Sequence OK"; Rec."Sequence OK") { ApplicationArea = All; Editable = false; }
            }
            group(Vehicle)
            {
                Caption = 'Vehicle & Contract';
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Odometer at Service"; Rec."Odometer at Service") { ApplicationArea = All; }
                field("Engine Hours"; Rec."Engine Hours") { ApplicationArea = All; }
            }
            group(Totals)
            {
                Caption = 'Totals';
                field("Total Cost"; Rec."Total Cost") { ApplicationArea = All; }
                field("Total Billable"; Rec."Total Billable") { ApplicationArea = All; }
                field("Pool Consumed"; Rec."Pool Consumed") { ApplicationArea = All; Editable = false; }
                field("Pre-Approved"; Rec."Pre-Approved") { ApplicationArea = All; Editable = false; }
            }
            part(Lines; "KINTO Maint Ticket Lines")
            {
                Caption = 'Service Lines';
                SubPageLink = "Ticket No." = field("Ticket No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(StartAnalysis)
            {
                Caption = 'Start Analysis';
                ApplicationArea = All;
                Image = TaskList;
                trigger OnAction()
                begin
                    Rec.StartAnalysis();
                    CurrPage.Update(true);
                end;
            }
            action(SubmitApproval)
            {
                Caption = 'Submit for Approval';
                ApplicationArea = All;
                Image = SendTo;
                trigger OnAction()
                begin
                    Rec.SubmitForApproval();
                    CurrPage.Update(true);
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                begin
                    Rec.Approve();
                    CurrPage.Update(true);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ApplicationArea = All;
                Image = Reject;
                trigger OnAction()
                var
                    Reason: Text[250];
                begin
                    Reason := 'Rejected by approver';
                    Rec.Reject(Reason);
                    CurrPage.Update(true);
                end;
            }
            action(StartExecution)
            {
                Caption = 'Start Execution';
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                begin
                    Rec.StartExecution();
                    CurrPage.Update(true);
                end;
            }
            action(CloseTicket)
            {
                Caption = 'Close';
                ApplicationArea = All;
                Image = Close;
                trigger OnAction()
                begin
                    Rec.CloseTicket();
                    CurrPage.Update(true);
                end;
            }
            action(CancelTicket)
            {
                Caption = 'Cancel';
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                begin
                    Rec.CancelTicket();
                    CurrPage.Update(true);
                end;
            }
            action(ValidateTicket)
            {
                Caption = 'Validate';
                ApplicationArea = All;
                Image = Validate;
                trigger OnAction()
                var
                    Ok: Boolean;
                begin
                    Ok := Rec.ValidateTicket();
                    if Ok then
                        Message('Validation passed.')
                    else
                        Message('Validation found issues — check Sequence OK and lines.');
                end;
            }
            action(BillCustomer)
            {
                Caption = 'Bill Additional to Customer';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    MaintMgt: Codeunit "KINTO Maintenance Management";
                begin
                    MaintMgt.BillTicketToCustomer(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(PoolLedger)
            {
                Caption = 'Pool Ledger';
                ApplicationArea = All;
                Image = Ledger;
                RunObject = page "KINTO Pool Ledger Entries";
                RunPageLink = "Contract No." = field("Contract No.");
            }
        }
    }
}