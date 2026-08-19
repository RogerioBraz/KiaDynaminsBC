codeunit 50106 "KINTO Depreciation Calc."
{

    procedure CalculateDepreciation(var QuoteItem: Record "KINTO Quote Item")
    begin
        // Market Depreciation
        if QuoteItem."Depreciation Market %" = 0 then
            QuoteItem."Depreciation Market %" := CalculateMarketDepreciation(QuoteItem);

        // Accounting Depreciation
        if QuoteItem."Depreciation Accounting %" = 0 then
            QuoteItem."Depreciation Accounting %" := CalculateAccountingDepreciation(QuoteItem);

        // Projected Depreciation (for used vehicles)
        if QuoteItem."Vehicle Condition" = QuoteItem."Vehicle Condition"::Used then begin
            QuoteItem."Projected Depreciation" := QuoteItem."Initial Value (Used)" - QuoteItem."Projected Residual Value";
            if QuoteItem."Projected Depreciation" < 0 then
                QuoteItem."Projected Depreciation" := 0; // Floor at zero
            QuoteItem."Monthly Booking Value" := QuoteItem."Projected Depreciation" / QuoteItem."Contract Term (Months)";
        end;
    end;

    local procedure CalculateMarketDepreciation(QuoteItem: Record "KINTO Quote Item"): Decimal
    begin
        // Based on vehicle type and contract term
        // Simplified — in production, lookup from configuration table
        case QuoteItem."Contract Term (Months)" of
            1 .. 12:
                exit(0.08);
            13 .. 24:
                exit(0.12);
            25 .. 36:
                exit(0.18);
            37 .. 48:
                exit(0.25);
            else
                exit(0.30);
        end;
    end;

    local procedure CalculateAccountingDepreciation(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        AnnualDepreciation: Decimal;
    begin
        // Straight-line over tax depreciation period
        AnnualDepreciation := 1 / (QuoteItem."Tax Depreciation Period" / 12);
        exit(AnnualDepreciation * (QuoteItem."Contract Term (Months)" / 12));
    end;
}