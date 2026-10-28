page 60313 "KINTO Portfolio Transfer List"
{
    Caption = 'KINTO Portfolio Transfers';
    PageType = List;
    SourceTable = "KINTO Portfolio Transfer";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Transfer No."; Rec."Transfer No.") { ApplicationArea = All; }
                field("From Salesperson"; Rec."From Salesperson") { ApplicationArea = All; }
                field("To Salesperson"; Rec."To Salesperson") { ApplicationArea = All; }
                field("Request Date"; Rec."Request Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Customers Moved"; Rec."Customers Moved") { ApplicationArea = All; }
                field("Prospects Moved"; Rec."Prospects Moved") { ApplicationArea = All; }
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Approve)
            {
                Caption = 'Approve Transfer';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                begin
                    if not Rec.Get(Rec."Transfer No.") then
                        exit;
                    if not Confirm('Approve transfer %1? The whole portfolio will move to the destination salesperson.', true, Rec."Transfer No.") then
                        exit;
                    Rec.Approve();
                    Message('Portfolio moved: %1 customer(s) and %2 prospect(s).', Rec."Customers Moved", Rec."Prospects Moved");
                    CurrPage.Update(false);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject Transfer';
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                begin
                    if not Rec.Get(Rec."Transfer No.") then
                        exit;
                    Rec.Reject('');
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
