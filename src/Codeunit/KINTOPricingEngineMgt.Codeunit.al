codeunit 50100 "KINTO Pricing Engine Mgt."
{

    Permissions = tabledata "KINTO Quote Header" = RIMD,
                  tabledata "KINTO Quote Item" = RIMD,
                  tabledata "KINTO Cash Flow Header" = RIMD,
                  tabledata "KINTO Cash Flow Data" = RIMD,
                  tabledata "KINTO Simulation Snapshot" = RIMD;

    var
        CountrySetup: Record "KINTO Country Setup";
        RVLookupMgt: Codeunit "KINTO RV Lookup Mgt.";
        CFCalc: Codeunit "KINTO Cash Flow Calculator";
        GoalSeekMgt: Codeunit "KINTO Goal Seek Mgt.";
        TaxCalc: Codeunit "KINTO Tax Calculator";
        CommCalc: Codeunit "KINTO Commission Calculator";
        DeprecCalc: Codeunit "KINTO Depreciation Calc.";
        BookingMgt: Codeunit "KINTO Booking Value Mgt.";
        ErrorMsg: Text[250];
        PricingErr: Label 'Pricing Engine is stopped for country %1. Contact administrator.';
        NoCountryErr: Label 'Country Setup not found for country %1.';
        NoItemErr: Label 'Item %1 not found.';

    procedure RunPricing(var QuoteHeader: Record "KINTO Quote Header")
    var
        QuoteItem: Record "KINTO Quote Item";
    begin
        // Validate emergency stop
        if not CountrySetup.Get(QuoteHeader."Country Code") then
            Error(NoCountryErr, QuoteHeader."Country Code");

        if CountrySetup."Emergency Stop" then
            Error(PricingErr, QuoteHeader."Country Code");

        QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::Draft;
        QuoteHeader.Modify(true);

        // Process each quote item
        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        if QuoteItem.FindSet() then
            repeat
                ProcessQuoteItem(QuoteHeader, QuoteItem);
            until QuoteItem.Next() = 0;

        // Aggregate results
        AggregateQuoteResults(QuoteHeader);

        // Pre-approval classification
        ClassifyPreApproval(QuoteHeader);

        QuoteHeader."Pricing Status" := QuoteHeader."Pricing Status"::Calculated;
        QuoteHeader.Modify(true);
    end;

    local procedure ProcessQuoteItem(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        Clear(QuoteItem."Error Message");

        // Step 1: Load parameters from Country Setup
        LoadCountryParameters(QuoteHeader, QuoteItem);

        // Step 2: Calculate Purchase Price
        QuoteItem."Purchase Price" := QuoteItem.CalculatePurchasePrice();

        // Step 3: RV Lookup
        QuoteItem."Projected Residual Value" := RVLookupMgt.LookupResidualValue(QuoteItem);

        // Step 4: Calculate Final Resale Price
        QuoteItem."Final Resale Price" := QuoteItem.CalculateFinalResalePrice();

        // Step 5: Calculate Depreciation
        DeprecCalc.CalculateDepreciation(QuoteItem);

        // Step 6: Calculate Commissions
        CommCalc.CalculateCommissions(QuoteHeader, QuoteItem);

        // Step 7: Calculate Taxes
        TaxCalc.CalculateTaxes(QuoteHeader, QuoteItem);

        // Step 8: Extended Analysis Months
        QuoteItem."Extended Analysis Months" := QuoteHeader.CalcExtendedAnalysisMonths(QuoteItem."Payment Allowance (days)");

        // Step 9: Pricing based on methodology
        case QuoteHeader."Pricing Methodology" of
            QuoteHeader."Pricing Methodology"::"Target ROI":
                GoalSeekMgt.CalculateMonthlyFeeByROI(QuoteHeader, QuoteItem);
            QuoteHeader."Pricing Methodology"::"KINTO Fee":
                CalculateKINTOFee(QuoteHeader, QuoteItem);
        end;

        // Step 10: Create Cash Flow
        CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

        // Step 11: Calculate Final Indicators
        CalculateIndicators(QuoteHeader, QuoteItem);

        // Step 12: Create Snapshot
        CreateSnapshot(QuoteHeader, QuoteItem);

        QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Calculated;
        QuoteItem.Modify(true);
    end;

    local procedure LoadCountryParameters(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        QuoteItem."Annual Inflation %" := CountrySetup."Default Inflation Index %";
        QuoteItem."Spread" := CountrySetup."Spread";
        QuoteItem."Interest Rate %" := CountrySetup."Annual Interest Expense %";
        QuoteItem."Idleness Rate %" := CountrySetup."Idleness Rate %";
        QuoteItem."Tax Depreciation Period" := CountrySetup."Tax Depreciation Period";
        QuoteItem."PIS COFINS Tariff %" := 9.25; // BR standard
        QuoteItem."PIS COFINS Credit %" := 9.25;
        QuoteItem."Profit Tax Rate %" := CountrySetup."Profit Tax Rate %";
        QuoteItem."Resale Cost %" := 0.03; // 3% default

        // Credit Risk Factor
        LoadCreditRiskFactor(QuoteHeader, QuoteItem);
    end;

    local procedure LoadCreditRiskFactor(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        // Precedence: Customer-level → Credit Score → Country default
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
        TotalCosts: Decimal;
        TargetMargin: Decimal;
    begin
        // KINTO Fee-Based: Monthly Fee = (Total Costs + Target Margin) / Contract Term
        TotalCosts := CFCalc.CalculateTotalCosts(QuoteHeader, QuoteItem);
        TargetMargin := QuoteItem."Purchase Price" * CountrySetup."Net Contribution Margin %" / 100;
        QuoteItem."Monthly Tariff" := Round((TotalCosts + TargetMargin) / QuoteItem."Contract Term (Months)", 0.01);
    end;

    local procedure CalculateIndicators(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    begin
        // IRR calculated from Cash Flow
        QuoteItem."KINTO IRR" := CFCalc.CalculateIRR(QuoteHeader, QuoteItem);

        // Reference IRR from Country Setup
        QuoteItem."Reference IRR" := CountrySetup."Annual Interest Expense %" / 100;

        // ROI
        QuoteItem."Calculated ROI" := CFCalc.CalculateROI(QuoteHeader, QuoteItem);

        // EBT and PAT
        QuoteItem.EBT := CFCalc.CalculateEBT(QuoteHeader, QuoteItem);
        QuoteItem.PAT := QuoteItem.EBT * (1 - QuoteItem."Profit Tax Rate %" / 100);

        // KINTO FCF
        QuoteItem."KINTO FCF" := CFCalc.CalculateFCF(QuoteHeader, QuoteItem);
    end;

    local procedure AggregateQuoteResults(var QuoteHeader: Record "KINTO Quote Header")
    var
        QuoteItem: Record "KINTO Quote Item";
    begin
        QuoteHeader."Total MSRP" := 0;
        QuoteHeader."Total Purchase Price" := 0;
        QuoteHeader."Total Monthly Fee" := 0;
        QuoteHeader."KINTO IRR" := 0;
        QuoteHeader."Calculated ROI" := 0;
        QuoteHeader.EBT := 0;
        QuoteHeader.PAT := 0;
        QuoteHeader."KINTO FCF" := 0;

        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        if QuoteItem.FindSet() then
            repeat
                QuoteHeader."Total MSRP" += QuoteItem.MSRP;
                QuoteHeader."Total Purchase Price" += QuoteItem."Purchase Price";
                QuoteHeader."Total Monthly Fee" += QuoteItem."Monthly Tariff";
                QuoteHeader."KINTO IRR" += QuoteItem."KINTO IRR";
                QuoteHeader."Calculated ROI" += QuoteItem."Calculated ROI";
                QuoteHeader.EBT += QuoteItem.EBT;
                QuoteHeader.PAT += QuoteItem.PAT;
                QuoteHeader."KINTO FCF" += QuoteItem."KINTO FCF";
            until QuoteItem.Next() = 0;

        // Average IRR/ROI if multiple items
        if QuoteItem.Count > 0 then begin
            QuoteHeader."KINTO IRR" := QuoteHeader."KINTO IRR" / QuoteItem.Count;
            QuoteHeader."Calculated ROI" := QuoteHeader."Calculated ROI" / QuoteItem.Count;
        end;
    end;

    local procedure ClassifyPreApproval(var QuoteHeader: Record "KINTO Quote Header")
    var
        QuoteItem: Record "KINTO Quote Item";
        IsNonStandard: Boolean;
    begin
        IsNonStandard := false;

        QuoteItem.SetRange("Quote No.", QuoteHeader."Quote No.");
        if QuoteItem.FindSet() then
            repeat
                // Check criteria
                if QuoteItem."Calculated ROI" < QuoteItem."Reference IRR" then
                    IsNonStandard := true;
                if QuoteHeader."Negotiation Buffer %" > CountrySetup."Suggested Negot. Buffer %" then
                    IsNonStandard := true;
                if QuoteHeader."Credit Score" in ['D', 'E', 'F'] then
                    IsNonStandard := true;
                if QuoteItem."Payment Allowance (days)" > 30 then
                    IsNonStandard := true;
                if QuoteItem."Contingency Amount" > 0 then
                    IsNonStandard := true;
                if QuoteItem."Vehicle Condition" = QuoteItem."Vehicle Condition"::Used then
                    if not CountrySetup."reKinto Pre-Approved" then
                        IsNonStandard := true;
            until QuoteItem.Next() = 0;

        if IsNonStandard then
            QuoteHeader."Approval Classification" := QuoteHeader."Approval Classification"::"Non-Standard"
        else
            QuoteHeader."Approval Classification" := QuoteHeader."Approval Classification"::Standard;
    end;

    local procedure CreateSnapshot(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        Snapshot: Record "KINTO Simulation Snapshot";
        NextID: Integer;
    begin
        NextID := GetNextSnapshotID();
        Snapshot.Init();
        Snapshot."Snapshot ID" := NextID;
        Snapshot."Quote No." := QuoteHeader."Quote No.";
        Snapshot."Quote Line No." := QuoteItem."Line No.";
        Snapshot."Vehicle Model No." := QuoteItem."Vehicle Model No.";
        Snapshot."Vehicle Variant" := QuoteItem."Vehicle Variant";
        Snapshot."Usage Type" := QuoteItem."Usage Type";
        Snapshot."Lead Time" := QuoteItem."Lead Time (days)";
        Snapshot."Contract Term" := QuoteItem."Contract Term (Months)";
        Snapshot."Monthly Mileage" := QuoteItem."Monthly Mileage (km)";
        Snapshot."Payment Allowance" := QuoteItem."Payment Allowance (days)";
        Snapshot."Annual Inflation %" := QuoteItem."Annual Inflation %";
        Snapshot.Spread := QuoteItem.Spread;
        Snapshot."Idleness Rate" := QuoteItem."Idleness Rate %";
        Snapshot."PIS COFINS Tariff %" := QuoteItem."PIS COFINS Tariff %";
        Snapshot."PIS COFINS Credit %" := QuoteItem."PIS COFINS Credit %";
        Snapshot."Tax Depreciation Period" := QuoteItem."Tax Depreciation Period";
        Snapshot."Profit Tax Rate %" := QuoteItem."Profit Tax Rate %";
        Snapshot."Credit Risk Factor" := QuoteItem."Credit Risk %";
        Snapshot."Target ROI" := QuoteItem."Target ROI %";
        Snapshot."Contract Start Month" := QuoteItem."Contract Start Month";
        Snapshot.MSRP := QuoteItem.MSRP;
        Snapshot."Total Equipment Price" := QuoteItem."Total Equipment Price";
        Snapshot."Purchase Price" := QuoteItem."Purchase Price";
        Snapshot."Depreciation Market %" := QuoteItem."Depreciation Market %";
        Snapshot."Final Resale Price" := QuoteItem."Final Resale Price";
        Snapshot.SGA := QuoteItem."SGA Amount";
        Snapshot."Standard Target ROI" := QuoteItem."Standard Target ROI %";
        Snapshot.EBT := QuoteItem.EBT;
        Snapshot.PAT := QuoteItem.PAT;
        Snapshot.IRR := QuoteItem."KINTO IRR";
        Snapshot."Reference IRR" := QuoteItem."Reference IRR";
        Snapshot."Calculated ROI" := QuoteItem."Calculated ROI";
        Snapshot."Monthly Fee" := QuoteItem."Monthly Tariff";
        Snapshot."Negotiated Monthly Price" := QuoteItem."Negotiated Monthly Price";
        Snapshot.Status := QuoteItem."Pricing Status";
        Snapshot."Participates in Pool" := QuoteItem."Participates in Pool";
        Snapshot."Incl. Preventive Maint." := QuoteItem."Incl. Preventive Maint.";
        Snapshot."Incl. Corrective Maint." := QuoteItem."Incl. Corrective Maint.";
        Snapshot."Number of Tires" := QuoteItem."Number of Tires";
        Snapshot."Glass Coverage Type" := QuoteItem."Glass Coverage Type";
        Snapshot.Armoring := QuoteItem."Inclusion of Armoring";
        Snapshot."Adjustment Index" := QuoteItem."Adjustment Index";
        Snapshot."Adjustment Period" := QuoteItem."Adjustment Period";
        Snapshot."Admin Fee" := QuoteItem."Admin Fee";
        Snapshot."Fine Admin Fee" := QuoteItem."Fine Admin Fee Per Event";
        Snapshot."Non-Withdrawal Fee" := QuoteItem."Non-Withdrawal Fee Per Day";
        Snapshot."Advanced Post" := QuoteItem."Advanced Post";
        Snapshot."Deadline Police Rep." := QuoteItem."Deadline Submit Police Rep.";
        Snapshot."Reimbursement Due Date" := QuoteItem."Reimbursement Due Date";
        Snapshot."Delivery Spare Vehicle" := QuoteItem."Delivery Spare Vehicle";
        Snapshot.Insert(true);

        QuoteHeader."Snapshot ID" := Snapshot."Snapshot ID";
    end;

    local procedure GetNextSnapshotID(): Integer
    var
        Snapshot: Record "KINTO Simulation Snapshot";
    begin
        if Snapshot.FindLast() then
            exit(Snapshot."Snapshot ID" + 1)
        else
            exit(1);
    end;
}