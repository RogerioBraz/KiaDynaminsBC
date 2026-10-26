page 50456 "KINTO Fleet Closing Snapshot List"
{
    Caption = 'Fleet Closing Snapshots';
    PageType = List;
    SourceTable = "KINTO Fleet Closing Snapshot";
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
                field("Closing Month"; Rec."Closing Month") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field(VIN; Rec.VIN) { ApplicationArea = All; }
                field("Vehicle Status"; Rec."Vehicle Status") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Odometer"; Rec."Odometer") { ApplicationArea = All; }
                field("Device No."; Rec."Device No.") { ApplicationArea = All; }
                field("Active Policy No."; Rec."Active Policy No.") { ApplicationArea = All; }
                field("Monthly Billing Amount"; Rec."Monthly Billing Amount") { ApplicationArea = All; }
                field(Reconciled; Rec.Reconciled) { ApplicationArea = All; StyleExpr = ReconStyle; }
                field("Reconcile Issue"; Rec."Reconcile Issue") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunClosing)
            {
                Caption = 'Run Monthly Closing';
                ApplicationArea = All;
                Image = Close;
                trigger OnAction()
                var
                    FleetMgt: Codeunit "KINTO Fleet Management";
                    CountryCode: Code[10];
                    ClosingMonth: Date;
                begin
                    ClosingMonth := CalcDate('<-CM>', WorkDate());
                    CountryCode := 'BR'; // default — dialog em versão futura
                    FleetMgt.RunMonthlyClosing(ClosingMonth, CountryCode);
                    CurrPage.Update(false);
                    Message('Monthly closing completed for %1.', CountryCode);
                end;
            }
        }
    }

    var
        ReconStyle: Text;

    trigger OnAfterGetRecord()
    begin
        if Rec.Reconciled then
            ReconStyle := 'Favorable'
        else
            ReconStyle := 'Unfavorable';
    end;
}
