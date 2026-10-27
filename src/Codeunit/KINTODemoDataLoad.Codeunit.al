codeunit 50157 "KINTO Demo Data Load"
{
    // ============================================================
    // CARGA INICIAL DE DEMONSTRAÇÃO (v2 — 27/10)
    // 11 cenários: contratos/billing → dispositivo+apólice → multas
    // → manutenção → terminação/danos → recovery → reajuste →
    // sinistro → remarketing completo (TP2/TP3) → portal TP1 →
    // mileage closing → service credit.
    // Cada rodada cria um novo conjunto de registros (contratos
    // novos a cada execução); billing e índice são idempotentes.
    //
    // USO: página KINTO Test Management → Run Demo Data Load, ou:
    //   - Job Queue: codeunit 50157
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
        DeviceNo: Code[20];
        PolicyNo: Code[20];
        MaintMgt: Codeunit "KINTO Maintenance Management";
        TermMgt: Codeunit "KINTO Termination Management";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        Contract: Record "KINTO Vehicle Contract";
        Fine: Record "KINTO Traffic Fine";
        VehicleReturn: Record "KINTO Vehicle Return";
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

        // D7: dispositivo telemático instalado + apólice ativa
        DeviceNo := Seed.CreateDemoDevice(Contract."Vehicle No.", ContractNo1);
        PolicyNo := Seed.CreateDemoPolicy(Contract."Vehicle No.", ContractNo1);
        SB.AppendLine('2. Dispositivo ' + DeviceNo + ' instalado + apólice ' + PolicyNo + ' ativa');

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
        SB.AppendLine('3. Multa ' + FineNo + ' vinculada + cobrada (cliente R$ 195,23 + taxas)');

        // Multa 2: infração fora da vigência → não linkable
        FineNo2 := Seed.CreateFine(ContractNo2, CalcDate('<-2Y>', WorkDate()));
        Fine.Get(FineNo2);
        FineMgt.LinkFine(Fine);
        SB.AppendLine('4. Multa ' + FineNo2 + ' fora de vigência → Not Linkable');

        // ============================================================
        // CENÁRIO 3 — MANUTENÇÃO (ticket + linhas)
        // ============================================================
        TicketNo := MaintMgt.CreateTicketFromContract(ContractNo2,
            "KINTO Maint Ticket Type"::Corrective, 'DEMO: revisão de freios + pneus', WorkDate(), 45000);
        Seed.AddTicketLine(TicketNo, 'Troca pastilha de freio', 2, 180, true);
        Seed.AddTicketLine(TicketNo, 'Balanceamento', 1, 120, false);
        SB.AppendLine('5. Ticket de manutenção ' + TicketNo + ' (2 linhas, 1 billable)');

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
        SB.AppendLine('6. Return ' + ReturnNo + ' c/ 3 danos → cobrança cliente R$ 4.300 + dealer R$ 180');

        // ============================================================
        // CENÁRIO 5 — TOTAL LOSS (recovery automático)
        // ============================================================
        ContractNo4 := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Seed.TerminateContract(ContractNo4, "KINTO Termination Type"::"Total Loss");
        Contract.Get(ContractNo4);
        TermMgt.HandleTotalLoss(Contract);
        SB.AppendLine('7. Total loss → recovery case automático (risco alto)');

        // ============================================================
        // CENÁRIO 6 (NOVO) — REAJUSTE POR ÍNDICE (ledger + cap)
        // ============================================================
        DemoAdjustment(SB);

        // ============================================================
        // CENÁRIO 7 (NOVO) — SINISTRO (5 trilhas, ciclo completo)
        // ============================================================
        DemoClaim(SB);

        // ============================================================
        // CENÁRIO 8 (NOVO) — REMARKETING COMPLETO (cascata → venda → baixa)
        // Habilita o portal ANTES da venda p/ gerar TP2 e TP3.
        // ============================================================
        DemoRemarketing(SB);

        // ============================================================
        // CENÁRIO 9 (NOVO) — PORTAL TP1 (disponíveis com preço)
        // ============================================================
        DemoPortalAvailability(SB);

        // ============================================================
        // CENÁRIO 10 (NOVO) — MILEAGE CLOSING (faixas + cap FIPE)
        // ============================================================
        DemoMileageClosing(SB);

        // ============================================================
        // CENÁRIO 11 (NOVO) — SERVICE CREDIT (cap 2%)
        // ============================================================
        DemoServiceCredit(SB);

        SB.AppendLine('');
        SB.AppendLine('Carga demo v2 concluída — 11 cenários. Páginas p/ demonstrar:');
        SB.AppendLine('  Contratos, Billing, Multas, Tickets, Returns, Recovery,');
        SB.AppendLine('  Reajustes (50480), Sinistros (50477), Remarketing (Sales/Offers),');
        SB.AppendLine('  Portal Sync (50481), Portal Config (50482), Test Management.');
        exit(SB.ToText());
    end;

    // ============================================================
    // CENÁRIOS NOVOS (v2)
    // ============================================================
    local procedure DemoAdjustment(var SB: TextBuilder)
    var
        Seed: Codeunit "KINTO Demo Data Seed";
        Contract: Record "KINTO Vehicle Contract";
        IndexEntry: Record "KINTO Price Index Entry";
        Scheduler: Codeunit "KINTO Price Adjustment Sch.";
        Ledger: Record "KINTO Adjustment Ledger";
        ContractNo: Code[20];
        Adjusted: Integer;
    begin
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        Contract."Price Index Code" := 'IPCA-T';
        Contract."Index Frequency" := Contract."Index Frequency"::Monthly;
        Contract."Index Cap %" := 5;
        Contract.Modify(true);

        // Índice com variação 8% (acima do cap 5% → cap aplicado)
        if not IndexEntry.Get('IPCA-T', CalcDate('<-2M>', WorkDate())) then begin
            IndexEntry.Init();
            IndexEntry."Index Code" := 'IPCA-T';
            IndexEntry."Valid From" := CalcDate('<-2M>', WorkDate());
            IndexEntry."Index Value" := 100;
            IndexEntry."Variation %" := 8;
            IndexEntry.Insert(true);
        end;

        Adjusted := Scheduler.RunAdjustments(WorkDate());
        Ledger.SetRange("Contract No.", ContractNo);
        if Ledger.FindFirst() then
            SB.AppendLine('8. Reajuste IPCA-T em ' + ContractNo + ': variação 8% → cap 5% aplicado (ledger gravado)')
        else
            SB.AppendLine('8. Reajuste: ' + Format(Adjusted) + ' contrato(s) ajustado(s), ledger do demo não localizado');
    end;

    local procedure DemoClaim(var SB: TextBuilder)
    var
        Seed: Codeunit "KINTO Demo Data Seed";
        Claim: Record "KINTO Claim";
        ClaimMgt: Codeunit "KINTO Claim Management";
        Contract: Record "KINTO Vehicle Contract";
        ContractNo: Code[20];
        PolicyNo: Code[20];
        ClaimNo: Code[20];
    begin
        // Idempotência: sinistro demo já criado em rodada anterior?
        Claim.SetFilter(Description, 'DEMO:*');
        if not Claim.IsEmpty() then begin
            SB.AppendLine('9. Sinistro demo já existente (idempotente)');
            exit;
        end;

        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        PolicyNo := Seed.CreateDemoPolicy(Contract."Vehicle No.", ContractNo);

        ClaimNo := ClaimMgt.CreateClaim(ContractNo, "KINTO Claim Class Type"::PartialDamage,
            WorkDate(), 'DEMO: colisão em avenida (perda parcial)');
        Claim.Get(ClaimNo);
        // Classificação: dano 78.000 sobre mercado 95.000 = 82% >= 70% → destruição total
        ClaimMgt.ClassifyClaim(Claim, 95000, 78000);
        ClaimMgt.SendToInsurer(Claim, 'INS-DEMO-001');
        ClaimMgt.RecordInsurerDecision(Claim, true, 90000);
        ClaimMgt.RegisterPayment(Claim);
        SB.AppendLine('9. Sinistro ' + ClaimNo + ' completo: classificado (82% → destruição total), ' +
            'seguradora aprovou R$ 90.000, indenização paga, contrato encerrado');
    end;

    local procedure DemoRemarketing(var SB: TextBuilder)
    var
        Seed: Codeunit "KINTO Demo Data Seed";
        Contract: Record "KINTO Vehicle Contract";
        Offer: Record "KINTO Remarketing Offer";
        Sale: Record "KINTO Remarketing Sale";
        PortalConfig: Record "KINTO Portal Config";
        RemMgt: Codeunit "KINTO Remarketing Mgt.";
        ContractNo: Code[20];
        VehicleNo: Code[20];
    begin
        // Portal ON antes da venda → InvoiceSale/CompleteSale geram TP2/TP3
        PortalConfig.GetConfig();
        PortalConfig.Enabled := true;
        PortalConfig.Modify(true);

        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        VehicleNo := Contract."Vehicle No.";
        Seed.TerminateContract(ContractNo);

        // Cascata de ofertas (3 canais BR) → envia e aceita a 1ª (cliente/motorista)
        if RemMgt.CreateCascadeOffers(VehicleNo) = 0 then begin
            SB.AppendLine('10. Remarketing: sem canais ativos (verificar Setup D8)');
            exit;
        end;
        Offer.SetRange("Vehicle No.", VehicleNo);
        Offer.SetRange("Step No.", 1);
        Offer.FindFirst();
        RemMgt.SendOffer(Offer);
        RemMgt.AcceptOffer(Offer); // cria a venda
        Sale.SetRange("Vehicle No.", VehicleNo);
        Sale.FindFirst();
        RemMgt.ApproveSalePrice(Sale);            // 4-olhos
        RemMgt.InvoiceSale(Sale);                 // TP2 automático
        RemMgt.RegisterPayment(Sale, WorkDate()); // fecha o contrato (venda ao motorista)
        RemMgt.CompleteSale(Sale);                // TP3 baixa + veículo Inactive
        SB.AppendLine('10. Remarketing ' + Sale."Sale No." + ': cascata 3 canais → oferta aceita → ' +
            '4-olhos → fatura → pagamento → baixa (TP2/TP3 no portal)');
    end;

    local procedure DemoPortalAvailability(var SB: TextBuilder)
    var
        Seed: Codeunit "KINTO Demo Data Seed";
        Contract: Record "KINTO Vehicle Contract";
        PortalConfig: Record "KINTO Portal Config";
        PortalIntegration: Codeunit "KINTO Portal Integration";
        SyncEntry: Record "KINTO Portal Sync Entry";
        RemMgt: Codeunit "KINTO Remarketing Mgt.";
        ContractNo: Code[20];
        Count: Integer;
    begin
        PortalConfig.GetConfig();
        PortalConfig.Enabled := true;
        PortalConfig.Modify(true);

        // Veículo PRÓPRIO p/ TP1 (o do cenário 10 já foi baixado): termina e
        // entra em remarketing com ofertas abertas → SendAllAvailable envia c/ preço
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        Seed.TerminateContract(ContractNo);
        RemMgt.CreateCascadeOffers(Contract."Vehicle No."); // StartRemarketing interno

        Count := PortalIntegration.SendAllAvailable();
        SyncEntry.SetRange("Event Type", SyncEntry."Event Type"::"Availability Sent");
        SB.AppendLine('11. Portal TP1: ' + Format(Count) + ' veículo(s) enviado(s) c/ preço — ' +
            Format(SyncEntry.Count()) + ' entries de disponibilidade na fila (Pending)');
        SB.AppendLine('    TP2/TP3: entries criadas automaticamente na venda do cenário 10');
    end;

    local procedure DemoMileageClosing(var SB: TextBuilder)
    var
        Seed: Codeunit "KINTO Demo Data Seed";
        Contract: Record "KINTO Vehicle Contract";
        VehicleReturn: Record "KINTO Vehicle Return";
        TermMgt: Codeunit "KINTO Termination Management";
        SetMgt: Codeunit "KINTO Settlement Mgt.";
        Settlement: Record "KINTO Settlement";
        ContractNo: Code[20];
        ReturnNo: Code[20];
        SettlementNo: Code[20];
    begin
        // 12 meses x 1.500 km = 18.000 km contratados; devolução com 23.000 km
        // → excesso 5.000: faixa 1 (1.800 x R$ 1,00) + faixa 2 (3.200 x R$ 2,00) = R$ 8.200
        ContractNo := Seed.CreateActiveContract('BR', 12, 1500, 3.4);
        Contract.Get(ContractNo);
        Contract."Excess Km Price (up to 10%)" := 1;
        Contract."Excess Km Price (above 10%)" := 2;
        Contract.Modify(true);
        Seed.TerminateContract(ContractNo);
        ReturnNo := TermMgt.CreateReturnFromContract(ContractNo, WorkDate(), 'São Paulo — pátio central');
        VehicleReturn.Get(ReturnNo);
        VehicleReturn."Odometer at Return" := 23000;
        VehicleReturn."Return Date" := WorkDate();
        VehicleReturn.Modify(true);
        SettlementNo := SetMgt.CreateSettlement(ContractNo, "KINTO Settlement Type"::"Final Balance");
        Settlement.Get(SettlementNo);
        SB.AppendLine('12. Mileage closing ' + SettlementNo + ': excesso 5.000 km → faixas 1+2 = R$ ' +
            Format(Settlement."Mileage Excess Charge") + ' (cap FIPE = booking value do veículo)');
    end;

    local procedure DemoServiceCredit(var SB: TextBuilder)
    var
        Seed: Codeunit "KINTO Demo Data Seed";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        CreditMgt: Codeunit "KINTO Service Credit Mgt.";
        Contract: Record "KINTO Vehicle Contract";
        CreditAmount: Decimal;
        ContractNo: Code[20];
        BillingMonth: Date;
    begin
        ContractNo := Seed.CreateActiveContract('BR', 24, 1500, 3.4);
        Contract.Get(ContractNo);
        BillingMonth := CalcDate('<-CM>', WorkDate());
        BillingMgt.GenerateBillingForContract(Contract, BillingMonth);
        // 30 dias sem serviço = mês inteiro → estoura o cap de 2%
        CreditAmount := CreditMgt.RequestServiceCredit(ContractNo, BillingMonth, 30,
            'DEMO: veículo indisponível 30 dias (cap 2% aplicado)');
        SB.AppendLine('13. Service credit: 30 dias sem serviço → crédito R$ ' + Format(-CreditAmount) +
            ' (limitado a 2% do faturamento do mês)');
    end;

    // ============================================================
    // AUXILIARES
    // ============================================================
    local procedure ContractHasBilling(ContractNo: Code[20]; BillingMonth: Date): Boolean
    var
        BillingLine: Record "KINTO Billing Line";
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        exit(not BillingLine.IsEmpty());
    end;
}