codeunit 50100 "KINTO Pricing Engine Mgt."
{
    // CORREÇÃO: Removido Caption — codeunits não suportam esta propriedade no AL atual
    Permissions = tabledata "KINTO Quote Header" = RIMD,
                  tabledata "KINTO Quote Item" = RIMD,
                  tabledata "KINTO Cash Flow Header" = RIMD,
                  tabledata "KINTO Cash Flow Data" = RIMD,
                  tabledata "KINTO Simulation Snapshot" = RIMD;

    var
        CountrySetup: Record "KINTO Country Setup";
        CFCalc: Codeunit "KINTO Cash Flow Calculator";
        GoalSeekMgt: Codeunit "KINTO Goal Seek Mgt.";
        PricingErr: Label 'Pricing Engine is stopped for country %1. Contact administrator.';
        NoCountryErr: Label 'Country Setup not found for country %1.';
        NoItemErr: Label 'Item No. is required on Quote Item Line %1.';
        NoMSRPErr: Label 'MSRP must be greater than 0 on Quote Item Line %1.';
        NoTermErr: Label 'Contract Term must be greater than 0 on Quote Item Line %1.';

    procedure RunPricing(var QuoteHeader: Record "KINTO Quote Header")
    var
        QuoteItem: Record "KINTO Quote Item";
    begin
        if not CountrySetup.Get(QuoteHeader."Country Code") then
            Error(NoCountryErr, QuoteHeader."Country Code");

        if CountrySetup."Emergency Stop" then
            Error(PricingErr, QuoteHeader."Country Code");

        QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::Draft;
        QuoteHeader.Modify(true);

        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        if QuoteItem.FindSet() then
            repeat
                ProcessQuoteItem(QuoteHeader, QuoteItem);
            until QuoteItem.Next() = 0;

        AggregateQuoteResults(QuoteHeader);
        ClassifyPreApproval(QuoteHeader);

        QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::Calculated;
        QuoteHeader.Modify(true);
    end;

    local procedure ProcessQuoteItem(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        PackagePricing: Codeunit "KINTO Package Pricing Calc";
        TotalPkgMonthlyCost: Decimal;
        InsuranceFromPackage: Decimal;
        VehicleValue: Decimal;
    begin
        Clear(QuoteItem."Error Message");

        // Validações obrigatórias
        if QuoteItem."Item No." = '' then begin
            QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Error;
            QuoteItem."Error Message" := StrSubstNo(NoItemErr, QuoteItem."Line No.");
            QuoteItem.Modify(true);
            exit;
        end;

        if QuoteItem.MSRP <= 0 then begin
            QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Error;
            QuoteItem."Error Message" := StrSubstNo(NoMSRPErr, QuoteItem."Line No.");
            QuoteItem.Modify(true);
            exit;
        end;

        if QuoteItem."Contract Term (Months)" <= 0 then begin
            QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Error;
            QuoteItem."Error Message" := StrSubstNo(NoTermErr, QuoteItem."Line No.");
            QuoteItem.Modify(true);
            exit;
        end;

        LoadCountryParameters(QuoteHeader, QuoteItem);
        QuoteItem."Purchase Price" := QuoteItem.CalculatePurchasePrice();
        QuoteItem."Final Resale Price" := QuoteItem.CalculateFinalResalePrice();
        QuoteItem."Extended Analysis Months" :=
            QuoteHeader.CalcExtendedAnalysisMonths(QuoteItem."Payment Allowance (days)");

        // Pacotes
        TotalPkgMonthlyCost := PackagePricing.CalculateAllPackageCosts(QuoteHeader, QuoteItem);

        // Seguro via Coverage Limits
        if QuoteItem."Insurance Quote No." <> '' then begin
            if QuoteItem."Vehicle Condition" = QuoteItem."Vehicle Condition"::New then
                VehicleValue := QuoteItem."Purchase Price"
            else
                VehicleValue := QuoteItem."Initial Value (Used)";

            InsuranceFromPackage := PackagePricing.CalculateInsuranceFromPackage(QuoteItem, VehicleValue);
            if InsuranceFromPackage > 0 then
                QuoteItem."Body Insurance" := InsuranceFromPackage;
        end;

        // Pricing
        case QuoteHeader."Pricing Methodology" of
            QuoteHeader."Pricing Methodology"::"Target ROI":
                GoalSeekMgt.CalculateMonthlyFeeByROI(QuoteHeader, QuoteItem);
            QuoteHeader."Pricing Methodology"::"KINTO Fee":
                CalculateKINTOFee(QuoteHeader, QuoteItem);
        end;

        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);
        CalculateIndicators(QuoteHeader, QuoteItem);
        CreateSnapshot(QuoteHeader, QuoteItem);

        QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Calculated;
        QuoteItem.Modify(true);
    end;

    // CORREÇÃO: Agora carrega TODOS os campos tributários (National Revenue Tax % → PIS COFINS Tariff %)
    local procedure LoadCountryParameters(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        QuoteItem."Annual Inflation %" := CountrySetup."Default Inflation Index %";
        QuoteItem."Spread" := CountrySetup."Spread";
        QuoteItem."Interest Rate %" := CountrySetup."Annual Interest Expense %";
        QuoteItem."Idleness Rate %" := CountrySetup."Idleness Rate %";
        QuoteItem."Tax Depreciation Period" := CountrySetup."Tax Depreciation Period";
        QuoteItem."Profit Tax Rate %" := CountrySetup."Profit Tax Rate %";

        // Campos tributários agora carregados do Country Setup
        QuoteItem."PIS COFINS Tariff %" := CountrySetup."National Revenue Tax %";
        QuoteItem."IPVA Rate %" := 4;

        LoadCreditRiskFactor(QuoteHeader, QuoteItem);
    end;

    local procedure LoadCreditRiskFactor(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        if QuoteHeader."Credit Risk Factor %" <> 0 then begin
            QuoteItem."Credit Risk %" := QuoteHeader."Credit Risk Factor %";
            exit;
        end;

        case QuoteHeader."Credit Score" of
            'A':
                QuoteItem."Credit Risk %" := CountrySetup."Credit Risk A %";
            'B':
                QuoteItem."Credit Risk %" := CountrySetup."Credit Risk B %";
            'C':
                QuoteItem."Credit Risk %" := CountrySetup."Credit Risk C %";
            'D':
                QuoteItem."Credit Risk %" := CountrySetup."Credit Risk D %";
            'E':
                QuoteItem."Credit Risk %" := CountrySetup."Credit Risk E %";
            'F':
                QuoteItem."Credit Risk %" := CountrySetup."Credit Risk F %";
            else
                QuoteItem."Credit Risk %" := CountrySetup."Default Credit Risk %";
        end;
    end;

    local procedure CalculateKINTOFee(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        PackagePricing: Codeunit "KINTO Package Pricing Calc";
        TotalCosts: Decimal;
        TargetMargin: Decimal;
        PkgCosts: Decimal;
    begin
        TotalCosts := CFCalc.CalculateTotalCosts(QuoteHeader, QuoteItem);
        PkgCosts := PackagePricing.CalculateAllPackageCosts(QuoteHeader, QuoteItem);
        TotalCosts += PkgCosts * QuoteItem."Contract Term (Months)";

        TargetMargin := QuoteItem."Purchase Price" * CountrySetup."Net Contribution Margin %" / 100;
        QuoteItem."Monthly Tariff" := Round((TotalCosts + TargetMargin) / QuoteItem."Contract Term (Months)", 0.01);
    end;

    local procedure CalculateIndicators(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        QuoteItem."KINTO IRR" := CFCalc.CalculateIRR(QuoteHeader, QuoteItem);
        QuoteItem."Reference IRR" := CountrySetup."Annual Interest Expense %" / 100;
        QuoteItem."Calculated ROI" := CFCalc.CalculateROI(QuoteHeader, QuoteItem);
        QuoteItem.EBT := CFCalc.CalculateEBT(QuoteHeader, QuoteItem);
        QuoteItem.PAT := QuoteItem.EBT * (1 - QuoteItem."Profit Tax Rate %" / 100);
        QuoteItem."KINTO FCF" := CFCalc.CalculateFCF(QuoteHeader, QuoteItem);
    end;

    local procedure AggregateQuoteResults(var QuoteHeader: Record "KINTO Quote Header")
    var
        QuoteItem: Record "KINTO Quote Item";
    begin
        QuoteHeader."Total MSRP" := 0;
        QuoteHeader."Total Purchase Price" := 0;
        QuoteHeader."Total Monthly Fee" := 0;
        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        if QuoteItem.FindSet() then
            repeat
                QuoteHeader."Total MSRP" += QuoteItem.MSRP;
                QuoteHeader."Total Purchase Price" += QuoteItem."Purchase Price";
                QuoteHeader."Total Monthly Fee" += QuoteItem."Monthly Tariff";
            until QuoteItem.Next() = 0;
    end;

    // CORREÇÃO: Validações de Header fora do loop
    local procedure ClassifyPreApproval(var QuoteHeader: Record "KINTO Quote Header")
    var
        QuoteItem: Record "KINTO Quote Item";
        IsNonStandard: Boolean;
    begin
        IsNonStandard := false;

        if QuoteHeader."Negotiation Buffer %" > CountrySetup."Suggested Negot. Buffer %" then
            IsNonStandard := true;
        if QuoteHeader."Credit Score" in ['D', 'E', 'F'] then
            IsNonStandard := true;

        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        if QuoteItem.FindSet() then
            repeat
                if QuoteItem."Calculated ROI" < QuoteItem."Reference IRR" then
                    IsNonStandard := true;
                if QuoteItem."Payment Allowance (days)" > 30 then
                    IsNonStandard := true;
            until QuoteItem.Next() = 0;

        if IsNonStandard then
            QuoteHeader."Approval Classification" := QuoteHeader."Approval Classification"::"Non-Standard"
        else
            QuoteHeader."Approval Classification" := QuoteHeader."Approval Classification"::Standard;
    end;

    // CORREÇÃO: Entry No. é AutoIncrement — NÃO atribuir manualmente
    // Snapshot ID garante unicidade com timestamp + Line No.
    local procedure CreateSnapshot(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        Snapshot: Record "KINTO Simulation Snapshot";
    begin
        Snapshot.Init();
        // Entry No. = AutoIncrement — deixar o BC gerar
        Snapshot."Snapshot ID" :=
            Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>') +
            '-' + Format(QuoteItem."Line No.");
        Snapshot."Quote No." := QuoteHeader."Quote No.";
        Snapshot."Quote Line No." := QuoteItem."Line No.";
        Snapshot."Monthly Fee" := QuoteItem."Monthly Tariff";
        Snapshot."IRR" := QuoteItem."KINTO IRR";
        Snapshot."Calculated ROI" := QuoteItem."Calculated ROI";
        Snapshot.Insert(true);

        QuoteHeader."Snapshot ID" := Snapshot."Snapshot ID";
    end;
}