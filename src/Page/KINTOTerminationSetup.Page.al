page 50405 "KINTO Termination Setup"
{
    Caption = 'KINTO Termination Setup';
    PageType = Card;
    SourceTable = "KINTO Termination Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Return Nos."; Rec."Return Nos.") { ApplicationArea = All; }
                field("Recovery Nos."; Rec."Recovery Nos.") { ApplicationArea = All; }
                field("Cautelar Required"; Rec."Cautelar Required") { ApplicationArea = All; }
                field("Return Odometer Tolerance"; Rec."Return Odometer Tolerance") { ApplicationArea = All; }
            }
            group(Damages)
            {
                Caption = 'Damages';
                field("Damage Charge Account"; Rec."Damage Charge Account") { ApplicationArea = All; }
                field("Damage Approval Threshold"; Rec."Damage Approval Threshold") { ApplicationArea = All; }
            }
            group(Recovery)
            {
                Caption = 'Recovery Risk Rules';
                field("Recovery Low Risk Days"; Rec."Recovery Low Risk Days") { ApplicationArea = All; }
                field("Recovery Medium Risk Days"; Rec."Recovery Medium Risk Days") { ApplicationArea = All; }
                field("Recovery Block Days"; Rec."Recovery Block Days") { ApplicationArea = All; }
            }
            group(Dealer)
            {
                Caption = 'Dealer Charges';
                field("Default Dealer Vendor No."; Rec."Default Dealer Vendor No.") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert(true);
        end;
    end;
}