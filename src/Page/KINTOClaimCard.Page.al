page 50477 "KINTO Claim"
{
    Caption = 'Claim';
    PageType = Card;
    SourceTable = "KINTO Claim";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Claim No."; Rec."Claim No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Policy No."; Rec."Policy No.") { ApplicationArea = All; }
                field("Claim Class"; Rec."Claim Class") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = StatusStyle; }
                field("Claim Date"; Rec."Claim Date") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
            group(Classification)
            {
                Caption = 'Classification (5 tracks)';
                field("Market Value"; Rec."Market Value") { ApplicationArea = All; }
                field("Damage Amount"; Rec."Damage Amount") { ApplicationArea = All; }
                field("Loss Ratio %"; Rec."Loss Ratio %") { ApplicationArea = All; }
                field("Total Destruction"; Rec."Total Destruction") { ApplicationArea = All; Style = Strong; }
            }
            group(Financial)
            {
                Caption = 'Financial';
                field("Deductible Amount"; Rec."Deductible Amount") { ApplicationArea = All; }
                field("Indemnity Amount"; Rec."Indemnity Amount") { ApplicationArea = All; }
                field("FA Written Off"; Rec."FA Written Off") { ApplicationArea = All; }
                field("Settlement No."; Rec."Settlement No.") { ApplicationArea = All; }
            }
            group(Insurer)
            {
                Caption = 'Insurer';
                field("Insurer Claim No."; Rec."Insurer Claim No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Classify)
            {
                Caption = 'Classify (loss ratio)';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                var
                    ClaimMgt: Codeunit "KINTO Claim Management";
                begin
                    ClaimMgt.ClassifyClaim(Rec, Rec."Market Value", Rec."Damage Amount");
                    CurrPage.Update(true);
                end;
            }
            action(SendToInsurer)
            {
                Caption = 'Send to Insurer';
                ApplicationArea = All;
                Image = SendMail;
                trigger OnAction()
                var
                    ClaimMgt: Codeunit "KINTO Claim Management";
                begin
                    ClaimMgt.SendToInsurer(Rec, Rec."Insurer Claim No.");
                    CurrPage.Update(true);
                end;
            }
            action(Decision)
            {
                Caption = 'Record Insurer Decision';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                var
                    ClaimMgt: Codeunit "KINTO Claim Management";
                begin
                    ClaimMgt.RecordInsurerDecision(Rec, Rec.Status = Rec.Status::Approved, Rec."Indemnity Amount");
                    CurrPage.Update(true);
                end;
            }
            action(Payment)
            {
                Caption = 'Register Payment';
                ApplicationArea = All;
                Image = Payment;
                trigger OnAction()
                var
                    ClaimMgt: Codeunit "KINTO Claim Management";
                begin
                    ClaimMgt.RegisterPayment(Rec);
                    CurrPage.Update(true);
                end;
            }
        }
        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(Classify_P; Classify) { }
                actionref(SendToInsurer_P; SendToInsurer) { }
                actionref(Decision_P; Decision) { }
                actionref(Payment_P; Payment) { }
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Approved, Rec.Status::Paid:
                StatusStyle := 'Favorable';
            Rec.Status::Denied:
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
