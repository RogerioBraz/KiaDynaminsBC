page 50186 "KINTO Test Management"
{
    Caption = 'KINTO Test Management';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Summary)
            {
                Caption = 'Summary';
                field(TotalRuns; TotalRuns) { ApplicationArea = All; Caption = 'Total Runs'; Editable = false; }
                field(TotalPassed; TotalPassed) { ApplicationArea = All; Caption = 'Passed'; Editable = false; Style = Favorable; }
                field(TotalFailed; TotalFailed) { ApplicationArea = All; Caption = 'Failed'; Editable = false; Style = Unfavorable; }
                field(LastRun; LastRun) { ApplicationArea = All; Caption = 'Last Run'; Editable = false; }
            }
            group(About)
            {
                Caption = 'About';
                field(AboutText; AboutText) { ApplicationArea = All; Caption = 'About'; Editable = false; MultiLine = true; }
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
                    UpdateSummary();
                    Message('Tests completed. Check the Test Runs list for details.');
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
                    UpdateSummary();
                end;
            }
            action(ShowTestRuns)
            {
                Caption = 'Test Runs';
                ApplicationArea = All;
                Image = List;
                RunObject = page "KINTO Test Run List";
                trigger OnAction() begin end;
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
            action(ShowRoleCenter)
            {
                Caption = 'KINTO Role Center';
                ApplicationArea = All;
                Image = Navigate;
                RunObject = page "KINTO Pricing Role Center";
                trigger OnAction() begin end;
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
                actionref(ShowTestRuns_Promoted; ShowTestRuns) { }
                actionref(ShowWorkflowCommands_Promoted; ShowWorkflowCommands) { }
                actionref(ShowJobQueue_Promoted; ShowJobQueue) { }
            }
        }
    }

    var
        TotalRuns: Integer;
        TotalPassed: Integer;
        TotalFailed: Integer;
        LastRun: DateTime;
        AboutText: Text;

    trigger OnOpenPage()
    begin
        AboutText := 'KINTO Test Management\' +
            'Run All Tests: executa os 18 testes do KiaDynBC Test (6 E2E + 12 unit).\' +
            'Run Demo Data Load: cria os 6 cenários de demonstração (contratos, multas, tickets, devoluções).\' +
            'Workflow Commands: fila de comandos de integração (runPricing, approve, createContract, generateBilling).\' +
            'Job Queue: fila que executa os comandos em background.';
        UpdateSummary();
    end;

    local procedure UpdateSummary()
    var
        Entry: Record "KINTO Test Run Entry";
    begin
        Entry.Reset();
        if Entry.FindSet() then begin
            TotalRuns := Entry.Count();
            repeat
                if Entry.Result = Entry.Result::Passed then
                    TotalPassed += 1
                else if Entry.Result in [Entry.Result::Failed, Entry.Result::Error] then
                    TotalFailed += 1;
            until Entry.Next() = 0;
            LastRun := Entry."Run DateTime";
        end else begin
            TotalRuns := 0;
            TotalPassed := 0;
            TotalFailed := 0;
            LastRun := 0DT;
        end;
    end;
}
