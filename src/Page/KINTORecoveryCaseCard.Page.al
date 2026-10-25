page 50403 "KINTO Recovery Case Card"
{
    Caption = 'KINTO Recovery Case';
    PageType = Card;
    SourceTable = "KINTO Recovery Case";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Case No."; Rec."Case No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; Editable = false; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Case Date"; Rec."Case Date") { ApplicationArea = All; }
                field("Aging Days"; Rec."Aging Days") { ApplicationArea = All; }
                field("Risk Level"; Rec."Risk Level") { ApplicationArea = All; }
                field("Last Contact Date"; Rec."Last Contact Date") { ApplicationArea = All; }
                field("Next Task Date"; Rec."Next Task Date") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
            }
            group(Recovery)
            {
                Caption = 'Recovery';
                field("Recovered Date"; Rec."Recovered Date") { ApplicationArea = All; Editable = false; }
                field("Current Odometer"; Rec."Current Odometer") { ApplicationArea = All; Editable = false; }
                field("Vehicle Condition"; Rec."Vehicle Condition") { ApplicationArea = All; Editable = false; }
            }
            group(Control)
            {
                Caption = 'Control';
                field(Blocked; Rec.Blocked) { ApplicationArea = All; Editable = false; }
                field("Blocked Reason"; Rec."Blocked Reason") { ApplicationArea = All; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClassifyRisk)
            {
                Caption = 'Classify Risk';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                begin
                    Rec.ClassifyRisk();
                    CurrPage.Update(true);
                end;
            }
            action(MarkRecovered)
            {
                Caption = 'Mark Recovered';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                var
                    D: Date;
                    Odo: Decimal;
                    Cond: Text[100];
                begin
                    D := WorkDate();
                    Odo := 0;
                    Cond := '';
                    Rec.MarkRecovered(D, Odo, Cond);
                    CurrPage.Update(true);
                end;
            }
            action(Unblock)
            {
                Caption = 'Unblock (requires permission)';
                ApplicationArea = All;
                Image = Unlock;
                trigger OnAction()
                begin
                    Rec.Unblock();
                    CurrPage.Update(true);
                end;
            }
        }
    }
}