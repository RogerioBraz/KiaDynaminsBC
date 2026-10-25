codeunit 50201 "KINTO Contract Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        CreateContractNumberSeries();
        CreateDefaultFinancialProducts();
        CreateDefaultPoolTypes();
        CreateDefaultPriceIndexes();
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