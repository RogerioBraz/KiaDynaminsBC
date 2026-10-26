codeunit 50207 "KINTO Workflow Command Runner"
{
    TableNo = "Job Queue Entry";

    Permissions = tabledata "KINTO Workflow Command" = RIMD,
                  tabledata "KINTO Quote Header" = RIMD,
                  tabledata "KINTO Quote Item" = RIMD,
                  tabledata "KINTO Cash Flow Data" = RIMD,
                  tabledata "KINTO Cash Flow Header" = RIMD,
                  tabledata "KINTO Simulation Snapshot" = RIMD,
                  tabledata "KINTO Country Setup" = R,
                  tabledata "KINTO RV Matrix" = R,
                  tabledata "KINTO Vehicle Contract" = RIMD,
                  tabledata "KINTO Contract Condition" = RIMD,
                  tabledata "KINTO Billing Line" = RIMD,
                  tabledata "KINTO Financial Product" = RIMD,
                  tabledata "KINTO Contract Change Log" = RIMD,
                  tabledata "Sales Header" = RIMD,
                  tabledata "Sales Line" = RIMD,
                  tabledata "Job Queue Entry" = RIMD,
                  tabledata "Job Queue Category" = RIMD;

    // Executa comandos pendentes em background session (Job Queue).
    // TableNo = Job Queue Entry — o JQ passa o PRÓPRIO JQ Entry ao OnRun
    // (Record(472) is not compatible with Codeunit.Run(Record(50410)) = TableNo errado).
    // O OnRun varre TODAS as commands pendentes e executa uma a uma.

    trigger OnRun()
    var
        Command: Record "KINTO Workflow Command";
        Processed: Integer;
        Failed: Integer;
        PricingContext: Codeunit "KINTO Pricing Context";
        LastError: Text;
    begin
        // Contexto programático: guards de status desativados durante o runner
        PricingContext.BeginPricing();
        // Rec = Job Queue Entry (passado pelo JQ) — não usamos seus campos,
        // apenas rodamos a varredura das commands pendentes.
        Command.SetFilter("Pending Command", '<>%1', Command."Pending Command"::" ");
        if Command.FindSet() then
            repeat
                Clear(LastError);
                if TryExecuteCommand(Command, Command."Pending Command") then
                    Processed += 1
                else begin
                    Failed += 1;
                    // Erro capturado: grava no Result Message em vez de abortar o JQ
                    SetResult(Command, false, 'ERROR: ' + GetLastErrorText());
                end;
            until Command.Next() = 0;

        // Sem comandos pendentes: execução vazia (JQ recorrente normal)
        PricingContext.EndPricing();
    end;

    [TryFunction]
    local procedure TryExecuteCommand(var Command: Record "KINTO Workflow Command"; CommandType: Enum "KINTO Command Type")
    begin
        ExecuteCommand(Command, CommandType);
    end;

    local procedure ExecuteCommand(var Command: Record "KINTO Workflow Command"; CommandType: Enum "KINTO Command Type"): Boolean
    var
        Quote: Record "KINTO Quote Header";
        Engine: Codeunit "KINTO Pricing Engine Mgt.";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        Contract: Record "KINTO Vehicle Contract";
        DebugLog: Text;
    begin
        if not Quote.Get(Command."Quote No.") then begin
            SetResult(Command, false, 'Quote not found');
            exit(false);
        end;

        case CommandType of
            CommandType::RunPricing:
                begin
                    // DEBUG: status ANTES do engine
                    DebugLog := 'BEFORE: ' + Format(Quote."Pricing Status") + ' fee=' + Format(Quote."Calculated Monthly Fee") + ' | ';
                    Engine.RunPricing(Quote);
                    Quote.Get(Quote."Quote No.");
                    // DEBUG: status DEPOIS do engine (re-lido do banco)
                    DebugLog += 'AFTER: ' + Format(Quote."Pricing Status") + ' fee=' + Format(Quote."Calculated Monthly Fee") + ' roi=' + Format(Quote."Calculated ROI");
                    Command."Pricing Status" := Quote."Pricing Status";
                    Command."Approval Classification" := Quote."Approval Classification";
                    Command."Calculated Monthly Fee" := Quote."Calculated Monthly Fee";
                    Command."KINTO IRR" := Quote."KINTO IRR";
                    Command."Calculated ROI" := Quote."Calculated ROI";
                    Command.EBT := Quote.EBT;
                    SetResult(Command, true, DebugLog + ' → Pricing calculated');
                end;
            CommandType::Approve:
                begin
                    Quote."Pricing Status" := Quote."Pricing Status"::Approved;
                    Quote.Modify(true);
                    Quote.Get(Quote."Quote No.");
                    Command."Pricing Status" := Quote."Pricing Status";
                    SetResult(Command, true, 'Quote approved');
                end;
            CommandType::CreateContract:
                begin
                    Command."Created Contract No." := BillingMgt.CreateContractFromQuote(Quote);
                    SetResult(Command, true, 'Contract ' + Command."Created Contract No." + ' created');
                end;
            CommandType::GenerateBilling:
                begin
                    Contract.SetRange("Quote No.", Quote."Quote No.");
                    if Contract.FindFirst() then begin
                        // Integração/demo: contrato criado pela API nasce Draft
                        // (ativação UI exige Vehicle No. de veículo usado) — ativa aqui
                        if Contract.Status = Contract.Status::Draft then begin
                            Contract.Status := Contract.Status::Active;
                            Contract.Modify(true);
                        end;
                        BillingMgt.GenerateBillingForContract(Contract, CalcDate('<-CM>', WorkDate()));
                        SetResult(Command, true, 'Billing generated for ' + Contract."Contract No.");
                    end else begin
                        SetResult(Command, false, 'Contract not found for quote');
                        exit(false);
                    end;
                end;
        end;
        exit(true);
    end;

    local procedure SetLog(var Command: Record "KINTO Workflow Command"; Msg: Text)
    begin
        Command."Result Message" := CopyStr(Msg, 1, MaxStrLen(Command."Result Message"));
        Command."Last Run DateTime" := CurrentDateTime;
        Command.Modify(true);
    end;

    local procedure SetResult(var Command: Record "KINTO Workflow Command"; Ok: Boolean; Msg: Text)
    begin
        Command."Pending Command" := Command."Pending Command"::" ";
        Command."Result Message" := CopyStr(Msg, 1, MaxStrLen(Command."Result Message"));
        Command."Last Run DateTime" := CurrentDateTime;
        Command.Modify(true);
    end;
}
