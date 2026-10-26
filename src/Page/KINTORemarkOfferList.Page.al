page 50459 "KINTO Remarketing Offer List"
{
    Caption = 'Remarketing Offers';
    PageType = List;
    SourceTable = "KINTO Remarketing Offer";
    SourceTableView = sorting("Offer No.") order(descending);
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Offer No."; Rec."Offer No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Step No."; Rec."Step No.") { ApplicationArea = All; }
                field("Channel Type"; Rec."Channel Type") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = StatusStyle; }
                field("Offer Price"; Rec."Offer Price") { ApplicationArea = All; }
                field("Sent Date"; Rec."Sent Date") { ApplicationArea = All; }
                field("Expiry Date"; Rec."Expiry Date") { ApplicationArea = All; }
                field("Response Date"; Rec."Response Date") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendOffer)
            {
                Caption = 'Send Offer';
                ApplicationArea = All;
                Image = SendTo;
                trigger OnAction()
                var
                    RemMgt: Codeunit "KINTO Remarketing Mgt.";
                begin
                    RemMgt.SendOffer(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(AcceptOffer)
            {
                Caption = 'Accept Offer';
                ApplicationArea = All;
                Image = Account;
                trigger OnAction()
                var
                    RemMgt: Codeunit "KINTO Remarketing Mgt.";
                begin
                    RemMgt.AcceptOffer(Rec);
                    CurrPage.Update(true);
                end;
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Accepted:
                StatusStyle := 'Favorable';
            Rec.Status::Rejected, Rec.Status::Skipped:
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
