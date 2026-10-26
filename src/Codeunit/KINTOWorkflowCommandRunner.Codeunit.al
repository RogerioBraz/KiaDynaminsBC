codeunit 50207 "KINTO Workflow Command Runner"
{
    TableNo = "KINTO Workflow Command";

    // Executa comandos pendentes em SEPARATE session (via Task Scheduler) —
    // gravações em outras tabelas persistem fora da transação do PATCH.

    trigger OnRun()
    var
        Command: Record "KINTO Workflow Command";
        Processed: Integer;
    begin
        // Via Job Queue (sem record): varre TODAS as commands pendentes
        // (o JQ Entry roda o codeunit sem record — Rec é default vazio)
        if Rec."Quote No." <> '' then begin
            // chamado com record específico (futuro)
            if Rec."Pending Command" <> Rec."Pending Command"::" " then
                ExecuteCommand(Rec, Rec."Pending Command");
            exit;
        end;

        Command.SetFilter("Pending Command", '<>%1', Command."Pending Command"::" ");
        if Command.FindSet() then
            repeat
                ExecuteCommand(Command, Command."Pending Command");
                Processed += 1;
            until Command.Next() = 0;
    end;

    local procedure ExecuteCommand(var Command: Record "KINTO Workflow Command"; CommandType: Enum "KINTO Command Type")
    var
        Quote: Record "KINTO Quote Header";
        Engine: Codeunit "KINTO Pricing Engine Mgt.";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        Contract: Record "KINTO Vehicle Contract";
        Ok: Boolean;
    begin
        if not Quote.Get(Command."Quote No.") then begin
            SetResult(Command, CommandType, false, 'Quote not found');
            exit;
        end;

        case CommandType of
            CommandType::RunPricing:
                begin
                    Engine.RunPricing(Quote);
                    Quote.Get(Quote."Quote No.");
                    Command."Pricing Status" := Quote."Pricing Status";
                    Command."Approval Classification" := Quote."Approval Classification";
                    Command."Calculated Monthly Fee" := Quote."Calculated Monthly Fee";
                    Command."KINTO IRR" := Quote."KINTO IRR";
                    Command."Calculated ROI" := Quote."Calculated ROI";
                    Command.EBT := Quote.EBT;
                    SetResult(Command, CommandType, true, 'Pricing calculated');
                end;
            CommandType::Approve:
                begin
                    Quote."Pricing Status" := Quote."Pricing Status"::Approved;
                    Quote.Modify(true);
                    Quote.Get(Quote."Quote No.");
                    Command."Pricing Status" := Quote."Pricing Status";
                    SetResult(Command, CommandType, true, 'Quote approved');
                end;
            CommandType::CreateContract:
                begin
                    Command."Created Contract No." := BillingMgt.CreateContractFromQuote(Quote);
                    SetResult(Command, CommandType, true, 'Contract ' + Command."Created Contract No." + ' created');
                end;
            CommandType::GenerateBilling:
                begin
                    Contract.SetRange("Quote No.", Quote."Quote No.");
                    if Contract.FindFirst() then begin
                        BillingMgt.GenerateBillingForContract(Contract, CalcDate('<-CM>', WorkDate()));
                        SetResult(Command, CommandType, true, 'Billing generated for ' + Contract."Contract No.");
                    end else
                        SetResult(Command, CommandType, false, 'Contract not found for quote');
                end;
        end;
    end;

    local procedure SetResult(var Command: Record "KINTO Workflow Command"; CommandType: Enum "KINTO Command Type"; Ok: Boolean; Msg: Text)
    begin
        Command."Pending Command" := Command."Pending Command"::" ";
        Command."Result Message" := CopyStr(Msg, 1, MaxStrLen(Command."Result Message"));
        Command."Last Run DateTime" := CurrentDateTime;
        Command.Modify(true);
    end;
}
