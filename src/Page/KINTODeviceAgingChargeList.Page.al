page 50463 "KINTO Device Aging Charge List"
{
    Caption = 'Device Aging Charges';
    PageType = List;
    SourceTable = "KINTO Device Aging Charge";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Device No."; Rec."Device No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Aging Days"; Rec."Aging Days") { ApplicationArea = All; }
                field("Daily Charge"; Rec."Daily Charge") { ApplicationArea = All; }
                field("Charge Amount"; Rec."Charge Amount") { ApplicationArea = All; }
                field("Charge Date"; Rec."Charge Date") { ApplicationArea = All; }
                field(Invoiced; Rec.Invoiced) { ApplicationArea = All; }
                field("Purchase Invoice No."; Rec."Purchase Invoice No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateCharges)
            {
                Caption = 'Generate Aging Charges';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                var
                    AgingMgt: Codeunit "KINTO Device Aging Mgt.";
                begin
                    AgingMgt.GenerateAgingCharges('BR', WorkDate());
                end;
            }
            action(InvoiceCharges)
            {
                Caption = 'Invoice Charges (by vendor)';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    AgingMgt: Codeunit "KINTO Device Aging Mgt.";
                begin
                    AgingMgt.InvoiceCharges('BR');
                end;
            }
        }
    }
}
