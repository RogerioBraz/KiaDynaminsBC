page 50215 "KINTO Maint Ticket Lines"
{
    Caption = 'KINTO Maintenance Ticket Lines';
    PageType = ListPart;
    SourceTable = "KINTO Maint Ticket Line";
    DelayedInsert = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Service Description"; Rec."Service Description") { ApplicationArea = All; }
                field("Part Number"; Rec."Part Number") { ApplicationArea = All; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; }
                field("Unit Cost"; Rec."Unit Cost") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; Editable = false; }
                field("Bill to Customer"; Rec."Bill to Customer") { ApplicationArea = All; }
                field("Customer Price"; Rec."Customer Price") { ApplicationArea = All; }
                field("Covered by Pool"; Rec."Covered by Pool") { ApplicationArea = All; }
                field("Covered by Warranty"; Rec."Covered by Warranty") { ApplicationArea = All; }
                field("Standard Price Found"; Rec."Standard Price Found") { ApplicationArea = All; Editable = false; }
                field("Price Deviation %"; Rec."Price Deviation %") { ApplicationArea = All; Editable = false; }
                field("Line Type"; Rec."Line Type") { ApplicationArea = All; }
                field("Service Type"; Rec."Service Type") { ApplicationArea = All; }
                field(Hours; Rec.Hours) { ApplicationArea = All; }
                field("Billable Hours"; Rec."Billable Hours") { ApplicationArea = All; Editable = false; }
                field("HH Rate"; Rec."HH Rate") { ApplicationArea = All; Editable = false; }
                field("Minimum Hours Applied"; Rec."Minimum Hours Applied") { ApplicationArea = All; Editable = false; }
            }
        }
    }
}