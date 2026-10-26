codeunit 50157 "KINTO Demo Data Load"
{
    // ============================================================
    // CARGA INICIAL DE DEMONSTRAÇÃO (Fases 1-5)
    // Executa o cenário completo de demo: master data → 3 contratos
    // (1 ativo c/ billing, 1 c/ multas, 1 terminado c/ danos) →
    // tickets → recovery. Idempotente: pode rodar várias vezes.
    //
    // USO: no BC, via página de execução (action) ou:
    //   - Job Queue: codeunit 50157
    //   - ou via AL: RunObject
    // ============================================================

    trigger OnRun()
    var
        Summary: Text;
    begin
        Summary := LoadDemoData();
        Message(Summary);
    end;

    procedure LoadDemoData(): Text
    var
        Seed: Codeunit "KINTO Demo Data Seed";
        ContractNo1: Code[20];
        ContractNo2: Code[20];
        ContractNo3: Code[20];
        ContractNo4: Code[20];
        FineNo: Code[20];
        FineNo2: Code[20];
        TicketNo: Code[20];
        ReturnNo: Code[20];
        FineMgt: Codeunit "KINTO Fine Management";
        MaintMgt: Codeunit "KINTO Maintenance Management";
        TermMgt: Codeunit "KINTO Termination Management";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        Contract: Record "KINTO Vehicle Contract";
        Fine: Record "KINTO Traffic Fine";
        VehicleReturn: Record "KINTO Vehicle Return";
        BillingLine: Record "KINTO Billing Line";
        BillingMonth: Date;
        SB: TextBuilder;
    begin
        BillingMonth := CalcDate('<-CM>', WorkDate());

        // ============================================================
        // CENÁRIO 1 — CONTRATO ATIVO + BILLING (ciclo comercial completo)
        // ============================================================
        ContractNo1 := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo1);
        if not ContractHasBilling(ContractNo1, BillingMonth) then begin
            BillingMgt.GenerateBillingForContract(Contract, BillingMonth);
            BillingMgt.ApproveContractLines(ContractNo1, BillingMonth);
            SB.AppendLine('1. Contrato ativo ' + ContractNo1 + ' + billing gerada e aprovada');
        end else
            SB.AppendLine('1. Contrato ativo ' + ContractNo1 + ' (billing já existente)');

        // ============================================================
        // CENÁRIO 2 — CONTRATO ATIVO + MULTAS (vinculação e cobrança)
        // ============================================================
        ContractNo2 := Seed.CreateActiveContract('BR', 24, 1500, 3.4);

        // Multa 1: infração dentro da vigência → vincula e cobra
        FineNo := Seed.CreateFine(ContractNo2, CalcDate('<-1M>', WorkDate()));
        Fine.Get(FineNo);
        FineMgt.LinkFine(Fine);
        Fine.Get(FineNo);
        if Fine."Contract No." <> '' then
            FineMgt.BillFineToCustomer(Fine);
        SB.AppendLine('2. Multa ' + FineNo + ' vinculada + cobrada (cliente R$ 195,23 + taxas)');

        // Multa 2: infração fora da vigência → não linkable
        FineNo2 := Seed.CreateFine(ContractNo2, CalcDate('<-2Y>', WorkDate()));
        Fine.Get(FineNo2);
        FineMgt.LinkFine(Fine);
        SB.AppendLine('3. Multa ' + FineNo2 + ' fora de vigência → Not Linkable');

        // ============================================================
        // CENÁRIO 3 — MANUTENÇÃO (ticket + pool)
        // ============================================================
        TicketNo := MaintMgt.CreateTicketFromContract(ContractNo2,
            "KINTO Maint Ticket Type"::Corrective, 'DEMO: revisão de freios + pneus', WorkDate(), 45000);
        Seed.AddTicketLine(TicketNo, 'Troca pastilha de freio', 2, 180, true);
        Seed.AddTicketLine(TicketNo, 'Balanceamento', 1, 120, false);
        SB.AppendLine('4. Ticket de manutenção ' + TicketNo + ' (2 linhas, 1 billable)');

        // ============================================================
        // CENÁRIO 4 — TERMINAÇÃO + DANOS (devolução com cobrança)
        // ============================================================
        ContractNo3 := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Seed.TerminateContract(ContractNo3);
        ReturnNo := TermMgt.CreateReturnFromContract(ContractNo3, WorkDate(), 'São Paulo — pátio central');
        VehicleReturn.Get(ReturnNo);
        VehicleReturn."Odometer at Return" := 52000;
        VehicleReturn."Return Date" := WorkDate();
        VehicleReturn.Modify(true);
        Seed.AddDamageLine(ReturnNo, 'Riscos no para-choque dianteiro', "KINTO Damage Class"::"Misuse",
            "KINTO Damage Payer"::Customer, 1500);
        Seed.AddDamageLine(ReturnNo, 'Amassado porta traseira', "KINTO Damage Class"::Accident,
            "KINTO Damage Payer"::Customer, 2800);
        Seed.AddDamageLine(ReturnNo, 'Falta tapete de borracha', "KINTO Damage Class"::Wear,
            "KINTO Damage Payer"::Dealer, 180);
        // Ciclo completo: Scheduled → In Progress → Checklist → Finish
        TermMgt.StartReturn(VehicleReturn);
        VehicleReturn.Get(ReturnNo);
        VehicleReturn.CompleteChecklist();
        VehicleReturn.FinishReturn();
        VehicleReturn.Get(ReturnNo);
        VehicleReturn.BillDamagesToCustomer();
        SB.AppendLine('5. Return ' + ReturnNo + ' c/ 3 danos → cobrança cliente R$ 4.300 + dealer R$ 180');

        // ============================================================
        // CENÁRIO 5 — TOTAL LOSS (recovery automático)
        // ============================================================
        ContractNo4 := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Seed.TerminateContract(ContractNo4, "KINTO Termination Type"::"Total Loss");
        Contract.Get(ContractNo4);
        TermMgt.HandleTotalLoss(Contract);
        SB.AppendLine('6. Total loss → recovery case automático (risco alto)');

        SB.AppendLine('');
        SB.AppendLine('Carga demo concluída. Cenários: contratos ' + ContractNo1 + '/' + ContractNo2 +
            '/' + ContractNo3 + ' + total loss.');
        exit(SB.ToText());
    end;

    local procedure ContractHasBilling(ContractNo: Code[20]; BillingMonth: Date): Boolean
    var
        BillingLine: Record "KINTO Billing Line";
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        exit(not BillingLine.IsEmpty());
    end;
}