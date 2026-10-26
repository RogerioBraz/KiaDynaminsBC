page 50471 "KINTO Contract Substitution"
{
    Caption = 'Contract Substitution';
    PageType = Card;
    SourceTable = "KINTO Contract Substitution";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Substitution No."; Rec."Substitution No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Old Vehicle No."; Rec."Old Vehicle No.") { ApplicationArea = All; }
                field("New Vehicle No."; Rec."New Vehicle No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Reason; Rec.Reason) { ApplicationArea = All; }
                field("Is Provisional"; Rec."Is Provisional") { ApplicationArea = All; }
            }
            group(Dates)
            {
                Caption = 'Dates';
                field("Request Date"; Rec."Request Date") { ApplicationArea = All; }
                field("Delivery Date"; Rec."Delivery Date") { ApplicationArea = All; }
                field("Completion Date"; Rec."Completion Date") { ApplicationArea = All; }
                field("Odometer at Delivery"; Rec."Odometer at Delivery") { ApplicationArea = All; }
                field("Device Transferred"; Rec."Device Transferred") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Deliver)
            {
                Caption = 'Deliver Substitute';
                ApplicationArea = All;
                Image = Delivery;
                trigger OnAction()
                var
                    SubMgt: Codeunit "KINTO Substitution Mgt.";
                begin
                    SubMgt.DeliverSubstitution(Rec);
                    CurrPage.Update(true);
                end;
            }
            action(Complete)
            {
                Caption = 'Complete (definitive)';
                ApplicationArea = All;
                Image = Close;
                trigger OnAction()
                var
                    SubMgt: Codeunit "KINTO Substitution Mgt.";
                begin
                    SubMgt.CompleteSubstitution(Rec);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}
