page 50200 "KINTO Vehicle Contract Card"
{
    Caption = 'KINTO Vehicle Contract Card';
    PageType = Card;
    SourceTable = "KINTO Vehicle Contract";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; Editable = false; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Customer Name"; Rec."Customer Name") { ApplicationArea = All; }
                field("Quote No."; Rec."Quote No.") { ApplicationArea = All; Editable = false; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
            }
            group(Vehicle)
            {
                Caption = 'Vehicle';
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Fixed Asset No."; Rec."Fixed Asset No.") { ApplicationArea = All; }
                field("Monthly Mileage (km)"; Rec."Monthly Mileage (km)") { ApplicationArea = All; }
            }
            group(Terms)
            {
                Caption = 'Terms';
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("Original End Date"; Rec."Original End Date") { ApplicationArea = All; }
                field("Current End Date"; Rec."Current End Date") { ApplicationArea = All; }
                field("Contract Term (Months)"; Rec."Contract Term (Months)") { ApplicationArea = All; }
                field("Total Monthly Fee"; Rec."Total Monthly Fee") { ApplicationArea = All; }
                field("Monthly Rent"; Rec."Monthly Rent") { ApplicationArea = All; }
                field("Billing Day"; Rec."Billing Day") { ApplicationArea = All; }
            }
            group(Indexation)
            {
                Caption = 'Indexation';
                field("Price Index Code"; Rec."Price Index Code") { ApplicationArea = All; }
                field("Index Frequency"; Rec."Index Frequency") { ApplicationArea = All; }
                field("Index Cap %"; Rec."Index Cap %") { ApplicationArea = All; }
            }
            group(Administration)
            {
                Caption = 'Administration';
                field("Cost Center Code"; Rec."Cost Center Code") { ApplicationArea = All; }
                field("Dimension Code"; Rec."Dimension Code") { ApplicationArea = All; }
                field("High Risk"; Rec."High Risk") { ApplicationArea = All; }
                field("Non-Operational"; Rec."Non-Operational") { ApplicationArea = All; }
                field("Legal Proceeding"; Rec."Legal Proceeding") { ApplicationArea = All; }
                field("Retention Fee Indicated"; Rec."Retention Fee Indicated") { ApplicationArea = All; }
                field("Retention Fee Amount"; Rec."Retention Fee Amount") { ApplicationArea = All; }
            }
            group(Termination)
            {
                Caption = 'Termination';
                field("Termination Type"; Rec."Termination Type") { ApplicationArea = All; }
                field("Termination Date"; Rec."Termination Date") { ApplicationArea = All; }
                field("Extension Count"; Rec."Extension Count") { ApplicationArea = All; Editable = false; }
                field("Amendment Count"; Rec."Amendment Count") { ApplicationArea = All; Editable = false; }
                field("Last Billing Month"; Rec."Last Billing Month") { ApplicationArea = All; Editable = false; }
                field("Rescission Fee %"; Rec."Rescission Fee %") { ApplicationArea = All; }
                field("Rescission Waiver Days"; Rec."Rescission Waiver Days") { ApplicationArea = All; }
            }
            group(ExcessKm)
            {
                Caption = 'Excess Mileage Pricing';
                field("Excess Km Price (up to 10%)"; Rec."Excess Km Price (up to 10%)") { ApplicationArea = All; }
                field("Excess Km Price (above 10%)"; Rec."Excess Km Price (above 10%)") { ApplicationArea = All; }
            }
            part(Conditions; "KINTO Contract Condition List")
            {
                Caption = 'Conditions';
                SubPageLink = "Contract No." = field("Contract No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActivateContract)
            {
                Caption = 'Activate';
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                begin
                    Rec.Activate();
                    CurrPage.Update(true);
                end;
            }
            action(ExtendContract)
            {
                Caption = 'Extend…';
                ApplicationArea = All;
                Image = Calendar;
                trigger OnAction()
                begin
                    if Page.RunModal(Page::"KINTO Extend Contract", Rec) = Action::OK then;
                    CurrPage.Update(true);
                end;
            }
            action(TerminateContract)
            {
                Caption = 'Terminate…';
                ApplicationArea = All;
                Image = Stop;
                trigger OnAction()
                var
                    TermType: Enum "KINTO Termination Type";
                    TermDate: Date;
                    Choice: Integer;
                begin
                    if Rec.Status in [Rec.Status::Terminated, Rec.Status::Cancelled] then
                        exit;
                    Choice := StrMenu('End of Term,Early Cancellation,Total Loss,Theft,Vehicle Substitution,Sale to Driver', 1, 'Termination type');
                    if Choice = 0 then
                        exit;
                    case Choice of
                        1:
                            TermType := TermType::"End of Term";
                        2:
                            TermType := TermType::"Early Cancellation";
                        3:
                            TermType := TermType::"Total Loss";
                        4:
                            TermType := TermType::Theft;
                        5:
                            TermType := TermType::"Vehicle Substitution";
                        6:
                            TermType := TermType::"Sale to Driver";
                    end;
                    TermDate := WorkDate();
                    Rec.Terminate(TermType, TermDate);
                    CurrPage.Update(true);
                end;
            }
            action(ChangeLog)
            {
                Caption = 'Change Log';
                ApplicationArea = All;
                Image = History;
                trigger OnAction()
                var
                    ChangeLog: Record "KINTO Contract Change Log";
                begin
                    ChangeLog.SetRange("Contract No.", Rec."Contract No.");
                    Page.Run(Page::"KINTO Contract Change Log", ChangeLog);
                end;
            }
            action(GenerateBilling)
            {
                Caption = 'Generate Monthly Billing';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
                    Month: Date;
                begin
                    Month := CalcDate('<CM>', WorkDate());
                    BillingMgt.GenerateBillingForContract(Rec, Month);
                    CurrPage.Update(true);
                end;
            }
        }
        area(Navigation)
        {
            action(BillingLines)
            {
                Caption = 'Billing Lines';
                ApplicationArea = All;
                Image = Invoice;
                RunObject = page "KINTO Billing Line List";
                RunPageLink = "Contract No." = field("Contract No.");
            }
            action(PoolLedger)
            {
                Caption = 'Pool Ledger';
                ApplicationArea = All;
                Image = Ledger;
                RunObject = page "KINTO Pool Ledger Entries";
                RunPageLink = "Contract No." = field("Contract No.");
            }
            action(Amendments)
            {
                Caption = 'Amendments';
                ApplicationArea = All;
                Image = Document;
                RunObject = page "KINTO Contract Amendment List";
                RunPageLink = "Contract No." = field("Contract No.");
            }
        }
    }
}