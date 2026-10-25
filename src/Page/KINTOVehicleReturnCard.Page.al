page 50400 "KINTO Vehicle Return Card"
{
    Caption = 'KINTO Vehicle Return';
    PageType = Card;
    SourceTable = "KINTO Vehicle Return";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Return No."; Rec."Return No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; Editable = false; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Return Date"; Rec."Return Date") { ApplicationArea = All; }
                field("Return Location"; Rec."Return Location") { ApplicationArea = All; }
                field(Latitude; Rec.Latitude) { ApplicationArea = All; }
                field(Longitude; Rec.Longitude) { ApplicationArea = All; }
            }
            group(Inspection)
            {
                Caption = 'Inspection & Checklist';
                field("Odometer at Return"; Rec."Odometer at Return") { ApplicationArea = All; }
                field("Engine Hours at Return"; Rec."Engine Hours at Return") { ApplicationArea = All; }
                field("Fuel Level %"; Rec."Fuel Level %") { ApplicationArea = All; }
                field("Checklist Complete"; Rec."Checklist Complete") { ApplicationArea = All; Editable = false; }
                field("Cautelar Report No."; Rec."Cautelar Report No.") { ApplicationArea = All; }
                field("Cautelar Result"; Rec."Cautelar Result") { ApplicationArea = All; }
                field("Pending Items"; Rec."Pending Items") { ApplicationArea = All; Editable = false; }
                field("Pending Items Desc."; Rec."Pending Items Desc.") { ApplicationArea = All; }
            }
            group(Totals)
            {
                Caption = 'Damage Totals';
                field("Total Damage Amount"; Rec."Total Damage Amount") { ApplicationArea = All; }
                field("Customer Damage Amount"; Rec."Customer Damage Amount") { ApplicationArea = All; }
                field("Dealer Charge Amount"; Rec."Dealer Charge Amount") { ApplicationArea = All; }
                field("Billing Line Entry No."; Rec."Billing Line Entry No.") { ApplicationArea = All; Editable = false; }
                field("Dealer Charge Doc No."; Rec."Dealer Charge Doc No.") { ApplicationArea = All; Editable = false; }
            }
            part(Damages; "KINTO Damage Lines")
            {
                Caption = 'Damage Lines';
                SubPageLink = "Return No." = field("Return No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(StartReturn)
            {
                Caption = 'Start';
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                var
                    TermMgt: Codeunit "KINTO Termination Management";
                begin
                    TermMgt.StartReturn(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(CompleteChecklist)
            {
                Caption = 'Complete Checklist';
                ApplicationArea = All;
                Image = CheckList;
                trigger OnAction()
                begin
                    Rec.CompleteChecklist();
                    CurrPage.Update(true);
                end;
            }
            action(FinishReturn)
            {
                Caption = 'Finish Return';
                ApplicationArea = All;
                Image = Close;
                trigger OnAction()
                begin
                    Rec.FinishReturn();
                    CurrPage.Update(true);
                end;
            }
            action(BillDamages)
            {
                Caption = 'Bill Damages to Customer';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                begin
                    Rec.BillDamagesToCustomer();
                    CurrPage.Update(true);
                end;
            }
            action(ChargeDealer)
            {
                Caption = 'Charge Pending Items to Dealer';
                ApplicationArea = All;
                Image = VendorLedger;
                trigger OnAction()
                begin
                    Rec.ChargePendingItemsToDealer();
                    CurrPage.Update(true);
                end;
            }
        }
    }
}