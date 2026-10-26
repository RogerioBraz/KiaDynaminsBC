table 50410 "KINTO Workflow Command"
{
    Caption = 'KINTO Workflow Command';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Pricing Workflow API";
    DrillDownPageId = "KINTO Pricing Workflow API";

    // Padrão command/request p/ integração REST: a API page opera sobre ESTA tabela.
    // OnValidate GRAVA o comando e agenda uma Task (Task Scheduler) — o runner
    // (codeunit 50207) executa em SEPARATE session, fora da transação do PATCH.
    // (Gravações em outras tabelas dentro do OnValidate de API page NÃO persistem —
    // comprovado 26/10: command persiste, Quote Header não.)

    fields
    {
        field(1; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            TableRelation = "KINTO Quote Header";

            trigger OnValidate()
            var
                Quote: Record "KINTO Quote Header";
            begin
                if not Quote.Get("Quote No.") then
                    Error(QuoteNotFoundErr, "Quote No.");
            end;
        }
        field(2; "Run Pricing Trigger"; Boolean)
        {
            Caption = 'Run Pricing Trigger (integration)';

            trigger OnValidate()
            begin
                if "Run Pricing Trigger" then
                    EnqueueCommand("Command Type"::RunPricing);
            end;
        }
        field(3; "Approve Quote Trigger"; Boolean)
        {
            Caption = 'Approve Quote Trigger (integration)';

            trigger OnValidate()
            begin
                if "Approve Quote Trigger" then
                    EnqueueCommand("Command Type"::Approve);
            end;
        }
        field(4; "Create Contract Trigger"; Boolean)
        {
            Caption = 'Create Contract Trigger (integration)';

            trigger OnValidate()
            begin
                if "Create Contract Trigger" then
                    EnqueueCommand("Command Type"::CreateContract);
            end;
        }
        field(5; "Generate Billing Trigger"; Boolean)
        {
            Caption = 'Generate Billing Trigger (integration)';

            trigger OnValidate()
            begin
                if "Generate Billing Trigger" then
                    EnqueueCommand("Command Type"::GenerateBilling);
            end;
        }
        field(10; "Pricing Status"; Enum "KINTO Pricing Status") { Caption = 'Quote Pricing Status'; Editable = false; }
        field(11; "Approval Classification"; Enum "KINTO Approval Classification") { Caption = 'Approval Classification'; Editable = false; }
        field(12; "Calculated Monthly Fee"; Decimal) { Caption = 'Calculated Monthly Fee'; Editable = false; DecimalPlaces = 2 : 2; }
        field(13; "KINTO IRR"; Decimal) { Caption = 'KINTO IRR'; Editable = false; DecimalPlaces = 0 : 10; }
        field(14; "Calculated ROI"; Decimal) { Caption = 'Calculated ROI'; Editable = false; DecimalPlaces = 0 : 10; }
        field(15; EBT; Decimal) { Caption = 'EBT'; Editable = false; DecimalPlaces = 2 : 2; }
        field(16; "Created Contract No."; Code[20]) { Caption = 'Created Contract No.'; Editable = false; }
        field(17; "Result Message"; Text[250]) { Caption = 'Result Message'; Editable = false; }
        field(18; "Last Run DateTime"; DateTime) { Caption = 'Last Run DateTime'; Editable = false; }
        field(19; "Pending Command"; Enum "KINTO Command Type") { Caption = 'Pending Command'; Editable = false; }
        field(20; "Task ID"; Guid) { Caption = 'Task ID'; Editable = false; }
    }

    keys
    {
        key(PK; "Quote No.") { Clustered = true; }
    }

    // ============================================================
    // ENFILEIRA O COMANDO + AGENDA A TASK (fora da transação do PATCH)
    // ============================================================
    local procedure EnqueueCommand(CommandType: Enum "KINTO Command Type")
    var
        TaskID: Guid;
    begin
        "Pending Command" := CommandType;
        "Result Message" := CopyStr(StrSubstNo('Queued %1 at %2', CommandType, Format(CurrentDateTime, 0, 9)), 1, MaxStrLen("Result Message"));
        "Last Run DateTime" := CurrentDateTime;
        // reseta o gatilho (o PATCH já gravou true; gravamos false no mesmo modify)
        case CommandType of
            "Command Type"::RunPricing:
                "Run Pricing Trigger" := false;
            "Command Type"::Approve:
                "Approve Quote Trigger" := false;
            "Command Type"::CreateContract:
                "Create Contract Trigger" := false;
            "Command Type"::GenerateBilling:
                "Generate Billing Trigger" := false;
        end;
        Modify(true);

        // Agenda o runner em SEPARATE session (roda após o commit do PATCH)
        ScheduleTask(CommandType);
    end;

    local procedure ScheduleTask(CommandType: Enum "KINTO Command Type")
    var
        TaskScheduler: Codeunit "Task Scheduler";
        TaskID: Guid;
        TaskRecord: Record "KINTO Workflow Command";
    begin
        // Cancela task anterior pendente desta cotação
        if ("Task ID" <> NullGuid) then begin
            TaskScheduler.CancelTask("Task ID");
            "Task ID" := NullGuid;
        end;

        // CreateTask passa o record ao OnRun (TableNo = command) em background session
        TaskRecord := Rec;
        TaskRecord."Pending Command" := CommandType;
        TaskID := TaskScheduler.CreateTask(Codeunit::"KINTO Workflow Command Runner", 0, false, CompanyName(), CurrentDateTime + 100, TaskRecord);
        "Task ID" := TaskID;
        Modify(true);
    end;

    var
        QuoteNotFoundErr: Label 'Quote %1 does not exist.';
        NullGuid: Guid;
}
