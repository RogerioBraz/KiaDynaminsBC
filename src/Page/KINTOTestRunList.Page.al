page 50187 "KINTO Test Run List"
{
    Caption = 'KINTO Test Runs';
    PageType = List;
    SourceTable = "KINTO Test Run Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Run DateTime"; Rec."Run DateTime") { ApplicationArea = All; }
                field("Test Name"; Rec."Test Name") { ApplicationArea = All; }
                field(Result; Rec.Result) { ApplicationArea = All; StyleExpr = ResultStyle; }
                field("Result Message"; Rec."Result Message") { ApplicationArea = All; }
                field("Duration (ms)"; Rec."Duration (ms)") { ApplicationArea = All; }
                field("Run By"; Rec."Run By") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunAllTests)
            {
                Caption = 'Run All Tests';
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                var
                    TestRunner: Codeunit "KINTO Test Runner";
                    ConfirmQst: Label 'Run all KINTO tests? This creates demo data (quotes, contracts, fines, returns).';
                begin
                    if not Confirm(ConfirmQst) then
                        exit;
                    TestRunner.RunAllTests();
                    CurrPage.Update(false);
                end;
            }
            action(RunDemoLoad)
            {
                Caption = 'Run Demo Data Load';
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                var
                    DemoLoad: Codeunit "KINTO Demo Data Load";
                    ConfirmQst: Label 'Run the demo data load (6 scenarios)?';
                begin
                    if not Confirm(ConfirmQst) then
                        exit;
                    Message(DemoLoad.LoadDemoData());
                    CurrPage.Update(false);
                end;
            }
            action(ShowWorkflowCommands)
            {
                Caption = 'Workflow Commands';
                ApplicationArea = All;
                Image = Task;
                RunObject = page "KINTO Pricing Workflow API";
                trigger OnAction() begin end;
            }
            action(ShowJobQueue)
            {
                Caption = 'Job Queue Entries';
                ApplicationArea = All;
                Image = BulletList;
                RunObject = page "Job Queue Entries";
                trigger OnAction() begin end;
            }
            action(ClearResults)
            {
                Caption = 'Clear Results';
                ApplicationArea = All;
                Image = Clear;
                trigger OnAction()
                var
                    Entry: Record "KINTO Test Run Entry";
                    ConfirmQst: Label 'Clear all test results?';
                begin
                    if not Confirm(ConfirmQst) then
                        exit;
                    Entry.DeleteAll();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(RunAllTests_Promoted; RunAllTests) { }
                actionref(RunDemoLoad_Promoted; RunDemoLoad) { }
            }
            group(View)
            {
                Caption = 'View';
                actionref(ShowWorkflowCommands_Promoted; ShowWorkflowCommands) { }
                actionref(ShowJobQueue_Promoted; ShowJobQueue) { }
            }
        }
    }

    var
        ResultStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Result of
            Rec.Result::Passed:
                ResultStyle := 'Favorable';
            Rec.Result::Failed, Rec.Result::Error:
                ResultStyle := 'Unfavorable';
            else
                ResultStyle := 'Standard';
        end;
    end;
}
