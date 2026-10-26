codeunit 50210 "KINTO Task Chain Mgt."
{
    // D5: cadeias de tarefas por template — recuperação de inadimplentes
    // (só high risk) gera a cadeia de cobrança do template do país.

    var
        NoTemplateErr: Label 'No active task template for risk level %1 in country %2.';
        NotHighRiskErr: Label 'Task chains apply to High risk recovery cases only.';

    procedure GenerateTaskChain(RecoveryCaseNo: Code[20]): Integer
    var
        RecoveryCase: Record "KINTO Recovery Case";
        Template: Record "KINTO Task Template";
        TemplateLine: Record "KINTO Task Template Line";
        Instance: Record "KINTO Task Instance";
        Contract: Record "KINTO Vehicle Contract";
        DueDate: Date;
        Count: Integer;
    begin
        RecoveryCase.Get(RecoveryCaseNo);
        if RecoveryCase."Risk Level" <> RecoveryCase."Risk Level"::High then
            Error(NotHighRiskErr);

        Contract.Get(RecoveryCase."Contract No.");
        Template.SetRange("Risk Level Filter", RecoveryCase."Risk Level"::High);
        Template.SetRange(Active, true);
        if not Template.FindFirst() then
            Error(NoTemplateErr, RecoveryCase."Risk Level", Contract."Country Code");

        TemplateLine.SetRange("Template Code", Template."Template Code");
        TemplateLine.SetCurrentKey("Step No.");
        if TemplateLine.FindSet() then
            repeat
                if Count = 0 then
                    DueDate := WorkDate() + TemplateLine."Days After Previous"
                else
                    DueDate += TemplateLine."Days After Previous";

                Instance.Init();
                Instance."Entry No." := Instance.NextEntryNo();
                Instance."Template Code" := Template."Template Code";
                Instance."Step No." := TemplateLine."Step No.";
                Instance."Recovery Case No." := RecoveryCaseNo;
                Instance."Contract No." := RecoveryCase."Contract No.";
                Instance.Description := TemplateLine.Description;
                Instance."Due Date" := DueDate;
                Instance."Assigned To" := TemplateLine."Assigned To";
                Instance.Insert(false);
                Count += 1;
            until TemplateLine.Next() = 0;

        exit(Count);
    end;

    procedure CompleteTask(var Instance: Record "KINTO Task Instance")
    begin
        Instance.Completed := true;
        Instance."Completed Date" := WorkDate();
        Instance.Modify(true);
    end;

    procedure CreateDefaultTemplate()
    var
        Template: Record "KINTO Task Template";
        TemplateLine: Record "KINTO Task Template Line";
    begin
        if Template.Get('RECOVERY-BR') then
            exit;
        Template.Init();
        Template."Template Code" := 'RECOVERY-BR';
        Template.Description := 'Cadeia de cobrança — recuperação (BR)';
        Template."Risk Level Filter" := Template."Risk Level Filter"::High;
        Template."Country Code" := 'BR';
        Template.Insert(false);

        TemplateLine.Init();
        TemplateLine."Template Code" := 'RECOVERY-BR';
        TemplateLine."Line No." := 10000;
        TemplateLine."Step No." := 1;
        TemplateLine.Description := 'Notificação amigável (e-mail/SMS)';
        TemplateLine."Days After Previous" := 0;
        TemplateLine."Task Type" := TemplateLine."Task Type"::Notification;
        TemplateLine.Insert(false);

        TemplateLine.Init();
        TemplateLine."Template Code" := 'RECOVERY-BR';
        TemplateLine."Line No." := 20000;
        TemplateLine."Step No." := 2;
        TemplateLine.Description := 'Ligação de cobrança';
        TemplateLine."Days After Previous" := 3;
        TemplateLine."Task Type" := TemplateLine."Task Type"::Call;
        TemplateLine.Insert(false);

        TemplateLine.Init();
        TemplateLine."Template Code" := 'RECOVERY-BR';
        TemplateLine."Line No." := 30000;
        TemplateLine."Step No." := 3;
        TemplateLine.Description := 'Visita / retomada do veículo';
        TemplateLine."Days After Previous" := 5;
        TemplateLine."Task Type" := TemplateLine."Task Type"::Visit;
        TemplateLine.Insert(false);

        TemplateLine.Init();
        TemplateLine."Template Code" := 'RECOVERY-BR';
        TemplateLine."Line No." := 40000;
        TemplateLine."Step No." := 4;
        TemplateLine.Description := 'Ação legal / cobrança jurídica';
        TemplateLine."Days After Previous" := 10;
        TemplateLine."Task Type" := TemplateLine."Task Type"::Legal;
        TemplateLine.Insert(false);
    end;
}
