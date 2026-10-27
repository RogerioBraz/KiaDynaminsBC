codeunit 50205 "KINTO Fine Management"
{
    Permissions = tabledata "KINTO Traffic Fine" = RIMD,
                  tabledata "KINTO Fine Driver" = RIMD,
                  tabledata "KINTO Vehicle Contract" = RIMD,
                  tabledata "KINTO Billing Line" = RIMD,
                  tabledata "KINTO Issuing Authority" = RIM,
                  tabledata "KINTO Fine Fee Setup" = RIM,
                  tabledata "KINTO Fine Provider" = RIM,
                  tabledata "KINTO Fine Integration Error" = RIMD;

    var
        NoContractErr: Label 'Fine %1 has no linked contract — link before billing.';
        NotBilledErr: Label 'Fine %1 is not in a state that allows billing.';
        AlreadyBilledErr: Label 'Fine %1 already has a billing line.';
        NoVehicleErr: Label 'Fine %1 has no vehicle — cannot link.';

    // ============================================================
    // FASE 4 — VINCULAÇÃO POR DATA DE INFRAÇÃO (D2)
    // Responde "quem tinha o carro em dd/mm" cruzando a multa com os
    // contratos da placa, usando a DATA DA INFRAÇÃO (não a de captura)
    // e a janela pós-contrato configurável por órgão (60d BR default).
    // ============================================================
    procedure LinkFine(var Fine: Record "KINTO Traffic Fine"): Boolean
    var
        Contract: Record "KINTO Vehicle Contract";
        Authority: Record "KINTO Issuing Authority";
        BestContractNo: Code[20];
        BestStart: Date;
        InfractionDate: Date;
    begin
        if Fine."Vehicle No." = '' then
            Error(NoVehicleErr, Fine."Fine No.");
        if Fine."Infraction DateTime" = 0DT then
            InfractionDate := DT2Date(Fine."Capture DateTime")
        else
            InfractionDate := DT2Date(Fine."Infraction DateTime");

        Fine."Contract No." := '';
        Fine."Customer No." := '';
        Fine."Link Status" := Fine."Link Status"::Unlinked;
        Fine."SNE Adjustment %" := 0;

        // Procura o contrato vigente na data da infração (o mais recente que cobre a data)
        Contract.Reset();
        Contract.SetRange("Vehicle No.", Fine."Vehicle No.");
        Contract.SetFilter(Status, '%1|%2|%3', Contract.Status::Active, Contract.Status::Extended,
            Contract.Status::Terminated);
        Contract.SetFilter("Start Date", '<=%1', InfractionDate);
        if Contract.FindSet() then
            repeat
                if ContractCoversDate(Contract, InfractionDate) then
                    if (BestContractNo = '') or (Contract."Start Date" > BestStart) then begin
                        BestContractNo := Contract."Contract No.";
                        BestStart := Contract."Start Date";
                    end;
            until Contract.Next() = 0;

        if BestContractNo <> '' then begin
            Contract.Get(BestContractNo);
            Fine."Contract No." := BestContractNo;
            Fine."Customer No." := Contract."Customer No.";
            Fine."Link Status" := Fine."Link Status"::Linked;
            Fine."Linked DateTime" := CurrentDateTime;
            // SNE Adjustment % vem do órgão autuador (60/80% configurável — D2)
            if Authority.Get(Fine."Issuing Authority Code") then
                Fine."SNE Adjustment %" := Authority."SNE Adjustment %";
            Fine.Modify(true);
            exit(true);
        end;

        // Janela pós-contrato: infração dentro de N dias após o fim do último contrato
        if ContractInGraceWindow(Fine."Vehicle No.", InfractionDate) then begin
            Fine."Link Status" := Fine."Link Status"::"Linked - Grace Period";
            Fine.Modify(true);
            exit(true);
        end;

        Fine."Link Status" := Fine."Link Status"::"Not Linkable";
        Fine.Modify(true);
        exit(false);
    end;

    local procedure ContractCoversDate(var Contract: Record "KINTO Vehicle Contract"; InfractionDate: Date): Boolean
    var
        EndDate: Date;
    begin
        EndDate := Contract."Current End Date";
        if (EndDate = 0D) or (EndDate < Contract."Start Date") then
            EndDate := CalcDate('<+CY>', Contract."Start Date"); // sem fim: assume ano corrente
        exit((InfractionDate >= Contract."Start Date") and (InfractionDate <= EndDate));
    end;

    local procedure ContractInGraceWindow(VehicleNo: Code[20]; InfractionDate: Date): Boolean
    var
        Contract: Record "KINTO Vehicle Contract";
        Authority: Record "KINTO Issuing Authority";
        GraceDays: Integer;
    begin
        GraceDays := 60; // default BR
        Contract.Reset();
        Contract.SetRange("Vehicle No.", VehicleNo);
        Contract.SetFilter(Status, '%1|%2', Contract.Status::Active, Contract.Status::Extended,
            Contract.Status::Terminated);
        if Contract.FindSet() then
            repeat
                // FIX 27/10: grace period é janela APÓS o fim do contrato — a infração
                // precisa ser POSTERIOR ao Current End Date (antes, qualquer infração
                // dentro da vigência caía no grace e virava Linked).
                if (Contract."Current End Date" <> 0D) and (InfractionDate > Contract."Current End Date") then begin
                    if Authority.Get(GetLastAuthorityCode()) then
                        if Authority."Grace Period Days" > 0 then
                            GraceDays := Authority."Grace Period Days";
                    if InfractionDate <= CalcDate(StrSubstNo('<+%1D>', GraceDays), Contract."Current End Date") then
                        exit(true);
                end;
            until Contract.Next() = 0;
        exit(false);
    end;

    local procedure GetLastAuthorityCode(): Code[20]
    begin
        // Placeholder: na ingestão, a multa traz o órgão; a janela usa o órgão da multa.
        exit('');
    end;

    // ============================================================
    // FASE 4 — VINCULAÇÃO EM LOTE (job de cruzamento)
    // ============================================================
    procedure LinkAllUnlinkedFines(): Integer
    var
        Fine: Record "KINTO Traffic Fine";
        Linked: Integer;
    begin
        Fine.SetRange("Link Status", Fine."Link Status"::Unlinked);
        Fine.SetFilter(Status, '<>%1&<>%2', Fine.Status::Cancelled, Fine.Status::Rejected);
        if Fine.FindSet() then
            repeat
                if LinkFine(Fine) then
                    Linked += 1;
            until Fine.Next() = 0;
        exit(Linked);
    end;

    // ============================================================
    // FASE 4 — COBRANÇA AO CLIENTE (D2: gera Billing Lines)
    // Produtos: "Multa" (valor cliente) + taxas por evento (Fee Setup)
    // ============================================================
    procedure BillFineToCustomer(var Fine: Record "KINTO Traffic Fine")
    var
        Contract: Record "KINTO Vehicle Contract";
        BillingMonth: Date;
    begin
        if Fine."Contract No." = '' then
            Error(NoContractErr, Fine."Fine No.");
        if not (Fine.Status in [Fine.Status::"Penalty Issued", Fine.Status::Paid, Fine.Status::Registered,
            Fine.Status::"Driver Indicated", Fine.Status::"NIC Sent"])
        then
            Error(NotBilledErr, Fine."Fine No.");
        if Fine."Billing Line Entry No." <> 0 then
            Error(AlreadyBilledErr, Fine."Fine No.");

        Contract.Get(Fine."Contract No.");
        BillingMonth := CalcDate('<-CM>', WorkDate());

        // Linha principal: valor faturado ao cliente (RN-016)
        if Fine."Customer Amount" > 0 then begin
            CreateFineBillingLine(Fine, Contract, BillingMonth, 'FINE',
                StrSubstNo('Traffic fine %1 — %2 %3 (%4)',
                    Fine."Fine No.", Fine."Issuing Authority Code", Fine."AIIP Code",
                    Format(DT2Date(Fine."Infraction DateTime"), 0, '<Day,2>/<Month,2>/<Year4>')),
                Fine."Customer Amount", "KINTO Financial Product Type"::"Traffic Fine", Fine."Currency Code");
        end;

        // Taxas por evento (3 linhas do D2: boleto, envio, indicação) — as configuradas
        BillFineFeeIfConfigured(Fine, Contract, BillingMonth, "KINTO Fine Fee Type"::"Boleto Issuance");
        BillFineFeeIfConfigured(Fine, Contract, BillingMonth, "KINTO Fine Fee Type"::"Notification Send");
        BillFineFeeIfConfigured(Fine, Contract, BillingMonth, "KINTO Fine Fee Type"::"Driver Indication");

        Fine.Status := Fine.Status::Billed;
        Fine."Billing Month" := BillingMonth;
        Fine.Modify(true);
    end;

    local procedure BillFineFeeIfConfigured(var Fine: Record "KINTO Traffic Fine"; var Contract: Record "KINTO Vehicle Contract"; BillingMonth: Date; FeeType: Enum "KINTO Fine Fee Type")
    var
        FeeSetup: Record "KINTO Fine Fee Setup";
    begin
        FeeSetup.SetRange("Country Code", Fine."Country Code");
        FeeSetup.SetRange("Fee Type", FeeType);
        if FeeSetup.FindFirst() then
            if FeeSetup.Amount > 0 then
                CreateFineBillingLine(Fine, Contract, BillingMonth, FeeSetup."Financial Product Code",
                    CopyStr(StrSubstNo('Fine fee %1 — %2', FeeType, Fine."Fine No."), 1, 100),
                    FeeSetup.Amount, "KINTO Financial Product Type"::"Admin Fee", FeeSetup."Currency Code");
    end;

    local procedure CreateFineBillingLine(var Fine: Record "KINTO Traffic Fine"; var Contract: Record "KINTO Vehicle Contract"; BillingMonth: Date; ProductCode: Code[20]; Description: Text[100]; Amount: Decimal; ProductType: Enum "KINTO Financial Product Type"; CurrencyCode: Code[10])
    var
        BillingLine: Record "KINTO Billing Line";
        FinancialProduct: Record "KINTO Financial Product";
    begin
        if not FinancialProduct.Get(ProductCode) then begin
            FinancialProduct.Init();
            FinancialProduct."Product Code" := ProductCode;
            FinancialProduct.Description := ProductCode;
            FinancialProduct."Product Type" := ProductType;
            FinancialProduct."Separate Invoice" := true;
            FinancialProduct.Insert(true);
        end;

        BillingLine.Init();
        BillingLine."Contract No." := Contract."Contract No.";
        BillingLine."Customer No." := Contract."Customer No.";
        BillingLine."Vehicle No." := Contract."Vehicle No.";
        BillingLine."Billing Month" := BillingMonth;
        BillingLine."Condition ID" := '';
        BillingLine."Financial Product Code" := ProductCode;
        BillingLine."Product Type" := ProductType;
        BillingLine.Description := CopyStr(Description, 1, MaxStrLen(BillingLine.Description));
        BillingLine.Quantity := 1;
        BillingLine."Days Billed" := 30;
        BillingLine."Unit Price" := Amount;
        BillingLine.Amount := Amount;
        BillingLine."Billing Period From" := CalcDate('<-CM>', BillingMonth);
        BillingLine."Billing Period To" := CalcDate('<CM>', BillingMonth);
        BillingLine."Currency Code" := CurrencyCode;
        BillingLine."Cost Center Code" := Contract."Cost Center Code";
        BillingLine."Origin Description" := CopyStr(StrSubstNo('Fine %1', Fine."Fine No."), 1, MaxStrLen(BillingLine."Origin Description"));
        BillingLine.Status := BillingLine.Status::Open;
        BillingLine.Insert(true);

        if ProductType = "KINTO Financial Product Type"::"Traffic Fine" then
            Fine."Billing Line Entry No." := BillingLine."Entry No.";
    end;

    // ============================================================
    // FASE 4 — RECONCILIAÇÃO COM PAGAMENTO AO FORNECEDOR (D2)
    // ============================================================
    procedure MarkVendorPaid(var Fine: Record "KINTO Traffic Fine"; PaidDate: Date)
    begin
        Fine."Vendor Paid" := true;
        Fine."Vendor Paid Date" := PaidDate;
        Fine.Modify(true);
    end;

    procedure GetReconciliationStatus(var Fine: Record "KINTO Traffic Fine"): Integer
    begin
        // 0 = pendente dos dois lados; 1 = pago ao fornecedor, não cobrado;
        // 2 = cobrado ao cliente, não pago; 3 = reconciliado
        if Fine."Vendor Paid" and (Fine."Billing Line Entry No." <> 0) then
            exit(3);
        if Fine."Vendor Paid" then
            exit(1);
        if Fine."Billing Line Entry No." <> 0 then
            exit(2);
        exit(0);
    end;

    // ============================================================
    // FASE 4 — SETUP PADRÃO (chamado pelo install)
    // ============================================================
    procedure CreateDefaultSetup()
    var
        Authority: Record "KINTO Issuing Authority";
        FeeSetup: Record "KINTO Fine Fee Setup";
        FinProduct: Record "KINTO Financial Product";
    begin
        if not FinProduct.Get('FINE') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'FINE';
            FinProduct.Description := 'Traffic Fine';
            FinProduct."Product Type" := FinProduct."Product Type"::"Traffic Fine";
            FinProduct."Separate Invoice" := true;
            FinProduct.Insert(true);
        end;

        if not Authority.Get('DETRAN-SP') then begin
            Authority.Init();
            Authority.Code := 'DETRAN-SP';
            Authority.Name := 'DETRAN-SP';
            Authority."Country Code" := 'BR';
            Authority."SNE Adjustment %" := 60; // D2: 60/80% configurável
            Authority."Grace Period Days" := 60;
            Authority.Insert(true);
        end;

        if not Authority.Get('CET-SP') then begin
            Authority.Init();
            Authority.Code := 'CET-SP';
            Authority.Name := 'CET-SP';
            Authority."Country Code" := 'BR';
            Authority."SNE Adjustment %" := 80;
            Authority."Grace Period Days" := 60;
            Authority.Insert(true);
        end;

        // Taxas por evento (3 linhas do D2) — valores zerados p/ config do cliente
        if not FeeSetup.Get('BR', FeeSetup."Fee Type"::"Boleto Issuance") then begin
            FeeSetup.Init();
            FeeSetup."Country Code" := 'BR';
            FeeSetup."Fee Type" := FeeSetup."Fee Type"::"Boleto Issuance";
            FeeSetup."Financial Product Code" := 'ADMIN-FEE';
            FeeSetup.Insert(true);
        end;
        if not FeeSetup.Get('BR', FeeSetup."Fee Type"::"Notification Send") then begin
            FeeSetup.Init();
            FeeSetup."Country Code" := 'BR';
            FeeSetup."Fee Type" := FeeSetup."Fee Type"::"Notification Send";
            FeeSetup."Financial Product Code" := 'ADMIN-FEE';
            FeeSetup.Insert(true);
        end;
        if not FeeSetup.Get('BR', FeeSetup."Fee Type"::"Driver Indication") then begin
            FeeSetup.Init();
            FeeSetup."Country Code" := 'BR';
            FeeSetup."Fee Type" := FeeSetup."Fee Type"::"Driver Indication";
            FeeSetup."Financial Product Code" := 'ADMIN-FEE';
            FeeSetup.Insert(true);
        end;
    end;
}