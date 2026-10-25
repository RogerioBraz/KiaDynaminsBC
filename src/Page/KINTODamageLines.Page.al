page 50402 "KINTO Damage Lines"
{
    Caption = 'KINTO Damage Lines';
    PageType = ListPart;
    SourceTable = "KINTO Damage Line";
    DelayedInsert = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Damage Class"; Rec."Damage Class") { ApplicationArea = All; }
                field("Paid By"; Rec."Paid By") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Approved; Rec.Approved) { ApplicationArea = All; Editable = false; }
                field("Photo Attached"; Rec."Photo Attached") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
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
                trigger OnAction()
                begin
                    Rec.Approve();
                    CurrPage.Update(true);
                end;
            }
        }
    }
}