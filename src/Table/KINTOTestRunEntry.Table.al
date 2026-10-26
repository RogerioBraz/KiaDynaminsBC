table 50420 "KINTO Test Run Entry"
{
    Caption = 'KINTO Test Run Entry';
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Run DateTime"; DateTime) { Caption = 'Run DateTime'; }
        field(3; "Test Codeunit ID"; Integer) { Caption = 'Test Codeunit ID'; }
        field(4; "Test Name"; Text[100]) { Caption = 'Test Name'; }
        field(5; Result; Enum "KINTO Test Result") { Caption = 'Result'; }
        field(6; "Result Message"; Text[250]) { Caption = 'Result Message'; }
        field(7; "Duration (ms)"; Integer) { Caption = 'Duration (ms)'; }
        field(8; "Run By"; Code[50]) { Caption = 'Run By'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Run DateTime") { }
    }

    procedure LogResult(TestCodeunitID: Integer; TestName: Text; Ok: Boolean; Msg: Text; DurationMs: Integer)
    var
        Entry: Record "KINTO Test Run Entry";
    begin
        Entry.Init();
        Entry."Run DateTime" := CurrentDateTime;
        Entry."Test Codeunit ID" := TestCodeunitID;
        Entry."Test Name" := CopyStr(TestName, 1, MaxStrLen(Entry."Test Name"));
        if Ok then
            Entry.Result := Entry.Result::Passed
        else
            Entry.Result := Entry.Result::Failed;
        Entry."Result Message" := CopyStr(Msg, 1, MaxStrLen(Entry."Result Message"));
        Entry."Duration (ms)" := DurationMs;
        Entry."Run By" := CopyStr(UserId, 1, MaxStrLen(Entry."Run By"));
        Entry.Insert(true);
    end;
}
