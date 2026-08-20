codeunit 50102 "KINTO Cash Flow Calculator"
{

    procedure GenerateCashFlow(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        CFHeader: Record "KINTO Cash Flow Header";
        CFData: Record "KINTO Cash Flow Data";
        TotalMonths: Integer;
        MonthNo: Integer;
        MonthDate: Date;
        AccumulatedMileage: Decimal;
        InflationFactor: Decimal;
        MaintenanceInflationFactor: Decimal;
    begin
        // Delete existing cash flow
        CFHeader.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFHeader.SetRange("Quote Line No.", QuoteItem."Line No.");
        if CFHeader.FindFirst() then begin
            CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
            CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
            CFData.DeleteAll();
            CFHeader.Delete();
        end;

        TotalMonths := QuoteItem."Contract Term (Months)" + QuoteItem."Extended Analysis Months";
        AccumulatedMileage := 0;
        InflationFactor := 1;
        MaintenanceInflationFactor := 1;

        // Create CF Header
        CFHeader.Init();
        CFHeader."Quote No." := QuoteHeader."Quote No.";
        CFHeader."Quote Line No." := QuoteItem."Line No.";
        CFHeader."Total Months" := TotalMonths;
        CFHeader."Contract Term" := QuoteItem."Contract Term (Months)";
        CFHeader."Extended Months" := QuoteItem."Extended Analysis Months";
        CFHeader."Start Date" := Today;
        CFHeader."End Date" := CalcDate('+' + Format(TotalMonths) + 'M', Today);
        CFHeader.Insert(true);

        // Month Zero
        GenerateMonthZero(QuoteHeader, QuoteItem, CFData, InflationFactor, MaintenanceInflationFactor);

        // Months 1..N
        for MonthNo := 1 to TotalMonths do begin
            MonthDate := CalcDate('+' + Format(MonthNo) + 'M', Today);
            AccumulatedMileage += QuoteItem."Monthly Mileage (km)";

            // Apply inflation
            ApplyInflation(QuoteHeader, QuoteItem, MonthNo, InflationFactor, MaintenanceInflationFactor);

            GenerateMonthlyEntries(QuoteHeader, QuoteItem, CFData, MonthNo, MonthDate,
                                   AccumulatedMileage, InflationFactor, MaintenanceInflationFactor);
        end;

        // End-of-Contract entries (Resale)
        GenerateEndOfContract(QuoteHeader, QuoteItem, CFData, TotalMonths);
    end;

    local procedure GenerateMonthZero(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; var CFData: Record "KINTO Cash Flow Data"; InflationFactor: Decimal; MaintInflationFactor: Decimal)
    begin
        // Purchase Price (negative)
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'PURCHASE_PRICE',
            'Purchase Price (incl. Equipment)', "KINTO CF Component Type"::Cost,
            -QuoteItem."Purchase Price", 0, InflationFactor);

        // Vehicle Registration
        if QuoteItem."Vehicle Registration Cost" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'VEH_REGISTRATION',
                'Vehicle Registration', "KINTO CF Component Type"::Cost,
                -QuoteItem."Vehicle Registration Cost", 0, InflationFactor);

        // Body Insurance
        if QuoteItem."Body Insurance" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'BODY_INSURANCE',
                'Body Insurance', "KINTO CF Component Type"::Cost,
                -QuoteItem."Body Insurance", 0, InflationFactor);

        // DLR Commission (One-Shot for BR)
        if QuoteItem."DLR Commission Amount" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'DLR_COMMISSION',
                'DLR Commission (Retainer)', "KINTO CF Component Type"::Commission,
                -QuoteItem."DLR Commission Amount", 0, InflationFactor);

        // KINTO Share Coupon
        if QuoteItem."KINTO Share Coupon" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, 0, Today, 'KINTO_SHARE',
                'KINTO Share Coupon', "KINTO CF Component Type"::Revenue,
                -QuoteItem."KINTO Share Coupon", 0, InflationFactor);
    end;

    local procedure GenerateMonthlyEntries(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; var CFData: Record "KINTO Cash Flow Data"; MonthNo: Integer; MonthDate: Date; AccumulatedMileage: Decimal; InflationFactor: Decimal; MaintInflationFactor: Decimal)
    var
        MonthlyTariff: Decimal;
        CountrySetup: Record "KINTO Country Setup";
    begin
        // Monthly Tariff (Revenue)
        MonthlyTariff := QuoteItem."Monthly Tariff" * InflationFactor;
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'MONTHLY_TARIFF',
            'Monthly Tariff', "KINTO CF Component Type"::Revenue,
            MonthlyTariff, AccumulatedMileage, InflationFactor);

        // PIS/COFINS on Tariff (Cost)
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'PIS_COFINS_TARIFF',
            'PIS/COFINS on Tariff', "KINTO CF Component Type"::Tax,
            -(MonthlyTariff * QuoteItem."PIS COFINS Tariff %" / 100), AccumulatedMileage, InflationFactor);


        // PIS/COFINS Credit on Depreciation (Revenue)
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'PIS_COFINS_CREDIT',
            'PIS/COFINS Credit on Depreciation', "KINTO CF Component Type"::Tax,
            (QuoteItem."Purchase Price" / QuoteItem."Tax Depreciation Period") * QuoteItem."PIS COFINS Credit %" / 100,
            AccumulatedMileage, InflationFactor);

        // Tax Depreciation (Cost)
        if MonthNo <= QuoteItem."Tax Depreciation Period" then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'TAX_DEPRECIATION',
                'Tax Depreciation', "KINTO CF Component Type"::Depreciation,
                -(QuoteItem."Purchase Price" / QuoteItem."Tax Depreciation Period"),
                AccumulatedMileage, InflationFactor);

        // Maintenance Cost (Mileage-Triggered)
        GenerateMaintenanceEntries(QuoteHeader, QuoteItem, CFData, MonthNo, MonthDate,
                                   AccumulatedMileage, MaintInflationFactor);

        // Tire Expense (Mileage-Triggered)
        GenerateTireEntries(QuoteHeader, QuoteItem, CFData, MonthNo, MonthDate,
                           AccumulatedMileage, MaintInflationFactor);

        // IPVA (Annually)
        if (MonthNo mod 12 = 0) or (MonthNo = 1) then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'IPVA',
                'IPVA', "KINTO CF Component Type"::Tax,
                -(QuoteItem."Purchase Price" * QuoteItem."IPVA Rate %" / 100),
                AccumulatedMileage, InflationFactor);

        // DPVAT + Licensing
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'DPVAT_LICENSING',
            'DPVAT + Licensing', "KINTO CF Component Type"::Tax,
            -(QuoteItem."DPVAT Licensing" / 12), AccumulatedMileage, InflationFactor);

        // Telematics
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'TELEMATICS',
            'Telematics', "KINTO CF Component Type"::Cost,
            -(QuoteItem."Telematics Monthly" * InflationFactor), AccumulatedMileage, InflationFactor);

        // Traffic Fine System Fee
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'TRAFFIC_FINE_FEE',
            'Traffic Fine System Fee', "KINTO CF Component Type"::Cost,
            -(QuoteItem."Traffic Fine Fee Monthly" * InflationFactor), AccumulatedMileage, InflationFactor);

        // SGA
        if QuoteItem."SGA Amount" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'SGA',
                'SG&A', "KINTO CF Component Type"::Cost,
                -(QuoteItem."SGA Amount" * InflationFactor), AccumulatedMileage, InflationFactor);

        // Interest Expense
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'INTEREST_EXPENSE',
            'Interest Expense', "KINTO CF Component Type"::Cost,
            -(QuoteItem."Purchase Price" * QuoteItem."Interest Rate %" / 100 / 12),
            AccumulatedMileage, InflationFactor);

        // Idleness
        if QuoteItem."Idleness Rate %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'IDLENESS',
                'Idleness Cost', "KINTO CF Component Type"::Cost,
                -(MonthlyTariff * QuoteItem."Idleness Rate %" / 100),
                AccumulatedMileage, InflationFactor);

        // Credit Risk
        if QuoteItem."Credit Risk %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'CREDIT_RISK',
                'Credit Risk', "KINTO CF Component Type"::Cost,
                -(MonthlyTariff * QuoteItem."Credit Risk %" / 100),
                AccumulatedMileage, InflationFactor);

        // DLR Commission (Monthly for AR)
        if CountrySetup.Get(QuoteHeader."Country Code") then
            if CountrySetup."DLR Commission Model" = CountrySetup."DLR Commission Model"::Monthly then
                InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'DLR_COMMISSION_MONTHLY',
                    'DLR Commission (Monthly)', "KINTO CF Component Type"::Commission,
                    -(MonthlyTariff * QuoteItem."DLR Sales Commission %" / 100),
                    AccumulatedMileage, InflationFactor);

        // Roadside Assistance
        GenerateRoadsideAssistance(QuoteHeader, QuoteItem, CFData, MonthNo, MonthDate, InflationFactor);

        // Spare Car
        if QuoteItem."Spare Car Expense" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'SPARE_CAR',
                'Spare Car Expense', "KINTO CF Component Type"::Cost,
                -(QuoteItem."Spare Car Expense" / 12 * InflationFactor),
                AccumulatedMileage, InflationFactor);
    end;

    local procedure GenerateMaintenanceEntries(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; var CFData: Record "KINTO Cash Flow Data"; MonthNo: Integer; MonthDate: Date; AccumulatedMileage: Decimal; MaintInflationFactor: Decimal)
    var
        MaintPlanLine: Record "KINTO Maintenance Plan Line";
    begin
        if QuoteItem."Maintenance Plan ID" = '' then exit;

        MaintPlanLine.SetRange("Plan ID", QuoteItem."Maintenance Plan ID");
        MaintPlanLine.SetFilter("KM Interval", '<=%1', AccumulatedMileage);
        if MaintPlanLine.FindLast() then begin
            // Check if this mileage interval was already triggered
            CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
            CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
            CFData.SetRange("Component ID", 'MAINTENANCE_' + Format(MaintPlanLine."KM Interval"));
            if not CFData.FindFirst() then
                InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate,
                    'MAINTENANCE_' + Format(MaintPlanLine."KM Interval"),
                    'Maintenance Cost ' + Format(MaintPlanLine."KM Interval") + 'km',
                    "KINTO CF Component Type"::Cost,
                    -(MaintPlanLine."Discounted Cost" * MaintInflationFactor),
                    AccumulatedMileage, MaintInflationFactor);
        end;
    end;

    local procedure GenerateTireEntries(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; var CFData: Record "KINTO Cash Flow Data"; MonthNo: Integer; MonthDate: Date; AccumulatedMileage: Decimal; MaintInflationFactor: Decimal)
    var
        TireChangeNo: Integer;
    begin
        if QuoteItem."Tire Expense" = 0 then exit;
        if QuoteItem."Tire Change Timing (km)" = 0 then exit;

        TireChangeNo := Round(AccumulatedMileage / QuoteItem."Tire Change Timing (km)", 1, '>');
        if TireChangeNo > 0 then begin
            CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
            CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
            CFData.SetRange("Component ID", 'TIRE_CHANGE_' + Format(TireChangeNo));
            if not CFData.FindFirst() then
                InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate,
                    'TIRE_CHANGE_' + Format(TireChangeNo),
                    'Tire Expense (Change ' + Format(TireChangeNo) + ')',
                    "KINTO CF Component Type"::Cost,
                    -(QuoteItem."Tire Expense" * MaintInflationFactor),
                    AccumulatedMileage, MaintInflationFactor);
        end;
    end;

    local procedure GenerateRoadsideAssistance(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; var CFData: Record "KINTO Cash Flow Data"; MonthNo: Integer; MonthDate: Date; InflationFactor: Decimal)
    var
        Amount: Decimal;
    begin
        case true of
            MonthNo <= 12:
                Amount := QuoteItem."Roadside Assistance Y1";
            MonthNo <= 24:
                Amount := QuoteItem."Roadside Assistance Y2";
            MonthNo <= 36:
                Amount := QuoteItem."Roadside Assistance Y3";
            else
                Amount := 0;
        end;

        if Amount > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, MonthNo, MonthDate, 'ROADSIDE_Y' + Format(Ceil(MonthNo / 12)),
                'Road Side Assistance (Year ' + Format(Ceil(MonthNo / 12)) + ')',
                "KINTO CF Component Type"::Cost,
                -(Amount * InflationFactor), 0, InflationFactor);
    end;

    local procedure GenerateEndOfContract(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; var CFData: Record "KINTO Cash Flow Data"; TotalMonths: Integer)
    var
        EndDate: Date;
    begin
        EndDate := CalcDate('+' + Format(TotalMonths) + 'M', Today);

        // Final Resale Price (Revenue)
        InsertCFEntry(CFData, QuoteHeader, QuoteItem, TotalMonths, EndDate, 'RESALE_PRICE',
            'Final Resale Price', "KINTO CF Component Type"::Resale,
            QuoteItem."Final Resale Price", 0, 1);

        // Resale Cost (Cost)
        if QuoteItem."Resale Cost %" > 0 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, TotalMonths, EndDate, 'RESALE_COST',
                'Resale Cost', "KINTO CF Component Type"::Cost,
                -(QuoteItem."Final Resale Price" * QuoteItem."Resale Cost %"),
                0, 1);

        // Payment Allowance End (Adjustment)
        if QuoteItem."Payment Allowance (days)" > 30 then
            InsertCFEntry(CFData, QuoteHeader, QuoteItem, TotalMonths, EndDate, 'PAYMENT_ALLOWANCE_END',
                'Payment Allowance Adjustment - End', "KINTO CF Component Type"::Adjustment,
                QuoteItem."Monthly Tariff" * (QuoteItem."Payment Allowance (days)" / 30 - 1),
                0, 1);
    end;

    local procedure ApplyInflation(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; MonthNo: Integer; var InflationFactor: Decimal; var MaintInflationFactor: Decimal)
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if not CountrySetup.Get(QuoteHeader."Country Code") then exit;

        case CountrySetup."Inflation Adj. Frequency" of
            CountrySetup."Inflation Adj. Frequency"::Monthly:
                begin
                    InflationFactor *= (1 + QuoteItem."Annual Inflation %" / 100 / 12);
                    MaintInflationFactor *= (1 + QuoteItem."Maintenance Inflation %" / 100 / 12);
                end;
            CountrySetup."Inflation Adj. Frequency"::Quarterly:
                if MonthNo mod 3 = 0 then begin
                    InflationFactor *= (1 + QuoteItem."Annual Inflation %" / 100 / 4);
                    MaintInflationFactor *= (1 + QuoteItem."Maintenance Inflation %" / 100 / 4);
                end;
            CountrySetup."Inflation Adj. Frequency"::Annually:
                if MonthNo mod 12 = 0 then begin
                    InflationFactor *= (1 + QuoteItem."Annual Inflation %" / 100);
                    MaintInflationFactor *= (1 + QuoteItem."Maintenance Inflation %" / 100);
                end;
        end;
    end;

    local procedure InsertCFEntry(var CFData: Record "KINTO Cash Flow Data"; var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"; MonthNo: Integer; MonthDate: Date; ComponentID: Code[30]; Description: Text[100]; ComponentType: Enum "KINTO CF Component Type"; Amount: Decimal; AccumulatedMileage: Decimal; InflationFactor: Decimal)
    begin
        CFData.Init();
        CFData."Quote No." := QuoteHeader."Quote No.";
        CFData."Quote Line No." := QuoteItem."Line No.";
        CFData."Month No." := MonthNo;
        CFData."Month Date" := MonthDate;
        CFData."Component ID" := ComponentID;
        CFData."Component Description" := Description;
        CFData."Component Type" := ComponentType;
        CFData."Amount" := Abs(Amount);
        CFData."Signed Amount" := Amount;
        CFData."Accumulated Mileage" := AccumulatedMileage;
        CFData."Inflation Factor" := InflationFactor;
        CFData.Insert(true);
    end;

    procedure CalculateIRR(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        CFData: Record "KINTO Cash Flow Data";
        CashFlows: array[12] of Decimal;
        MonthNo: Integer;
        MaxMonths: Integer;
    begin
        // Build cash flow array for IRR calculation
        MaxMonths := QuoteItem."Contract Term (Months)" + QuoteItem."Extended Analysis Months";

        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetCurrentKey("Quote No.", "Quote Line No.", "Month No.");

        // Aggregate by month
        for MonthNo := 0 to MaxMonths do begin
            CFData.SetRange("Month No.", MonthNo);
            CFData.CalcSums("Signed Amount");
            // Store in array (simplified — in production use temporary table or List)
        end;

        // Newton-Raphson IRR (simplified implementation)
        exit(CalculateIRRBisection(QuoteHeader, QuoteItem));
    end;

    local procedure CalculateIRRBisection(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        CFData: Record "KINTO Cash Flow Data";
        LowerRate: Decimal;
        UpperRate: Decimal;
        MidRate: Decimal;
        NPV: Decimal;
        Tolerance: Decimal;
        MaxIterations: Integer;
        Iteration: Integer;
        MonthNo: Integer;
        MaxMonths: Integer;
    begin
        LowerRate := -0.99;
        UpperRate := 10.0;
        Tolerance := 0.0001;
        MaxIterations := 200;
        MaxMonths := QuoteItem."Contract Term (Months)" + QuoteItem."Extended Analysis Months";

        for Iteration := 1 to MaxIterations do begin
            MidRate := (LowerRate + UpperRate) / 2;
            NPV := 0;

            CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
            CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
            for MonthNo := 0 to MaxMonths do begin
                CFData.SetRange("Month No.", MonthNo);
                CFData.CalcSums("Signed Amount");
                if CFData."Signed Amount" <> 0 then
                    NPV += CFData."Signed Amount" / Power(1 + MidRate, MonthNo);
            end;

            if Abs(NPV) < Tolerance then
                exit(MidRate);

            if NPV > 0 then
                LowerRate := MidRate
            else
                UpperRate := MidRate;
        end;

        exit(MidRate);
    end;

    procedure CalculateROI(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        CFData: Record "KINTO Cash Flow Data";
        TotalRevenue: Decimal;
        TotalCost: Decimal;
    begin
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");

        CFData.SetRange("Component Type", CFData."Component Type"::Revenue);
        CFData.CalcSums("Signed Amount");
        TotalRevenue := CFData."Signed Amount";

        CFData.SetRange("Component Type");
        CFData.SetFilter("Component Type", '<>%1', CFData."Component Type"::Revenue);
        CFData.CalcSums("Signed Amount");
        TotalCost := Abs(CFData."Signed Amount");

        if TotalCost = 0 then exit(0);
        exit((TotalRevenue - TotalCost) / TotalCost);
    end;

    procedure CalculateEBT(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        CFData: Record "KINTO Cash Flow Data";
        TotalSigned: Decimal;
    begin
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.CalcSums("Signed Amount");
        TotalSigned := CFData."Signed Amount";

        // EBT = Total Cash Flow - Interest Expense - Depreciation (simplified)
        CFData.SetRange("Component ID", 'INTEREST_EXPENSE');
        CFData.CalcSums("Signed Amount");
        exit(TotalSigned - CFData."Signed Amount");
    end;

    procedure CalculateFCF(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        CFData: Record "KINTO Cash Flow Data";
    begin
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.CalcSums("Signed Amount");
        exit(CFData."Signed Amount");
    end;

    procedure CalculateTotalCosts(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        CFData: Record "KINTO Cash Flow Data";
    begin
        CFData.SetRange("Quote No.", QuoteHeader."Quote No.");
        CFData.SetRange("Quote Line No.", QuoteItem."Line No.");
        CFData.SetFilter("Component Type", '<>%1', CFData."Component Type"::Revenue);
        CFData.CalcSums("Signed Amount");
        exit(Abs(CFData."Signed Amount"));
    end;

    local procedure Ceil(Value: Decimal): Integer
    begin
        exit(Round(Value, 1, '>'));
    end;

    local procedure Power(Base: Decimal; Exponent: Integer): Decimal
    var
        Result: Decimal;
        i: Integer;
    begin
        Result := 1;
        for i := 1 to Exponent do
            Result *= Base;
        exit(Result);
    end;
}