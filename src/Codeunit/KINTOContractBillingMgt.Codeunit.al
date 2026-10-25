codeunit 50200 "KINTO Contract Billing Mgt."
{
    Permissions = tabledata "KINTO Vehicle Contract" = RIMD,
                  tabledata "KINTO Contract Condition" = RIMD,
                  tabledata "KINTO Billing Line" = RIMD,
                  tabledata "KINTO Contract Change Log" = RIMD,
                  tabledata "Sales Header" = RIMD,
                  tabledata "Sales Line" = RIMD;

    // ============================================================
    // FASE 1 — QUOTE → CONTRATO
    // ============================================================
    procedure CreateContractFromQuote(var QuoteHeader: Record "KINTO Quote Header"): Code[20]
    var
        QuoteItem: Record "KINTO Quote Item";
        Contract: Record "KINTO Vehicle Contract";
        Condition: Record "KINTO Contract Condition";
        FinancialProduct: Record "KINTO Financial Product";
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        MonthEnd: Date;
        NotApprovedErr: Label 'Quote %1 must be Approved before creating a contract.';
        NoItemsErr: Label 'Quote %1 has no items.';
        NoRentProductErr: Label 'Financial product RENT not found. Run the contract setup first.';
        MonthlyAmount: Decimal;
    begin
        if QuoteHeader."Pricing Status" <> QuoteHeader."Pricing Status"::Approved then
            Error(NotApprovedErr, QuoteHeader."Quote No.");

        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        if not QuoteItem.FindSet() then
            Error(NoItemsErr, QuoteHeader."Quote No.");

        if not FinancialProduct.Get('RENT') then
            Error(NoRentProductErr);

        Contract.Init();
        Contract."Contract No." := '';
        Contract."Customer No." := QuoteHeader."Customer No.";
        Contract."Quote No." := QuoteHeader."Quote No.";
        Contract."Country Code" := QuoteHeader."Country Code";
        Contract."Currency Code" := QuoteHeader."Currency Code";
        Contract."Start Date" := WorkDate();
        Contract."Contract Term (Months)" := QuoteItem."Contract Term (Months)";
        if Contract."Contract Term (Months)" <= 0 then
            Contract."Contract Term (Months)" := 12;
        MonthEnd := CalcDate('<CM>', WorkDate());
        Contract."Original End Date" := CalcDate(StrSubstNo('<+%1M>', Contract."Contract Term (Months)"), MonthEnd);
        Contract."Current End Date" := Contract."Original End Date";
        Contract."Monthly Mileage (km)" := QuoteItem."Monthly Mileage (km)";
        Contract."Payment Allowance Days" := QuoteHeader."Payment Allowance Days";
        Contract.Insert(true);

        // Uma condição RENT por item da cotação (pacotes entram como condições futuras)
        repeat
            MonthlyAmount := QuoteItem."Negotiated Monthly Price";
            if MonthlyAmount = 0 then
                MonthlyAmount := QuoteItem."Monthly Tariff";

            Condition.Init();
            Condition."Contract No." := Contract."Contract No.";
            Condition."Condition ID" := '';
            Condition."No. Series" := 'KINTO-COND';
            Condition."Financial Product Code" := 'RENT';
            Condition."Product Type" := FinancialProduct."Product Type";
            Condition.Description := FinancialProduct.Description;
            Condition."Monthly Amount" := MonthlyAmount;
            Condition."Valid From" := Contract."Start Date";
            Condition."Source Quote No." := QuoteHeader."Quote No.";
            Condition."Source Quote Line No." := QuoteItem."Line No.";
            Condition.Insert(true);
        until QuoteItem.Next() = 0;

        // Vincula veículo usado (se houver)
        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        QuoteItem.SetFilter("Inventory Vehicle No.", '<>%1', '');
        if QuoteItem.FindFirst() then
            if InventoryVehicle.Get(QuoteItem."Inventory Vehicle No.") then begin
                Contract."Vehicle No." := InventoryVehicle."Vehicle No.";
                Contract."Fixed Asset No." := InventoryVehicle."Fixed Asset No.";
                Contract.Modify(true);
            end;

        LogChange(Contract."Contract No.", "KINTO Contract Change Type"::Created,
            StrSubstNo('Contract created from quote %1', QuoteHeader."Quote No."));
        exit(Contract."Contract No.");
    end;

    // ============================================================
    // FASE 2 — MEDIÇÃO MENSAL (D6 PP-03)
    // ============================================================
    procedure GenerateBillingForContract(var Contract: Record "KINTO Vehicle Contract"; BillingMonth: Date)
    var
        Condition: Record "KINTO Contract Condition";
        BillingLine: Record "KINTO Billing Line";
        FinancialProduct: Record "KINTO Financial Product";
        MonthStart: Date;
        MonthEnd: Date;
        DaysBilled: Decimal;
        Prorated: Boolean;
    begin
        if not ContractIsBilledInMonth(Contract, BillingMonth) then
            Error(ContractNotActiveErr, Contract."Contract No.");

        // Idempotência: não duplica mês já faturado
        BillingLine.SetRange("Contract No.", Contract."Contract No.");
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        if not BillingLine.IsEmpty() then
            Error(AlreadyBilledErr, Contract."Contract No.", BillingMonth);

        MonthStart := CalcDate('<-CM>', BillingMonth);
        MonthEnd := CalcDate('<CM>', BillingMonth);

        // Medição por condição ativa na data (Condition ID versionado)
        Condition.Reset();
        Condition.SetRange("Contract No.", Contract."Contract No.");
        Condition.SetRange(Active, true);
        Condition.SetFilter("Valid From", '<=%1', MonthEnd);
        if Condition.FindSet() then
            repeat
                if (Condition."Valid To" = 0D) or (Condition."Valid To" >= MonthStart) then begin
                    FinancialProduct.Get(Condition."Financial Product Code");
                    if FinancialProduct."Service Item No." = '' then
                        Error(ProductNotFoundErr, Condition."Financial Product Code");

                    // RN-014 do D6: mês cheio = 30 dias; preço diário = mensal/30.
                    // Prorrata apenas na terminação dentro do mês.
                    Prorated := false;
                    DaysBilled := 30;
                    if (Contract."Termination Date" <> 0D) and
                       (Contract."Termination Date" >= MonthStart) and
                       (Contract."Termination Date" <= MonthEnd)
                    then begin
                        DaysBilled := Contract."Termination Date" - MonthStart + 1;
                        Prorated := true;
                    end;

                    CreateBillingLine(Contract, Condition, BillingMonth, MonthStart, MonthEnd, DaysBilled, Prorated);
                end;
            until Condition.Next() = 0;

        Contract."Last Billing Month" := BillingMonth;
        Contract.Modify(true);
        LogChange(Contract."Contract No.", "KINTO Contract Change Type"::BillingGenerated,
            StrSubstNo('Billing generated for %1', Format(BillingMonth, 0, '<Month,2>/<Year4>')));
    end;

    local procedure CreateBillingLine(var Contract: Record "KINTO Vehicle Contract"; var Condition: Record "KINTO Contract Condition"; BillingMonth: Date; PeriodFrom: Date; PeriodTo: Date; DaysBilled: Decimal; Prorated: Boolean)
    var
        BillingLine: Record "KINTO Billing Line";
    begin
        BillingLine.Init();
        BillingLine."Contract No." := Contract."Contract No.";
        BillingLine."Billing Month" := BillingMonth;
        BillingLine."Condition ID" := Condition."Condition ID";
        BillingLine."Financial Product Code" := Condition."Financial Product Code";
        BillingLine."Product Type" := Condition."Product Type";
        BillingLine.Description := Condition.Description;
        BillingLine.Quantity := 1;
        BillingLine."Days Billed" := DaysBilled;
        BillingLine."Unit Price" := Round(Condition."Daily Amount" * DaysBilled, 0.01);
        BillingLine.Amount := BillingLine."Unit Price";
        BillingLine."Billing Period From" := PeriodFrom;
        BillingLine."Billing Period To" := PeriodTo;
        BillingLine.Prorated := Prorated;
        BillingLine."Currency Code" := Contract."Currency Code";
        BillingLine.Status := BillingLine.Status::Open;
        BillingLine.Insert(true);
    end;

    local procedure ContractIsBilledInMonth(var Contract: Record "KINTO Vehicle Contract"; BillingMonth: Date): Boolean
    var
        MonthStart: Date;
        MonthEnd: Date;
    begin
        MonthStart := CalcDate('<-CM>', BillingMonth);
        MonthEnd := CalcDate('<CM>', BillingMonth);
        if Contract."Start Date" > MonthEnd then
            exit(false);
        if (Contract."Current End Date" <> 0D) and (Contract."Current End Date" < MonthStart) then
            exit(false);
        if Contract.Status in [Contract.Status::Draft, Contract.Status::Cancelled] then
            exit(false);
        exit(true);
    end;

    // ============================================================
    // FASE 2 — APROVAÇÃO E FATURAMENTO (D6 PP-03/PP-04)
    // ============================================================
    procedure ApproveContractLines(ContractNo: Code[20]; BillingMonth: Date): Integer
    var
        BillingLine: Record "KINTO Billing Line";
        LineCount: Integer;
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetRange(Status, BillingLine.Status::Open);
        if BillingLine.FindSet() then
            repeat
                BillingLine.Approve();
                LineCount += 1;
            until BillingLine.Next() = 0;
        exit(LineCount);
    end;

    procedure InvoiceApprovedLines(ContractNo: Code[20]; BillingMonth: Date): Integer
    var
        BillingLine: Record "KINTO Billing Line";
        InvoicedCount: Integer;
    begin
        // RN-007 do D6: produto financeiro com Separate Invoice gera documento próprio;
        // os demais produtos são agrupados numa única fatura do contrato/mês.
        InvoicedCount := InvoiceGroup(ContractNo, BillingMonth, false, '');

        BillingLine.Reset();
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetRange(Status, BillingLine.Status::Approved);
        if BillingLine.FindSet() then
            repeat
                if ProductSeparatesInvoice(BillingLine."Financial Product Code") then
                    InvoicedCount += InvoiceGroup(ContractNo, BillingMonth, true, BillingLine."Financial Product Code");
            until BillingLine.Next() = 0;

        exit(InvoicedCount);
    end;

    local procedure InvoiceGroup(ContractNo: Code[20]; BillingMonth: Date; OnlySeparate: Boolean; ProductCode: Code[20]): Integer
    var
        BillingLine: Record "KINTO Billing Line";
        Contract: Record "KINTO Vehicle Contract";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinancialProduct: Record "KINTO Financial Product";
        LineNo: Integer;
        LineCount: Integer;
    begin
        BillingLine.Reset();
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetRange(Status, BillingLine.Status::Approved);
        if ProductCode <> '' then
            BillingLine.SetRange("Financial Product Code", ProductCode);
        if not BillingLine.FindSet() then
            exit(0);

        Contract.Get(ContractNo);

        // Sales Invoice com item de serviço (Item Type=Service) — licença Essential
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Contract."Customer No.");
        SalesHeader.Validate("Posting Date", CalcDate('<CM>', BillingMonth));
        if Contract."Currency Code" <> '' then
            SalesHeader.Validate("Currency Code", Contract."Currency Code");
        if Contract."Cost Center Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", Contract."Cost Center Code");
        SalesHeader."KINTO Contract No." := Contract."Contract No.";
        SalesHeader."KINTO Billing Month" := BillingMonth;
        SalesHeader.Modify(true);

        LineNo := 10000;
        LineCount := 0;
        repeat
            if OnlySeparate or (not ProductSeparatesInvoice(BillingLine."Financial Product Code")) then begin
                FinancialProduct.Get(BillingLine."Financial Product Code");
                SalesLine.Init();
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.Insert(true);
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", FinancialProduct."Service Item No.");
                SalesLine.Validate(Quantity, BillingLine.Quantity);
                SalesLine.Validate("Unit Price", BillingLine."Unit Price");
                SalesLine.Description := CopyStr(BillingLine.Description, 1, MaxStrLen(SalesLine.Description));
                if Contract."Cost Center Code" <> '' then
                    SalesLine.Validate("Shortcut Dimension 1 Code", Contract."Cost Center Code");
                SalesLine.Modify(true);

                BillingLine.Status := BillingLine.Status::Invoiced;
                BillingLine."Sales Invoice No." := SalesHeader."No.";
                BillingLine.Modify(true);
                LineNo += 10000;
                LineCount += 1;
            end;
        until BillingLine.Next() = 0;

        exit(LineCount);
    end;

    local procedure ProductSeparatesInvoice(ProductCode: Code[20]): Boolean
    var
        FinancialProduct: Record "KINTO Financial Product";
    begin
        if FinancialProduct.Get(ProductCode) then
            exit(FinancialProduct."Separate Invoice");
        exit(true); // conservador: produto desconhecido fatura separado
    end;

    // ============================================================
    // FASE 2 — REAJUSTE POR ÍNDICE (D6 PP-01)
    // ============================================================
    procedure ApplyPriceAdjustment(var Contract: Record "KINTO Vehicle Contract"; AdjustmentMonth: Date)
    var
        Condition: Record "KINTO Contract Condition";
        IndexEntry: Record "KINTO Price Index Entry";
        NewAmount: Decimal;
        AppliedCount: Integer;
        NoIndexErr: Label 'Contract %1 has no price index configured.';
    begin
        if Contract."Price Index Code" = '' then
            Error(NoIndexErr, Contract."Contract No.");

        IndexEntry.SetRange("Index Code", Contract."Price Index Code");
        IndexEntry.SetFilter("Valid From", '<%1', CalcDate('<-CM>', AdjustmentMonth));
        if not IndexEntry.FindLast() then
            exit;

        Condition.Reset();
        Condition.SetRange("Contract No.", Contract."Contract No.");
        Condition.SetRange(Active, true);
        if Condition.FindSet() then
            repeat
                NewAmount := Condition."Monthly Amount" * (1 + MinDec(IndexEntry."Variation %", Contract."Index Cap %") / 100);
                Condition.CreateRevision(Round(NewAmount, 0.01), CalcDate('<CM+1D>', AdjustmentMonth));
                AppliedCount += 1;
            until Condition.Next() = 0;

        if AppliedCount > 0 then
            LogChange(Contract."Contract No.", "KINTO Contract Change Type"::ConditionChanged,
                StrSubstNo('Price adjustment: index %1, variation %2%, %3 condition(s)',
                    Contract."Price Index Code", IndexEntry."Variation %", AppliedCount));
    end;

    local procedure MinDec(A: Decimal; B: Decimal): Decimal
    begin
        if B = 0 then
            exit(A);
        if A < B then
            exit(A);
        exit(B);
    end;

    // ============================================================
    // LOG
    // ============================================================
    procedure LogChange(ContractNo: Code[20]; ChangeType: Enum "KINTO Contract Change Type"; Description: Text[250])
    var
        ChangeLog: Record "KINTO Contract Change Log";
    begin
        ChangeLog.Init();
        ChangeLog."Contract No." := ContractNo;
        ChangeLog."Change Type" := ChangeType;
        ChangeLog.Description := Description;
        ChangeLog.Insert(true);
    end;

    var
        ContractNotActiveErr: Label 'Contract %1 is not active in the billing month.';
        ProductNotFoundErr: Label 'Financial product %1 not found or has no service item.';
        AlreadyBilledErr: Label 'Contract %1 already has billing lines for month %2.';
}