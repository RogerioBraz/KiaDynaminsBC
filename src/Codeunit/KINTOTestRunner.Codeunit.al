codeunit 50160 "KINTO Test Runner"
{
    // Executa os codeunits de teste do KiaDynBC Test (test app) e grava
    // cada resultado em KINTO Test Run Entry. Usa CODEUNIT.Run(ID) —
    // late binding: o app principal compila sem o test app; se ele não
    // estiver instalado, o resultado é "Test app not installed".

    var
        TestRunEntry: Record "KINTO Test Run Entry";
        CurrentTestName: Text;

    trigger OnRun()
    begin
        RunAllTests();
    end;

    procedure RunAllTests()
    var
        TestsRun: Integer;
    begin
        // Test app: codeunits de teste (IDs do KiaDynBC Test)
        RunTestCodeunit(50150, 'E2E Pricing');
        RunTestCodeunit(50151, 'E2E Contract');
        RunTestCodeunit(50152, 'E2E Billing');
        RunTestCodeunit(50153, 'E2E Fine');
        RunTestCodeunit(50154, 'E2E Maintenance');
        RunTestCodeunit(50155, 'E2E Termination');
        // Unit tests antigos (test app)
        RunTestCodeunit(50162, 'Unit Setup');
        RunTestCodeunit(50163, 'Unit Country Setup');
        RunTestCodeunit(50164, 'Unit RV Lookup');
        RunTestCodeunit(50165, 'Unit Cash Flow');
        RunTestCodeunit(50166, 'Unit Goal Seek');
        RunTestCodeunit(50167, 'Unit Pricing Engine E2E');
        RunTestCodeunit(50168, 'Unit Booking Value');
        RunTestCodeunit(50169, 'Unit Extended Analysis');
        RunTestCodeunit(50170, 'Unit Pre-Approval');
        RunTestCodeunit(50171, 'Unit Number Series');
        RunTestCodeunit(50172, 'Unit Maint Range');
        RunTestCodeunit(50173, 'Unit Package Pricing');
    end;

    local procedure RunTestCodeunit(TestCodeunitID: Integer; TestName: Text)
    var
        StartDateTime: DateTime;
        Ok: Boolean;
    begin
        StartDateTime := CurrentDateTime;
        Ok := CODEUNIT.Run(TestCodeunitID);
        TestRunEntry.LogResult(TestCodeunitID, TestName, Ok,
            GetResultMessage(Ok), CurrentDateTime - StartDateTime);
        Commit(); // isola cada teste (falha não derruba os demais)
    end;

    local procedure GetResultMessage(Ok: Boolean): Text
    begin
        if Ok then
            exit('OK');
        if GetLastErrorText() = '' then
            exit('FAILED');
        exit(CopyStr(GetLastErrorText(), 1, 250));
    end;
}
