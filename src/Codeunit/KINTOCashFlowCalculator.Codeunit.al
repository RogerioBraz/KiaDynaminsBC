codeunit 50102 "KINTO Cash Flow Calculator"
{
    // CORREÇÃO: Removido Caption — codeunits não suportam esta propriedade

    procedure GenerateCashFlow(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        CFHeader: Record "KINTO Cash Flow Header";
        CFData: Record "KINTO Cash Flow Data";
        MonthNo: Integer;
        MonthDate: Date;
        InflationFactor: Decimal;
        TotalMonths: Integer;
    begin
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        if CFData.FindSet() then CFData.DeleteAll();

        CFHeader.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFHeader.SetRange("Quote Line No.", QuoteItem."Line No.");
        if CFHeader.FindFirst() then CFHeader.Delete();

        CFHeader.Init();
        CFHeader."Quote No." := QuoteHeader."Quote No.";
        CFHeader."Quote Line No." := QuoteItem."Line No.";
        CFHeader."Contract Term" := QuoteItem."Contract Term (Months)";
        CFHeader.Insert(true);

        TotalMonths := QuoteItem."Contract Term (Months)" + QuoteItem."Extended Analysis Months";

        GenerateMonthZero(CFData, QuoteHeader, QuoteItem);

        for MonthNo := 1 to TotalMonths do begin
            MonthDate := CalcDate('+' + Format(MonthNo) + 'M', Today);
            InflationFactor := CalculateInflationFactor(QuoteItem, MonthNo);
            GenerateMonthlyEntries(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, InflationFactor);
        end;

        GenerateEndOfContract(CFData, QuoteHeader, QuoteItem, QuoteItem."Contract Term (Months)");
    end;

    local procedure GenerateMonthZero(var CFData: Record "KINTO Cash Flow Data"; var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        if QuoteItem."Purchase Price" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'PURCHASE_PRICE',
                'Purchase Price', "KINTO CF Component Type"::Cost, -QuoteItem."Purchase Price", 0, 1);

        if QuoteItem."Vehicle Registration Cost" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'VEH_REGISTRATION',
                'Vehicle Registration', "KINTO CF Component Type"::Cost, -QuoteItem."Vehicle Registration Cost", 0, 1);

        if QuoteItem."DLR Commission Amount" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'DLR_COMMISSION_ONESHOT',
                'DLR Commission (One-Shot)', "KINTO CF Component Type"::Commission, -QuoteItem."DLR Commission Amount", 0, 1);
    end;

    local procedure GenerateMonthlyEntries(var CFData: Record "KINTO Cash Flow Data"; var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; MonthNo: Integer; MonthDate: Date; InflationFactor: Decimal)
    var
        PackagePricing: Codeunit "KINTO Package Pricing Calc";
        PkgMonthly: Decimal;
        MonthlyTariff: Decimal;
    begin
        MonthlyTariff := QuoteItem."Monthly Tariff" * InflationFactor;
        if MonthlyTariff > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'MONTHLY_TARIFF',
                'Monthly Tariff', "KINTO CF Component Type"::Revenue, MonthlyTariff, 0, InflationFactor);

        // PIS/COFINS — agora carregado do Country Setup via LoadCountryParameters
        if QuoteItem."PIS COFINS Tariff %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'PIS_COFINS_TARIFF',
                'PIS/COFINS on Tariff', "KINTO CF Component Type"::Tax,
                -(MonthlyTariff * QuoteItem."PIS COFINS Tariff %" / 100 * InflationFactor), 0, InflationFactor);

        if QuoteItem."Tax Depreciation Period" > 0 then
            if MonthNo <= QuoteItem."Tax Depreciation Period" then
                InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'TAX_DEPRECIATION',
                    'Tax Depreciation', "KINTO CF Component Type"::Depreciation,
                    -(QuoteItem."Purchase Price" / QuoteItem."Tax Depreciation Period" * InflationFactor), 0, InflationFactor);

        if QuoteItem."IPVA Rate %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'IPVA',
                'IPVA', "KINTO CF Component Type"::Tax,
                -(QuoteItem."Purchase Price" * QuoteItem."IPVA Rate %" / 100 / 12 * InflationFactor), 0, InflationFactor);

        if QuoteItem."DPVAT Licensing" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'DPVAT_LICENSING',
                'DPVAT + Licensing', "KINTO CF Component Type"::Cost,
                -(QuoteItem."DPVAT Licensing" / 12 * InflationFactor), 0, InflationFactor);

        if QuoteItem."Body Insurance" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'BODY_INSURANCE',
                'Body Insurance (Monthly)', "KINTO CF Component Type"::Cost,
                -(QuoteItem."Body Insurance" * InflationFactor), 0, InflationFactor);

        if QuoteItem."Telematics Monthly" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'TELEMATICS',
                'Telematics', "KINTO CF Component Type"::Cost,
                -(QuoteItem."Telematics Monthly" * InflationFactor), 0, InflationFactor);

        if QuoteItem."Traffic Fine Fee Monthly" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'TRAFFIC_FINE_FEE',
                'Traffic Fine Fee', "KINTO CF Component Type"::Cost,
                -(QuoteItem."Traffic Fine Fee Monthly" * InflationFactor), 0, InflationFactor);

        if QuoteItem."SGA Amount" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'SGA',
                'SG&A', "KINTO CF Component Type"::Cost,
                -(QuoteItem."SGA Amount" * InflationFactor), 0, InflationFactor);

        if QuoteItem."Interest Rate %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'INTEREST_EXPENSE',
                'Interest Expense', "KINTO CF Component Type"::Cost,
                -(QuoteItem."Purchase Price" * QuoteItem."Interest Rate %" / 100 / 12 * InflationFactor), 0, InflationFactor);

        if QuoteItem."Idleness Rate %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'IDLENESS',
                'Idleness', "KINTO CF Component Type"::Cost,
                -(MonthlyTariff * QuoteItem."Idleness Rate %" / 100 * InflationFactor), 0, InflationFactor);

        if QuoteItem."Credit Risk %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'CREDIT_RISK',
                'Credit Risk', "KINTO CF Component Type"::Cost,
                -(MonthlyTariff * QuoteItem."Credit Risk %" / 100 * InflationFactor), 0, InflationFactor);

        // PACOTES
        PkgMonthly := PackagePricing.GetGlassCoverageMonthly(QuoteItem);
        if PkgMonthly > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'GLASS_COVERAGE',
                'Glass Coverage', "KINTO CF Component Type"::Cost, -PkgMonthly * InflationFactor, 0, InflationFactor);

        PkgMonthly := PackagePricing.Get24hAssistanceMonthly(QuoteItem);
        if PkgMonthly > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'ASSISTANCE_24H',
                '24h Assistance', "KINTO CF Component Type"::Cost, -PkgMonthly * InflationFactor, 0, InflationFactor);

        PkgMonthly := PackagePricing.GetPickupDeliveryMonthly(QuoteItem);
        if PkgMonthly > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'PICKUP_DELIVERY',
                'Pick-up and Delivery', "KINTO CF Component Type"::Cost, -PkgMonthly * InflationFactor, 0, InflationFactor);

        PkgMonthly := PackagePricing.GetReplacementVehicleMonthly(QuoteItem);
        if PkgMonthly > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'REPLACEMENT_VEH',
                'Replacement Vehicle', "KINTO CF Component Type"::Cost, -PkgMonthly * InflationFactor, 0, InflationFactor);

        PkgMonthly := PackagePricing.GetTireMonthly(QuoteItem);
        if PkgMonthly > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'TIRE_PACKAGE',
                'Tire Package', "KINTO CF Component Type"::Cost, -PkgMonthly * InflationFactor, 0, InflationFactor);

        PkgMonthly := PackagePricing.GetServiceMonthly(QuoteItem);
        if PkgMonthly > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'SERVICE_FEE',
                'Service Fee (Telematics)', "KINTO CF Component Type"::Cost, -PkgMonthly * InflationFactor, 0, InflationFactor);

        PkgMonthly := PackagePricing.GetMaintenanceMonthly(QuoteItem);
        if PkgMonthly > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'MAINTENANCE_COST',
                'Maintenance Cost', "KINTO CF Component Type"::Cost, -PkgMonthly * InflationFactor, 0, InflationFactor);
    end;

    local procedure GenerateEndOfContract(var CFData: Record "KINTO Cash Flow Data"; var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; MonthNo: Integer)
    var
        EndDate: Date;
    begin
        EndDate := CalcDate('+' + Format(MonthNo) + 'M', Today);

        if QuoteItem."Final Resale Price" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, EndDate, 'RESALE_PRICE',
                'Resale Price', "KINTO CF Component Type"::Resale, QuoteItem."Final Resale Price", 0, 1);

        if QuoteItem."Resale Cost %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, EndDate, 'RESALE_COST',
                'Resale Cost', "KINTO CF Component Type"::Cost,
                -(QuoteItem."Final Resale Price" * QuoteItem."Resale Cost %" / 100), 0, 1);
    end;

    local procedure InsertCFEntry(var CFData: Record "KINTO Cash Flow Data"; var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; MonthNo: Integer; MonthDate: Date; ComponentID: Code[30]; CompDesc: Text[100]; CompType: Enum "KINTO CF Component Type"; Amount: Decimal; AccumMileage: Decimal; InflationFactor: Decimal)
    begin
        CFData.Init();
        CFData."Quote No." := QuoteHeader."Quote No.";
        CFData."Quote Line No." := QuoteItem."Line No.";
        CFData."Month No." := MonthNo;
        CFData."Month Date" := MonthDate;
        CFData."Component ID" := ComponentID;
        CFData."Component Description" := CompDesc;
        CFData."Component Type" := CompType;
        CFData."Amount" := Abs(Amount);
        CFData."Signed Amount" := Amount;
        CFData."Accumulated Mileage" := AccumMileage + (QuoteItem."Monthly Mileage (km)" * MonthNo);
        CFData."Inflation Factor" := InflationFactor;
        CFData."Indexation Applied" := InflationFactor <> 1;
        CFData.Insert(true);
    end;

    local procedure CalculateInflationFactor(var QuoteItem: Record "KINTO Quote Item"; MonthNo: Integer): Decimal
    var
        AnnualFactor: Decimal;
    begin
        if QuoteItem."Annual Inflation %" = 0 then exit(1);
        AnnualFactor := 1 + QuoteItem."Annual Inflation %" / 100;
        exit(Round(Power(AnnualFactor, MonthNo / 12), 0.000001));
    end;

    procedure CalculateTotalCosts(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        PackagePricing: Codeunit "KINTO Package Pricing Calc";
        TotalCosts: Decimal;
        MonthlyTariff: Decimal;
    begin
        TotalCosts := 0;
        MonthlyTariff := QuoteItem."Monthly Tariff";
        if MonthlyTariff = 0 then MonthlyTariff := 1;

        if QuoteItem."PIS COFINS Tariff %" > 0 then
            TotalCosts += MonthlyTariff * QuoteItem."PIS COFINS Tariff %" / 100;
        if QuoteItem."Tax Depreciation Period" > 0 then
            TotalCosts += QuoteItem."Purchase Price" / QuoteItem."Tax Depreciation Period";
        if QuoteItem."IPVA Rate %" > 0 then
            TotalCosts += QuoteItem."Purchase Price" * QuoteItem."IPVA Rate %" / 100 / 12;
        TotalCosts += QuoteItem."DPVAT Licensing" / 12;
        TotalCosts += QuoteItem."Body Insurance";
        TotalCosts += QuoteItem."Telematics Monthly";
        TotalCosts += QuoteItem."Traffic Fine Fee Monthly";
        TotalCosts += QuoteItem."SGA Amount";
        if QuoteItem."Interest Rate %" > 0 then
            TotalCosts += QuoteItem."Purchase Price" * QuoteItem."Interest Rate %" / 100 / 12;
        TotalCosts += MonthlyTariff * QuoteItem."Idleness Rate %" / 100;
        TotalCosts += MonthlyTariff * QuoteItem."Credit Risk %" / 100;
        TotalCosts += MonthlyTariff * QuoteItem."DLR Sales Commission %" / 100;
        TotalCosts += MonthlyTariff * QuoteItem."DLR Delivery Commission %" / 100;
        TotalCosts += PackagePricing.CalculateAllPackageCosts(QuoteHeader, QuoteItem);

        TotalCosts := TotalCosts * QuoteItem."Contract Term (Months)";
        TotalCosts += QuoteItem."Vehicle Registration Cost";
        TotalCosts += QuoteItem."DLR Commission Amount";

        if QuoteItem."Resale Cost %" > 0 then
            TotalCosts += QuoteItem."Final Resale Price" * QuoteItem."Resale Cost %" / 100;

        exit(TotalCosts);
    end;

    procedure GetBodyInsuranceAmount(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        InsQuote: Record "KINTO Insurance Quote";
    begin
        if QuoteItem."Insurance Quote No." <> '' then
            if InsQuote.Get(QuoteItem."Insurance Quote No.") then
                if InsQuote."Insurance Value" > 0 then
                    exit(InsQuote."Insurance Value");
        exit(QuoteItem."Body Insurance");
    end;

    procedure CalculateIRR(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        CFData: Record "KINTO Cash Flow Data";
        CashFlows: array[200] of Decimal;
        MonthIdx: Integer;
        MaxMonth: Integer;
    begin
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        if CFData.FindSet() then
            repeat
                MonthIdx := CFData."Month No." + 1;
                if MonthIdx <= 200 then
                    CashFlows[MonthIdx] += CFData."Signed Amount";
                if MonthIdx > MaxMonth then
                    MaxMonth := MonthIdx;
            until CFData.Next() = 0;

        if MaxMonth < 2 then exit(0);
        exit(CalculateIRRSimple(CashFlows, MaxMonth));
    end;

    local procedure CalculateIRRSimple(var CashFlows: array[200] of Decimal; MaxMonth: Integer): Decimal
    var
        i: Integer;
        NPV: Decimal;
        Rate: Decimal;
        BestRate: Decimal;
        BestNPV: Decimal;
    begin
        BestRate := 0;
        BestNPV := 0;
        Rate := 0.001;
        while Rate < 1.0 do begin
            NPV := 0;
            for i := 1 to MaxMonth do
                NPV += CashFlows[i] / Power(1 + Rate, i);

            if Abs(NPV) < Abs(BestNPV) then begin
                BestNPV := NPV;
                BestRate := Rate;
            end;

            if NPV < 0 then
                Rate := Rate + 0.01
            else
                Rate := Rate + 0.001;
        end;
        exit(Round(BestRate * 100, 0.01));
    end;

    procedure CalculateROI(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        TotalRevenue: Decimal;
        TotalCost: Decimal;
    begin
        TotalRevenue := QuoteItem."Monthly Tariff" * QuoteItem."Contract Term (Months)";
        TotalRevenue += QuoteItem."Final Resale Price";
        TotalCost := QuoteItem."Purchase Price";
        TotalCost += CalculateTotalCosts(QuoteHeader, QuoteItem);
        if TotalCost = 0 then exit(0);
        exit(Round((TotalRevenue - TotalCost) / TotalCost * 100, 0.01));
    end;

    procedure CalculateEBT(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        TotalRevenue: Decimal;
        TotalCost: Decimal;
    begin
        TotalRevenue := QuoteItem."Monthly Tariff" * QuoteItem."Contract Term (Months)";
        TotalRevenue += QuoteItem."Final Resale Price";
        TotalRevenue -= QuoteItem."Purchase Price";
        TotalCost := CalculateTotalCosts(QuoteHeader, QuoteItem);
        exit(Round(TotalRevenue - TotalCost, 0.01));
    end;

    procedure CalculateFCF(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        EBTValue: Decimal;
    begin
        EBTValue := CalculateEBT(QuoteHeader, QuoteItem);
        exit(Round(EBTValue * (1 - QuoteItem."Profit Tax Rate %" / 100), 0.01));
    end;
}