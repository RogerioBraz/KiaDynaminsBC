codeunit 50201 "KINTO Contract Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        CreateContractNumberSeries();
        CreateDefaultFinancialProducts();
        CreateDefaultPoolTypes();
        CreateDefaultPriceIndexes();
        CreateFineSetup();
        CreateTerminationSetup();
    end;

    local procedure CreateTerminationSetup()
    var
        TermMgt: Codeunit "KINTO Termination Management";
    begin
        // Séries KINTO-RET / KINTO-REC + setup de terminação
        TermMgt.CreateDefaultSetup();
    end;

    local procedure CreateFineSetup()
    var
        FineMgt: Codeunit "KINTO Fine Management";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Fine No. Series (Fase 4)
        if not NoSeries.Get('KINTO-FINE') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-FINE';
            NoSeries.Description := 'KINTO Traffic Fine Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-FINE';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'F-00001';
            NoSeriesLine."Ending No." := 'F-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Setup de multas: produtos, órgãos autuadores (SNE 60/80%), taxas por evento
        FineMgt.CreateDefaultSetup();
    end;

    local procedure CreateContractNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Vehicle Contract No. Series
        if not NoSeries.Get('KINTO-CONTR') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-CONTR';
            NoSeries.Description := 'KINTO Vehicle Contract Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-CONTR';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'C-00001';
            NoSeriesLine."Ending No." := 'C-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Condition ID No. Series
        if not NoSeries.Get('KINTO-COND') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-COND';
            NoSeries.Description := 'KINTO Contract Condition IDs';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-COND';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'CD-00001';
            NoSeriesLine."Ending No." := 'CD-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Maintenance Ticket No. Series (Fase 3)
        if not NoSeries.Get('KINTO-TICK') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-TICK';
            NoSeries.Description := 'KINTO Maintenance Ticket Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-TICK';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'TK-00001';
            NoSeriesLine."Ending No." := 'TK-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Device No. Series (D7)
        if not NoSeries.Get('KINTO-DEV') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-DEV';
            NoSeries.Description := 'KINTO Telematic Device Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-DEV';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'DEV-00001';
            NoSeriesLine."Ending No." := 'DEV-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Claim No. Series (D3c)
        if not NoSeries.Get('KINTO-CLM') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-CLM';
            NoSeries.Description := 'KINTO Claim Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-CLM';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'CLM-00001';
            NoSeriesLine."Ending No." := 'CLM-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Substitution No. Series (D5)
        if not NoSeries.Get('KINTO-SUB') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-SUB';
            NoSeries.Description := 'KINTO Contract Substitution Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-SUB';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'SUB-00001';
            NoSeriesLine."Ending No." := 'SUB-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Settlement No. Series (D5)
        if not NoSeries.Get('KINTO-STL') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-STL';
            NoSeries.Description := 'KINTO Settlement Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-STL';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'STL-00001';
            NoSeriesLine."Ending No." := 'STL-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Remarketing Offer No. Series (D8)
        if not NoSeries.Get('KINTO-RMK') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-RMK';
            NoSeries.Description := 'KINTO Remarketing Offer Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-RMK';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'RMK-00001';
            NoSeriesLine."Ending No." := 'RMK-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Remarketing Sale No. Series (D8)
        if not NoSeries.Get('KINTO-RMS') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-RMS';
            NoSeries.Description := 'KINTO Remarketing Sale Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-RMS';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'RMS-00001';
            NoSeriesLine."Ending No." := 'RMS-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Policy No. Series (D7)
        if not NoSeries.Get('KINTO-POL') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-POL';
            NoSeries.Description := 'KINTO Insurance Policy Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-POL';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'POL-00001';
            NoSeriesLine."Ending No." := 'POL-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;
    end;

    local procedure CreateDefaultFinancialProducts()
    var
        FinProduct: Record "KINTO Financial Product";
    begin
        // RENT é obrigatório para quote→contrato (CreateContractFromQuote).
        // Vincular "Service Item No." a itens reais (Type=Service) no setup do cliente.
        if not FinProduct.Get('RENT') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'RENT';
            FinProduct.Description := 'Vehicle Rent';
            FinProduct."Product Type" := FinProduct."Product Type"::Rent;
            FinProduct."Separate Invoice" := false;
            FinProduct."Credit Allowed" := true;
            FinProduct."Credit Limit % of Billing" := 2;
            FinProduct.Insert(true);
        end;

        if not FinProduct.Get('SVC-CREDIT') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'SVC-CREDIT';
            FinProduct.Description := 'Service Credit (days without service)';
            FinProduct."Product Type" := FinProduct."Product Type"::Credit;
            FinProduct."Separate Invoice" := false;
            FinProduct."Credit Allowed" := true;
            FinProduct."Credit Limit % of Billing" := 2;
            FinProduct.Insert(true);
        end;

        if not FinProduct.Get('FINE') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'FINE';
            FinProduct.Description := 'Traffic Fine';
            FinProduct."Product Type" := FinProduct."Product Type"::"Traffic Fine";
            FinProduct."Separate Invoice" := true;
            FinProduct.Insert(true);
        end;

        if not FinProduct.Get('ADMIN-FEE') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'ADMIN-FEE';
            FinProduct.Description := 'Administrative Fee';
            FinProduct."Product Type" := FinProduct."Product Type"::"Admin Fee";
            FinProduct."Separate Invoice" := true;
            FinProduct.Insert(true);
        end;

        if not FinProduct.Get('ADD-SERVICE') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'ADD-SERVICE';
            FinProduct.Description := 'Additional Service (Maintenance)';
            FinProduct."Product Type" := FinProduct."Product Type"::"Additional Service";
            FinProduct."Separate Invoice" := true;
            FinProduct.Insert(true);
        end;

        if not FinProduct.Get('PEN-RETENTION') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'PEN-RETENTION';
            FinProduct.Description := 'Contractual Retention Fee';
            FinProduct."Product Type" := FinProduct."Product Type"::Penalty;
            FinProduct."Separate Invoice" := true;
            FinProduct.Insert(true);
        end;

        if not FinProduct.Get('PEN-RECISSION') then begin
            FinProduct.Init();
            FinProduct."Product Code" := 'PEN-RECISSION';
            FinProduct.Description := 'Early Termination Fee';
            FinProduct."Product Type" := FinProduct."Product Type"::Penalty;
            FinProduct."Separate Invoice" := true;
            FinProduct.Insert(true);
        end;
    end;

    local procedure CreateDefaultPoolTypes()
    var
        PoolType: Record "KINTO Pool Type";
    begin
        if not PoolType.Get('RESERVE-DAYS') then begin
            PoolType.Init();
            PoolType."Code" := 'RESERVE-DAYS';
            PoolType.Description := 'Replacement Vehicle Days';
            PoolType."Unit of Measure" := PoolType."Unit of Measure"::Days;
            PoolType."Shared Across Vehicles" := true; // RN-036 do D1
            PoolType.Insert(true);
        end;

        if not PoolType.Get('TIRES') then begin
            PoolType.Init();
            PoolType."Code" := 'TIRES';
            PoolType.Description := 'Tire Pool';
            PoolType."Unit of Measure" := PoolType."Unit of Measure"::Units;
            PoolType."Shared Across Vehicles" := true;
            PoolType.Insert(true);
        end;

        if not PoolType.Get('KM-POOL') then begin
            PoolType.Init();
            PoolType."Code" := 'KM-POOL';
            PoolType.Description := 'Mileage Pool';
            PoolType."Unit of Measure" := PoolType."Unit of Measure"::km;
            PoolType."Shared Across Vehicles" := false;
            PoolType.Insert(true);
        end;

        if not PoolType.Get('MONETARY') then begin
            PoolType.Init();
            PoolType."Code" := 'MONETARY';
            PoolType.Description := 'Monetary Balance';
            PoolType."Unit of Measure" := PoolType."Unit of Measure"::Monetary;
            PoolType.Monetary := true;
            PoolType."Shared Across Vehicles" := true;
            PoolType.Insert(true);
        end;
    end;

    local procedure CreateDefaultPriceIndexes()
    var
        PriceIndex: Record "KINTO Price Index";
    begin
        if not PriceIndex.Get('IPCA') then begin
            PriceIndex.Init();
            PriceIndex."Index Code" := 'IPCA';
            PriceIndex.Description := 'IPCA (Brazil)';
            PriceIndex."Country Code" := 'BR';
            PriceIndex.Insert(true);
        end;

        if not PriceIndex.Get('IPC') then begin
            PriceIndex.Init();
            PriceIndex."Index Code" := 'IPC';
            PriceIndex.Description := 'IPC (Argentina)';
            PriceIndex."Country Code" := 'AR';
            PriceIndex.Insert(true);
        end;
    end;
}