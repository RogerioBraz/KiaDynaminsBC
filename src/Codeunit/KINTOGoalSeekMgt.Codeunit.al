codeunit 50103 "KINTO Goal Seek Mgt."
{

    var
        CFCalc: Codeunit "KINTO Cash Flow Calculator";
        Tolerance: Decimal;
        MaxIterations: Integer;

    procedure CalculateMonthlyFeeByROI(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        LowerBound: Decimal;
        UpperBound: Decimal;
        CurrentFee: Decimal;
        CalculatedROI: Decimal;
        TargetROI: Decimal;
        Iteration: Integer;
        Converged: Boolean;
    begin
        Tolerance := 0.0001;
        MaxIterations := 100;
        TargetROI := QuoteItem."Target ROI %" / 100;

        // Initial bounds
        LowerBound := 0.01;
        UpperBound := QuoteItem."Purchase Price" * 0.05; // 5% of purchase price as upper bound

        // Validate monotonicity assumption
        Converged := false;
        Iteration := 0;

        while (Iteration < MaxIterations) and not Converged do begin
            CurrentFee := (LowerBound + UpperBound) / 2;

            // Set the fee and recalculate
            QuoteItem."Monthly Tariff" := CurrentFee;

            // Regenerate cash flow with this fee
            CFCalc.GenerateCashFlow(QuoteHeader, QuoteItem);

            // Calculate ROI
            CalculatedROI := CFCalc.CalculateROI(QuoteHeader, QuoteItem);

            if Abs(CalculatedROI - TargetROI) < Tolerance then
                Converged := true
            else if CalculatedROI < TargetROI then
                LowerBound := CurrentFee
            else
                UpperBound := CurrentFee;

            Iteration += 1;
        end;

        if not Converged then
            // Use best approximation
            QuoteItem."Monthly Tariff" := CurrentFee;

        QuoteItem."Calculated ROI" := CalculatedROI;
    end;
}