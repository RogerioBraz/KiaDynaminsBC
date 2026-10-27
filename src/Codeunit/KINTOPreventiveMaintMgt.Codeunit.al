codeunit 60000 "KINTO Preventive Maint. Mgt."
{
    // ============================================================
    // D1 — MANUTENCAO PREVENTIVA AUTOMATICA
    // 1) Gera tickets preventivos por plano (km e/ou data) nos
    //    contratos ativos, respeitando tolerancia e lead time.
    // 2) Processa eventos telematicos pendentes -> ticket corretivo.
    // Idempotente: usa "Next Preventive Date/Odometer" do contrato
    // e marca o evento como processado.
    // ============================================================

    procedure GeneratePreventiveTickets(AsOfDate: Date): Integer
    var
        Contract: Record "KINTO Vehicle Contract";
        Vehicle: Record "KINTO Inventory Vehicle";
        PlanHeader: Record "KINTO Maintenance Plan Header";
        PlanLine: Record "KINTO Maintenance Plan Line";
        MaintMgt: Codeunit "KINTO Maintenance Management";
        Created: Integer;
        DueKm: Decimal;
        DueDate: Date;
        TicketNo: Code[20];
    begin
        Contract.Reset();
        Contract.SetRange(Status, Contract.Status::Active);
        Contract.SetFilter("Maintenance Plan ID", '<>%1', '');
        if Contract.FindSet() then
            repeat
                if PlanHeader.Get(Contract."Maintenance Plan ID") and
                   PlanHeader."Preventive Enabled" and
                   Vehicle.Get(Contract."Vehicle No.") then begin
                    // PlanLine PRECISA estar carregado: ScheduleNext usa o KM
                    // Interval dele para avancar o proximo odometro. Sem isso o
                    // intervalo vinha 0 e o contrato voltava a ser devido no
                    // MESMO odometro na execucao seguinte.
                    LoadPlanLine(PlanHeader, PlanLine);
                    if IsPreventiveDue(Contract, Vehicle, PlanHeader, PlanLine, AsOfDate, DueKm, DueDate) and
                       not HasOpenPreventiveTicket(Contract."Contract No.") then begin
                        TicketNo := MaintMgt.CreateTicketFromContract(Contract."Contract No.",
                            "KINTO Maint Ticket Type"::Preventive,
                            StrSubstNo('Preventive service (plan %1, interval %2 km)', PlanHeader."Plan ID", PlanLine."KM Interval"),
                            AsOfDate, Vehicle."Current Odometer");
                        if TicketNo <> '' then begin
                            Contract."Last Preventive Date" := AsOfDate;
                            Contract."Last Preventive Odometer" := Vehicle."Current Odometer";
                            ScheduleNext(Contract, PlanHeader, PlanLine);
                            Contract.Modify(true);
                            Created += 1;
                        end;
                    end;
                end;
            until Contract.Next() = 0;
        exit(Created);
    end;



    // Carrega a linha do plano (menor intervalo de km > 0). Idempotente: se ja
    // estiver carregada para este plano, nao recarrega.
    local procedure LoadPlanLine(var PlanHeader: Record "KINTO Maintenance Plan Header";
        var PlanLine: Record "KINTO Maintenance Plan Line")
    var
        Line: Record "KINTO Maintenance Plan Line";
    begin
        if (PlanLine."Plan ID" = PlanHeader."Plan ID") and (PlanLine."KM Interval" > 0) then
            exit;
        Line.Reset();
        Line.SetRange("Plan ID", PlanHeader."Plan ID");
        Line.SetFilter("KM Interval", '>0');
        Line.SetCurrentKey("KM Interval");
        if Line.FindFirst() then
            PlanLine := Line
        else
            PlanLine.Reset();
    end;

    // Idempotencia real: ja existe ticket preventivo em aberto para o contrato?
    // Sem esta guarda, a mesma preventive pode gerar um ticket novo a cada
    // execucao do job (o reagendamento sozinho nao garante, porque o job
    // processa todos os contratos e roda varias vezes ao dia).
    local procedure HasOpenPreventiveTicket(ContractNo: Code[20]): Boolean
    var
        Ticket: Record "KINTO Maintenance Ticket";
    begin
        Ticket.SetRange("Contract No.", ContractNo);
        Ticket.SetRange("Ticket Type", Ticket."Ticket Type"::Preventive);
        Ticket.SetFilter(Status, '%1|%2|%3|%4',
            Ticket.Status::Open, Ticket.Status::"In Analysis",
            Ticket.Status::"In Execution", Ticket.Status::"Pending Approval");
        exit(not Ticket.IsEmpty());
    end;

    local procedure IsPreventiveDue(var Contract: Record "KINTO Vehicle Contract"; var Vehicle: Record "KINTO Inventory Vehicle";
        var PlanHeader: Record "KINTO Maintenance Plan Header"; var PlanLine: Record "KINTO Maintenance Plan Line";
        AsOfDate: Date; var DueKm: Decimal; var DueDate: Date): Boolean
    var
        NextKm: Decimal;
        Tolerance: Decimal;
    begin
        // Primeiro ciclo: parte do odometro atual / data de inicio do contrato
        if Contract."Next Preventive Odometer" = 0 then begin
            NextKm := GetNextIntervalKm(PlanHeader, PlanLine, Vehicle."Current Odometer");
            if NextKm = 0 then
                exit(false);
            Contract."Next Preventive Odometer" := NextKm;
            Contract."Next Preventive Date" := GetNextIntervalDate(PlanHeader, PlanLine, AsOfDate);
        end;

        Tolerance := PlanHeader."Odometer Tolerance (km)";
        DueKm := Contract."Next Preventive Odometer";
        DueDate := Contract."Next Preventive Date";

        // Devido por km (com tolerancia) ou por data limite
        if (DueKm > 0) and (Vehicle."Current Odometer" >= (DueKm - Tolerance)) then
            exit(true);
        if (DueDate <> 0D) and (AsOfDate >= DueDate) then
            exit(true);
        exit(false);
    end;

    local procedure ScheduleNext(var Contract: Record "KINTO Vehicle Contract";
        var PlanHeader: Record "KINTO Maintenance Plan Header"; var PlanLine: Record "KINTO Maintenance Plan Line")
    begin
        if PlanLine."KM Interval" > 0 then
            Contract."Next Preventive Odometer" := Contract."Last Preventive Odometer" + PlanLine."KM Interval";
        Contract."Next Preventive Date" := CalcDate(StrSubstNo('<+%1M>', GetIntervalMonths(Contract."Country Code")), Contract."Last Preventive Date");
    end;

    local procedure GetNextIntervalKm(var PlanHeader: Record "KINTO Maintenance Plan Header";
        var PlanLine: Record "KINTO Maintenance Plan Line"; CurrentOdometer: Decimal): Decimal
    var
        Interval: Decimal;
    begin
        // Menor intervalo de km do plano acima do odometro atual.
        // ATENCAO: "KM Interval" e o intervalo (10.000), NAO um odometro absoluto —
        // comparar com o odometro aqui escolhia sempre a mesma linha e o
        // reagendamento nao avancava (Next Preventive Odometer repetia).
        PlanLine.Reset();
        PlanLine.SetRange("Plan ID", PlanHeader."Plan ID");
        PlanLine.SetFilter("KM Interval", '>0');
        if PlanLine.FindFirst() then begin
            Interval := PlanLine."KM Interval";
            // proximo multiplo do intervalo acima do odometro atual
            exit((Round(CurrentOdometer / Interval, 1, '>') + 1) * Interval);
        end;
        exit(0);
    end;

    local procedure GetNextIntervalDate(var PlanHeader: Record "KINTO Maintenance Plan Header";
        var PlanLine: Record "KINTO Maintenance Plan Line"; AsOfDate: Date): Date
    begin
        exit(CalcDate(StrSubstNo('<+%1M>', GetIntervalMonths('')), AsOfDate));
    end;

    // ============================================================
    // GATILHO TELEMATICO -> TICKET CORRETIVO
    // ============================================================
    procedure ProcessTelematicEvents(AsOfDate: Date): Integer
    var
        TelematicEvent: Record "KINTO Telematic Event";
        Contract: Record "KINTO Vehicle Contract";
        MaintMgt: Codeunit "KINTO Maintenance Management";
        Processed: Integer;
        TicketNo: Code[20];
        Description: Text[250];
    begin
        TelematicEvent.Reset();
        TelematicEvent.SetRange("Ticket Created", false);
        TelematicEvent.SetFilter("Ticket No.", '');
        if TelematicEvent.FindSet() then
            repeat
                if TelematicEvent."Event Trigger" <> TelematicEvent."Event Trigger"::None then begin
                    // Contrato ativo do veiculo
                    Contract.Reset();
                    Contract.SetRange("Vehicle No.", TelematicEvent."Vehicle No.");
                    Contract.SetRange(Status, Contract.Status::Active);
                    if not Contract.FindFirst() then begin
                        TelematicEvent."Processed DateTime" := CurrentDateTime;
                        TelematicEvent."Process Error" := 'No active contract for vehicle';
                        TelematicEvent.Modify(false);
                    end else begin
                        Description := StrSubstNo('Telematic trigger %1 (code %2) - vehicle %3',
                            TelematicEvent."Event Trigger", TelematicEvent."Fault Code", TelematicEvent."Vehicle No.");
                        TicketNo := MaintMgt.CreateTicketFromContract(Contract."Contract No.",
                            "KINTO Maint Ticket Type"::Corrective, Description, AsOfDate, TelematicEvent."Odometer (km)");
                        if TicketNo <> '' then begin
                            TelematicEvent."Ticket Created" := true;
                            TelematicEvent."Ticket No." := TicketNo;
                            Processed += 1;
                        end;
                        TelematicEvent."Processed DateTime" := CurrentDateTime;
                        TelematicEvent.Modify(false);
                    end;
                end;
            until TelematicEvent.Next() = 0;
        exit(Processed);
    end;

    // Intervalo padrao de preventiva em meses (Country Setup, default 6)
    local procedure GetIntervalMonths(CountryCode: Code[10]): Integer
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CountrySetup.GetForCompanyOr(CountryCode) then
            if CountrySetup."Preventive Interval Months" > 0 then
                exit(CountrySetup."Preventive Interval Months");
        exit(6);
    end;
}
