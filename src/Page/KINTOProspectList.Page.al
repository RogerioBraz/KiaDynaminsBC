page 60310 "KINTO Prospect List"
{
    Caption = 'KINTO Prospects';
    PageType = List;
    SourceTable = "KINTO Prospect";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Prospect No."; Rec."Prospect No.") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Prospect Type"; Rec."Prospect Type") { ApplicationArea = All; }
                field("Tax ID"; Rec."Tax ID") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Channel; Rec.Channel) { ApplicationArea = All; }
                field("Contact Name"; Rec."Contact Name") { ApplicationArea = All; }
                field("Contact Phone"; Rec."Contact Phone") { ApplicationArea = All; }
                field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
                field("Converted Customer No."; Rec."Converted Customer No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConvertToCustomer)
            {
                Caption = 'Convert to Customer';
                ApplicationArea = All;
                Image = Move;
                ToolTip = 'Creates the BC customer from the selected prospect, keeping the prospect as history.';
                trigger OnAction()
                var
                    Mgt: Codeunit "KINTO Prospect Management";
                    CustomerNo: Code[20];
                begin
                    if not Rec.Get(Rec."Prospect No.") then
                        exit;
                    CustomerNo := Mgt.ConvertToCustomer(Rec."Prospect No.");
                    Message('Customer %1 created from prospect %2.', CustomerNo, Rec."Prospect No.");
                    CurrPage.Update(false);
                end;
            }
            action(BlockProspect)
            {
                Caption = 'Block';
                ApplicationArea = All;
                Image = Lock;
                trigger OnAction()
                var
                    Reason: Enum "KINTO Block Reason";
                    Why: Text[250];
                begin
                    if not Rec.Get(Rec."Prospect No.") then
                        exit;
                    if not Confirm('Block prospect %1?', true, Rec."Prospect No.") then
                        exit;
                    Why := '';
                    Rec.Block(Reason::Credit, Why);
                    CurrPage.Update(false);
                end;
            }
            action(UnblockProspect)
            {
                Caption = 'Unblock';
                ApplicationArea = All;
                Image = Unlock;
                trigger OnAction()
                begin
                    if not Rec.Get(Rec."Prospect No.") then
                        exit;
                    Rec.Unblock();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(ConvertToCustomer_Promoted; ConvertToCustomer) { }
        }
    }
}
