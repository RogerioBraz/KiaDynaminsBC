codeunit 60007 "KINTO Demo D1-D5 Seed"
{
    // ============================================================
    // SEMENTE DE DEMONSTRACAO — features D1-D5 (28/10)
    //
    // Por que existe: o Demo Data Load (50157) cobre o ciclo comercial
    // (contrato, billing, multa, manutencao, terminacao, remarketing, portal),
    // mas NAO cria nenhum registro das features D1-D5. Consequencia: as 16
    // telas de clausulas, avaliacao, SLA, downtime, subtarefas, documentos,
    // pre-fechamento, HH rate e telematica abriam VAZIAS — inutil para
    // treinamento e para captura de tela do manual.
    //
    // Idempotente: checa antes de inserir, pode rodar quantas vezes quiser.
    // ============================================================

    trigger OnRun()
    var
        Summary: Text;
    begin
        Summary := SeedAll();
        Message(Summary);
    end;

    procedure SeedAll(): Text
    var
        SB: TextBuilder;
        ContractNo: Code[20];
        VendorNo: Code[20];
        VehicleNo: Code[20];
        TicketNo: Code[20];
        Seed: Codeunit "KINTO Demo Data Seed";
        Contract: Record "KINTO Vehicle Contract";
    begin
        ContractNo := '';
        Contract.Reset();
        Contract.SetRange(Status, Contract.Status::Active);
        if Contract.FindFirst() then begin
            ContractNo := Contract."Contract No.";
            VehicleNo := Contract."Vehicle No.";
        end;
        if ContractNo = '' then begin
            ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
            Contract.Get(ContractNo);
            VehicleNo := Contract."Vehicle No.";
        end;
        VendorNo := Seed.EnsureDemoVendor();

        SB.AppendLine('Contrato: ' + ContractNo + ' | Veiculo: ' + VehicleNo);
        SB.AppendLine('Clausulas: ' + Format(SeedClauses()));
        SB.AppendLine('Faixas HH rate: ' + Format(SeedLaborRates(VendorNo)));
        SB.AppendLine('SLA: ' + Format(SeedServiceLevel(ContractNo)));
        SB.AppendLine('Avaliacao de cliente: ' + Format(SeedEvaluation(ContractNo)));
        SB.AppendLine('Documentos do veiculo: ' + Format(SeedVehicleDocuments(VehicleNo)));
        TicketNo := SeedTicket(ContractNo, VendorNo, VehicleNo);
        SB.AppendLine('Ticket p/ subtarefas e downtime: ' + TicketNo);
        SB.AppendLine('Subtarefas: ' + Format(SeedSubtasks(TicketNo)));
        SB.AppendLine('Indisponibilidade: ' + Format(SeedDowntime(ContractNo, VehicleNo, TicketNo)));
        SB.AppendLine('Eventos telemetricos: ' + Format(SeedTelematicEvents(VehicleNo)));
        SB.AppendLine('Pre-fechamento: ' + Format(SeedPreClosure(ContractNo)));
        SB.AppendLine('Log de expiracao: ' + Format(SeedExpiryLog(ContractNo)));
        exit(SB.ToText());
    end;

    // ---------- D4: biblioteca de clausulas ----------
    procedure SeedClauses(): Integer
    var
        Clause: Record "KINTO Contract Clause";
        Created: Integer;
    begin
        Created := 0;
        Created += EnsureClause('CLA-001', 'Obrigacoes de manutencao preventiva',
            Clause."Clause Category"::Maintenance, false, 10,
            'O LOCATARIO obriga-se a realizar as manutencoes preventivas nos intervalos de quilometragem e prazo definidos no plano de manutencao, sob pena de cobranca integral dos reparos decorrentes da omissao.');
        Created += EnsureClause('CLA-002', 'Indicacao de condutor infrator',
            Clause."Clause Category"::Penalty, false, 20,
            'O LOCATARIO respondera pelas multas de transito e devera indicar o condutor infrator no prazo legal, sob pena de arcar com o valor integral da penalidade acrescido de taxa administrativa.');
        Created += EnsureClause('CLA-003', 'Limite de quilometragem contratada',
            Clause."Clause Category"::Usage, true, 30,
            'A quilometragem contratada e destinada exclusivamente ao uso do veiculo nas atividades do LOCATARIO, sendo vedada a sublocacao ou cessao a terceiros sem anuencia previa e escrita da KINTO.');
        Created += EnsureClause('CLA-004', 'Cobertura securitaria e franquia',
            Clause."Clause Category"::Insurance, false, 40,
            'O veiculo e segurado contra danos parciais e perda total, permanecendo a franquia e a depreciacao por parte do LOCATARIO em caso de sinistro com culpa ou sem indicacao de condutor.');
        Created += EnsureClause('CLA-005', 'Foro de eleicao',
            Clause."Clause Category"::Legal, true, 50,
            'Fica eleito o foro da Comarca de Sao Paulo/SP para dirimir quaisquer controversias oriundas do presente contrato, com renuncia a qualquer outro, por mais privilegiado que seja.');
        exit(Created);
    end;

    local procedure EnsureClause(Code: Code[20]; Desc: Text[100]; Cat: Enum "KINTO Clause Category";
        Mandatory: Boolean; Sort: Integer; Text: Text[2048]): Integer
    var
        Clause: Record "KINTO Contract Clause";
    begin
        if Clause.Get(Code) then
            exit(0);
        Clause.Init();
        Clause."Clause Code" := Code;
        Clause.Description := Desc;
        Clause."Clause Category" := Cat;
        Clause."Clause Text" := Text;
        Clause."Country Code" := 'BR';
        Clause."Is Mandatory" := Mandatory;
        Clause.Active := true;
        Clause."Sort Order" := Sort;
        Clause."Created By" := 'DEMO';
        Clause."Created DateTime" := CurrentDateTime;
        Clause.Insert(true);
        exit(1);
    end;

    // ---------- D1: tabela de HH rate por fornecedor ----------
    procedure SeedLaborRates(VendorNo: Code[20]): Integer
    var
        Rate: Record "KINTO Vendor Labor Rate";
        Created: Integer;
    begin
        Created := 0;
        Created += EnsureLaborRate(VendorNo, Rate."Service Type"::Mechanical, CalcDate('<-6M>', WorkDate()), 145.50, 2, 'Mecanica geral');
        Created += EnsureLaborRate(VendorNo, Rate."Service Type"::Bodywork, CalcDate('<-6M>', WorkDate()), 168.00, 4, 'Funilaria e pintura');
        Created += EnsureLaborRate(VendorNo, Rate."Service Type"::Electrical, CalcDate('<-6M>', WorkDate()), 152.00, 2, 'Eletrica automotiva');
        Created += EnsureLaborRate(VendorNo, Rate."Service Type"::Tires, CalcDate('<-6M>', WorkDate()), 95.00, 1, 'Pneus e alinhamento');
        Created += EnsureLaborRate(VendorNo, Rate."Service Type"::Glass, CalcDate('<-6M>', WorkDate()), 130.00, 1.5, 'Vidros');
        Created += EnsureLaborRate(VendorNo, Rate."Service Type"::Preventive, CalcDate('<-6M>', WorkDate()), 138.00, 1.5, 'Revisao preventiva');
        exit(Created);
    end;

    local procedure EnsureLaborRate(VendorNo: Code[20]; ServiceType: Enum "KINTO Maint Service Type";
        ValidFrom: Date; HH: Decimal; MinHours: Decimal; Desc: Text[100]): Integer
    var
        Rate: Record "KINTO Vendor Labor Rate";
    begin
        if Rate.Get(VendorNo, ServiceType, ValidFrom) then
            exit(0);
        Rate.Init();
        Rate."Vendor No." := VendorNo;
        Rate."Service Type" := ServiceType;
        Rate."Valid From" := ValidFrom;
        Rate."HH Rate" := HH;
        Rate."Minimum Hours" := MinHours;
        Rate.Active := true;
        Rate.Description := Desc;
        Rate.Insert(true);
        exit(1);
    end;

    // ---------- D3: SLA por contrato ----------
    procedure SeedServiceLevel(ContractNo: Code[20]): Integer
    var
        SLA: Record "KINTO Service Level";
    begin
        if SLA.Get(ContractNo) then
            exit(0);
        SLA.Init();
        SLA."Contract No." := ContractNo;
        SLA."SLA Profile" := 'GOLD';
        SLA."Response Time (hours)" := 4;
        SLA."Resolution Time (hours)" := 48;
        SLA."Replacement Vehicle Hours" := 24;
        SLA."Max Downtime Days/Year" := 15;
        SLA."Penalty Per Hour" := 240.30;
        SLA."Penalty Cap %" := 1;
        SLA."Availability Target %" := 95;
        SLA.Active := true;
        SLA.Insert(true);
        exit(1);
    end;

    // ---------- D4: avaliacao de cliente ----------
    procedure SeedEvaluation(ContractNo: Code[20]): Integer
    var
        Eval: Record "KINTO Contract Evaluation";
        Contract: Record "KINTO Vehicle Contract";
        Seq: Codeunit "KINTO Entry No. Sequencer";
    begin
        Eval.Reset();
        Eval.SetRange("Contract No.", ContractNo);
        if not Eval.IsEmpty() then
            exit(0);
        Contract.Get(ContractNo);
        Eval.Init();
        Eval."Evaluation No." := Seq.NextEvaluationNo();
        Eval."Contract No." := ContractNo;
        Eval."Customer No." := Contract."Customer No.";
        Eval."Evaluation Date" := WorkDate();
        Eval."Payment Behavior Score" := 4;
        Eval."Vehicle Care Score" := 3;
        Eval."Violations Count" := 2;
        Eval."Damages Amount" := 1850.00;
        Eval."Renewal Recommendation" := Eval."Renewal Recommendation"::"Renew with Conditions";
        Eval.Status := Eval.Status::Completed;
        Eval.Notes := 'Cliente com bom historico de pagamento; atencao a conservacao do veiculo e as multas em aberto.';
        Eval."Created By" := 'DEMO';
        Eval.Insert(true);
        exit(1);
    end;

    // ---------- D3: documentos do veiculo versionados ----------
    procedure SeedVehicleDocuments(VehicleNo: Code[20]): Integer
    var
        Doc: Record "KINTO Vehicle Document";
        Created: Integer;
    begin
        Created := 0;
        Doc.SetRange("Vehicle No.", VehicleNo);
        if not Doc.IsEmpty() then
            exit(0);

        Created += EnsureDoc(VehicleNo, Doc."Document Type"::CRLV, 'CRLV-2026-004471', 1,
            CalcDate('<-2M>', WorkDate()), CalcDate('<+10M>', WorkDate()), 'DETRAN-SP');
        Created += EnsureDoc(VehicleNo, Doc."Document Type"::Cautelar, 'LC-2026-8842', 1,
            CalcDate('<-2M>', WorkDate()), CalcDate('<+4M>', WorkDate()), 'LaudoCautelar Brasil');
        Created += EnsureDoc(VehicleNo, Doc."Document Type"::Insurance, 'APL-2026-77120', 1,
            CalcDate('<-2M>', WorkDate()), CalcDate('<+10M>', WorkDate()), 'Seguradora Porto');
        Created += EnsureDoc(VehicleNo, Doc."Document Type"::Licensing, 'IPVA-2026-991', 1,
            CalcDate('<-3M>', WorkDate()), CalcDate('<+9M>', WorkDate()), 'SEFAZ-SP');
        exit(Created);
    end;

    local procedure EnsureDoc(VehicleNo: Code[20]; DocType: Enum "KINTO Vehicle Doc Type"; DocNo: Text[50];
        Version: Integer; Issue: Date; Expiry: Date; Issuer: Text[100]): Integer
    var
        Doc: Record "KINTO Vehicle Document";
        Seq: Codeunit "KINTO Entry No. Sequencer";
    begin
        Doc.Reset();
        Doc.SetRange("Vehicle No.", VehicleNo);
        Doc.SetRange("Document Type", DocType);
        Doc.SetRange("Version No.", Version);
        if not Doc.IsEmpty() then
            exit(0);
        Doc.Init();
        Doc."Entry No." := Seq.NextDocumentEntryNo();
        Doc."Vehicle No." := VehicleNo;
        Doc."Document Type" := DocType;
        Doc."Document No." := DocNo;
        Doc."Version No." := Version;
        Doc."Issue Date" := Issue;
        Doc."Expiry Date" := Expiry;
        Doc."Issuing Body" := Issuer;
        Doc."Is Current" := true;
        Doc.Notes := 'Documento vigente carregado pelo seed de demonstracao.';
        Doc."Created By" := 'DEMO';
        Doc."Created DateTime" := CurrentDateTime;
        Doc.Insert(true);
        exit(1);
    end;

    // ---------- D3: ticket para subtarefas e downtime ----------
    local procedure SeedTicket(ContractNo: Code[20]; VendorNo: Code[20]; VehicleNo: Code[20]): Code[20]
    var
        Ticket: Record "KINTO Maintenance Ticket";
        MaintMgt: Codeunit "KINTO Maintenance Management";
        Vehicle: Record "KINTO Inventory Vehicle";
        TicketType: Enum "KINTO Maint Ticket Type";
        TicketNo: Code[20];
    begin
        // reaproveita um ticket em andamento do contrato, se existir
        Ticket.Reset();
        Ticket.SetRange("Contract No.", ContractNo);
        Ticket.SetFilter(Status, '%1|%2', Ticket.Status::Open, Ticket.Status::"In Execution");
        if Ticket.FindFirst() then
            exit(Ticket."Ticket No.");

        Vehicle.Get(VehicleNo);
        TicketNo := MaintMgt.CreateTicketFromContract(ContractNo, TicketType::Corrective,
            'Reparo corretivo — retorno de frota', WorkDate(), Vehicle."Current Odometer");
        if TicketNo <> '' then begin
            Ticket.Get(TicketNo);
            Ticket."Vendor No." := VendorNo;
            Ticket.Modify(true);
        end;
        exit(TicketNo);
    end;

    // ---------- D3: subtarefas do ticket ----------
    procedure SeedSubtasks(TicketNo: Code[20]): Integer
    var
        Sub: Record "KINTO Ticket Subtask";
        Created: Integer;
    begin
        if TicketNo = '' then
            exit(0);
        Sub.SetRange("Ticket No.", TicketNo);
        if not Sub.IsEmpty() then
            exit(0);

        Created += EnsureSubtask(TicketNo, 10, 'Diagnostico inicial e orcamento', Sub.Status::Completed, 'tecnico.oliveira', -3);
        Created += EnsureSubtask(TicketNo, 20, 'Aprovacao do orcamento pelo gestor de frota', Sub.Status::Completed, 'gestor.frota', -2);
        Created += EnsureSubtask(TicketNo, 30, 'Execucao do reparo na oficina', Sub.Status::"In Progress", 'tecnico.souza', 1);
        Created += EnsureSubtask(TicketNo, 40, 'Vistoria final e liberacao do veiculo', Sub.Status::Pending, 'vistoriador.lima', 2);
        Created += EnsureSubtask(TicketNo, 50, 'Faturamento e encerramento', Sub.Status::Blocked, 'financeiro.kinto', 5);
        exit(Created);
    end;

    local procedure EnsureSubtask(TicketNo: Code[20]; No: Integer; Desc: Text[250];
        Status: Enum "KINTO Subtask Status"; Assignee: Code[50]; DueInDays: Integer): Integer
    var
        Sub: Record "KINTO Ticket Subtask";
    begin
        Sub.Reset();
        Sub.SetRange("Ticket No.", TicketNo);
        Sub.SetRange("Subtask No.", No);
        if not Sub.IsEmpty() then
            exit(0);
        Sub.Init();
        Sub."Ticket No." := TicketNo;
        Sub."Subtask No." := No;
        Sub.Description := Desc;
        Sub.Status := Status;
        Sub."Assigned To" := Assignee;
        Sub."Due DateTime" := CreateDateTime(CalcDate('<-1D>', WorkDate()) + DueInDays, 180000T);
        Sub.Sequence := No;
        if No > 10 then
            Sub."Depends On Subtask" := No - 10;
        Sub.Insert(true);
        exit(1);
    end;

    // ---------- D3: indisponibilidade do veiculo ----------
    procedure SeedDowntime(ContractNo: Code[20]; VehicleNo: Code[20]; TicketNo: Code[20]): Integer
    var
        Down: Record "KINTO Vehicle Downtime";
        Created: Integer;
        StartDT: DateTime;
        EndDT: DateTime;
    begin
        Down.SetRange("Contract No.", ContractNo);
        if not Down.IsEmpty() then
            exit(0);
        Created := 0;

        // parada ja encerrada (gera credito de servico)
        StartDT := CreateDateTime(CalcDate('<-12D>', WorkDate()), 080000T);
        EndDT := CreateDateTime(CalcDate('<-9D>', WorkDate()), 170000T);
        Created += EnsureDowntime(VehicleNo, ContractNo, StartDT, EndDT, Down.Reason::Maintenance, TicketNo, true,
            'Reparo corretivo no sistema de freios — veiculo parado na concessionaria.');

        // parada aberta (veiculo indisponivel agora)
        StartDT := CreateDateTime(CalcDate('<-1D>', WorkDate()), 140000T);
        Created += EnsureDowntime(VehicleNo, ContractNo, StartDT, 0DT, Down.Reason::Accident, '', true,
            'Sinistro leve — aguardando pericia e liberacao da seguradora.');
        exit(Created);
    end;

    local procedure EnsureDowntime(VehicleNo: Code[20]; ContractNo: Code[20]; StartDT: DateTime; EndDT: DateTime;
        Reason: Enum "KINTO Downtime Reason"; TicketNo: Code[20]; Chargeable: Boolean; Notes: Text[250]): Integer
    var
        Down: Record "KINTO Vehicle Downtime";
        Seq: Codeunit "KINTO Entry No. Sequencer";
    begin
        Down.Reset();
        Down.SetRange("Vehicle No.", VehicleNo);
        Down.SetRange("Start DateTime", StartDT);
        if not Down.IsEmpty() then
            exit(0);
        Down.Init();
        Down."Entry No." := Seq.NextDowntimeEntryNo();
        Down."Vehicle No." := VehicleNo;
        Down."Contract No." := ContractNo;
        Down."Start DateTime" := StartDT;
        Down."End DateTime" := EndDT;
        Down.Reason := Reason;
        Down."Ticket No." := TicketNo;
        Down."Chargeable to KINTO" := Chargeable;
        Down.Notes := Notes;
        Down.Insert(true);
        exit(1);
    end;

    // ---------- D1: eventos telematicos ----------
    procedure SeedTelematicEvents(VehicleNo: Code[20]): Integer
    var
        Evt: Record "KINTO Telematic Event";
        Seq: Codeunit "KINTO Entry No. Sequencer";
        Created: Integer;
    begin
        Evt.SetRange("Vehicle No.", VehicleNo);
        if not Evt.IsEmpty() then
            exit(0);
        Created := 0;
        Created += EnsureTelematic(VehicleNo, Evt."Event Trigger"::"Odometer Reached", 45000,
            '{"odometer":45000,"threshold":45000,"ts":"2026-10-25T08:12:00Z"}');
        Created += EnsureTelematic(VehicleNo, Evt."Event Trigger"::"Service Interval", 44850,
            '{"odometer":44850,"km_since_service":10000,"ts":"2026-10-24T16:40:00Z"}');
        Created += EnsureTelematic(VehicleNo, Evt."Event Trigger"::"Low Fluids", 44120,
            '{"odometer":44120,"fluid":"coolant","level_pct":18,"ts":"2026-10-20T11:05:00Z"}');
        Created += EnsureTelematic(VehicleNo, Evt."Event Trigger"::"Brake Wear", 43800,
            '{"odometer":43800,"pad_wear_pct":82,"ts":"2026-10-18T09:30:00Z"}');
        Created += EnsureTelematic(VehicleNo, Evt."Event Trigger"::"Fault Code", 43550,
            '{"odometer":43550,"dtc":"P0420","desc":"Catalyst efficiency below threshold","ts":"2026-10-17T14:22:00Z"}');
        exit(Created);
    end;

    local procedure EnsureTelematic(VehicleNo: Code[20]; EventTrigger: Enum "KINTO Telematic Trigger";
        Odometer: Decimal; Payload: Text): Integer
    var
        Evt: Record "KINTO Telematic Event";
        Seq: Codeunit "KINTO Entry No. Sequencer";
    begin
        Evt.Reset();
        Evt.SetRange("Vehicle No.", VehicleNo);
        Evt.SetRange("Event Trigger", EventTrigger);
        if not Evt.IsEmpty() then
            exit(0);
        Evt.Init();
        Evt."Entry No." := Seq.NextTelematicEntryNo();
        Evt."Vehicle No." := VehicleNo;
        Evt."Event DateTime" := CreateDateTime(CalcDate('<-7D>', WorkDate()) + (Evt."Entry No." mod 7), 090000T);
        Evt."Event Trigger" := EventTrigger;
        Evt."Odometer (km)" := Odometer;
        Evt."Raw Payload" := Payload;
        Evt.Insert(true);
        exit(1);
    end;

    // ---------- D5: pre-fechamento ----------
    procedure SeedPreClosure(ContractNo: Code[20]): Integer
    var
        PC: Record "KINTO Pre-Closure";
        Created: Integer;
    begin
        PC.SetRange("Contract No.", ContractNo);
        if not PC.IsEmpty() then
            exit(0);
        PC.Init();
        PC."Pre-Closure No." := 'PC-' + ContractNo;
        PC."Contract No." := ContractNo;
        PC."Planned Return Date" := CalcDate('<+45D>', WorkDate());
        PC."Notice Sent Date" := CalcDate('<-5D>', WorkDate());
        PC.Status := PC.Status::Notified;
        PC."Odometer Forecast" := 58200;
        PC.Insert(true);
        exit(1);
    end;

    // ---------- D4: log de expiracao de contrato ----------
    procedure SeedExpiryLog(ContractNo: Code[20]): Integer
    var
        Log: Record "KINTO Contract Expiry Log";
        Created: Integer;
    begin
        Log.SetRange("Contract No.", ContractNo);
        if not Log.IsEmpty() then
            exit(0);
        Created := 0;
        Created += EnsureExpiryLog(ContractNo, CalcDate('<-30D>', WorkDate()), Log."Action Type"::"Notice Sent",
            30, 'Aviso de vencimento enviado ao cliente — 30 dias de antecedencia.');
        Created += EnsureExpiryLog(ContractNo, CalcDate('<-15D>', WorkDate()), Log."Action Type"::"Evaluation Due",
            15, 'Avaliacao de cliente pendente: contrato entra na janela de renovacao.');
        exit(Created);
    end;

    local procedure EnsureExpiryLog(ContractNo: Code[20]; ActionDate: Date; ActionType: Enum "KINTO Contract Expiry Action";
        DaysToExpiry: Integer; Msg: Text[250]): Integer
    var
        Log: Record "KINTO Contract Expiry Log";
        Seq: Codeunit "KINTO Entry No. Sequencer";
    begin
        Log.Reset();
        Log.SetRange("Contract No.", ContractNo);
        Log.SetRange("Action Type", ActionType);
        if not Log.IsEmpty() then
            exit(0);
        Log.Init();
        Log."Entry No." := Seq.NextExpiryLogEntryNo();
        Log."Contract No." := ContractNo;
        Log."Action Date" := ActionDate;
        Log."Action Type" := ActionType;
        Log."Days to Expiry" := DaysToExpiry;
        Log."Log Message" := Msg;
        Log."Created DateTime" := CurrentDateTime;
        Log.Insert(true);
        exit(1);
    end;
}
