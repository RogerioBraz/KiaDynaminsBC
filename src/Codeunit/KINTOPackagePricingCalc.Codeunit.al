codeunit 50114 "KINTO Package Pricing Calc"
{
    procedure CalculateAllPackageCosts(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        TotalMonthlyCost: Decimal;
    begin
        TotalMonthlyCost := 0;

        // Glass Coverage
        TotalMonthlyCost += GetGlassCoverageMonthly(QuoteItem);

        // 24h Assistance
        TotalMonthlyCost += Get24hAssistanceMonthly(QuoteItem);

        // Pick-up and Delivery
        TotalMonthlyCost += GetPickupDeliveryMonthly(QuoteItem);

        // Replacement Vehicle
        TotalMonthlyCost += GetReplacementVehicleMonthly(QuoteItem);

        // Tires
        TotalMonthlyCost += GetTireMonthly(QuoteItem);

        // Services (Telematics, etc.)
        TotalMonthlyCost += GetServiceMonthly(QuoteItem);

        // Maintenance (reestruturado)
        TotalMonthlyCost += GetMaintenanceMonthly(QuoteItem);

        exit(TotalMonthlyCost);
    end;

    procedure GetGlassCoverageMonthly(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        GlassPkg: Record "KINTO Glass Coverage Package";
    begin
        if QuoteItem."Glass Coverage Package ID" = '' then exit(0);
        if not GlassPkg.Get(QuoteItem."Glass Coverage Package ID") then exit(0);
        exit(GlassPkg.GetMonthlyCost(QuoteItem."Contract Term (Months)"));
    end;

    procedure Get24hAssistanceMonthly(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        AssistancePkg: Record "KINTO 24h Assistance Package";
    begin
        if QuoteItem."24h Assistance Package ID" = '' then exit(0);
        if not AssistancePkg.Get(QuoteItem."24h Assistance Package ID") then exit(0);
        exit(AssistancePkg.GetMonthlyCost(QuoteItem."Contract Term (Months)"));
    end;

    procedure GetPickupDeliveryMonthly(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        PickupPkg: Record "KINTO Pickup Delivery Package";
    begin
        if QuoteItem."Pickup Delivery Package ID" = '' then exit(0);
        if not PickupPkg.Get(QuoteItem."Pickup Delivery Package ID") then exit(0);
        exit(PickupPkg.GetMonthlyCost(QuoteItem."Contract Term (Months)"));
    end;

    procedure GetReplacementVehicleMonthly(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        ReplPkg: Record "KINTO Replacement Vehicle Pkg";
        Uses: Integer;
    begin
        if QuoteItem."Replacement Vehicle Pkg ID" = '' then exit(0);
        if not ReplPkg.Get(QuoteItem."Replacement Vehicle Pkg ID") then exit(0);
        Uses := QuoteItem."Replacement Vehicle Uses";
        if Uses = 0 then Uses := ReplPkg."Default Uses";
        exit(ReplPkg.GetMonthlyCost(Uses, QuoteItem."Contract Term (Months)"));
    end;

    procedure GetTireMonthly(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        TirePkg: Record "KINTO Tire Package";
        Qty: Integer;
    begin
        if QuoteItem."Tire Package ID" = '' then exit(0);
        if not TirePkg.Get(QuoteItem."Tire Package ID") then exit(0);
        Qty := QuoteItem."Tire Quantity";
        if Qty = 0 then Qty := TirePkg."Default Quantity";
        if Qty = 0 then Qty := QuoteItem."Number of Tires";
        exit(TirePkg.GetMonthlyCost(Qty, QuoteItem."Contract Term (Months)"));
    end;

    procedure GetServiceMonthly(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        ServicePkg: Record "KINTO Service Package";
    begin
        if QuoteItem."Service Package ID" = '' then exit(0);
        if not ServicePkg.Get(QuoteItem."Service Package ID") then exit(0);
        exit(ServicePkg.GetMonthlyCost());
    end;

    procedure GetMaintenanceMonthly(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        MaintHeader: Record "KINTO Maintenance Plan Header";
        CurrentOdometer: Decimal;
        CurrentAge: Integer;
    begin
        if QuoteItem."Maintenance Plan ID" = '' then exit(0);
        if not MaintHeader.Get(QuoteItem."Maintenance Plan ID") then exit(0);

        // Para veículos usados, usa odômetro atual; para novos, inicia em 0
        if QuoteItem."Vehicle Condition" = QuoteItem."Vehicle Condition"::Used then
            CurrentOdometer := QuoteItem."Initial Value (Used)"
        else
            CurrentOdometer := 0;

        CurrentAge := 0; // Veículos novos começam em 0

        exit(MaintHeader.GetMonthlyMaintenanceCost(
            QuoteItem."Contract Term (Months)",
            QuoteItem."Monthly Mileage (km)" * QuoteItem."Contract Term (Months)",
            CurrentOdometer,
            CurrentAge));
    end;

    procedure CalculateInsuranceFromPackage(QuoteItem: Record "KINTO Quote Item"; VehicleValue: Decimal): Decimal
    var
        InsQuote: Record "KINTO Insurance Quote";
        InsQuoteGroup: Record "KINTO Insurance Quote Group";
        InsCoverageLimit: Record "KINTO Insurance Coverage Limit";
        TotalPremium: Decimal;
        LoadingFactor: Decimal;
        CategoryPremium: Decimal;
    begin
        TotalPremium := 0;

        // 1. Busca a Insurance Quote vinculada ao Quote Item
        if QuoteItem."Insurance Quote No." = '' then exit(0);
        if not InsQuote.Get(QuoteItem."Insurance Quote No.") then exit(0);

        // 2. Busca o Insurance Quote Group vinculado à cotação
        if InsQuote."Quote Group ID" = 0 then exit(0);
        if not InsQuoteGroup.Get(InsQuote."Quote Group ID") then exit(0);

        // 3. CORREÇÃO: Filtra Coverage Limits pelo GROUP ID (não pelo Quote No.)
        InsCoverageLimit.SetRange("Insurance Package ID", InsQuoteGroup."Group ID");
        InsCoverageLimit.SetRange(Active, true);
        if InsCoverageLimit.FindSet() then
            repeat
                CategoryPremium := InsCoverageLimit.CalculatePremium(VehicleValue);
                TotalPremium += CategoryPremium;
            until InsCoverageLimit.Next() = 0;

        // 4. Aplica Insurance Loading (Surcharge) do GROUP
        if InsQuoteGroup."Insurance Loading %" > 0 then begin
            LoadingFactor := 1 + InsQuoteGroup."Insurance Loading %" / 100;
            TotalPremium := TotalPremium * LoadingFactor;
        end;

        exit(Round(TotalPremium, 0.01));
    end;


}