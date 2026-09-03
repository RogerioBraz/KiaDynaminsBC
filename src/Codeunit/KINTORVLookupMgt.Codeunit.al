codeunit 50101 "KINTO RV Lookup Mgt."
{
    var
        NoResidualValueErr: Label 'No residual value was found for item %1 and usage type %2. Create an active entry in the KINTO Residual Value Matrix and try again.';
        NoResidualValueRangeErr: Label 'No residual value range matches item %3, projected mileage %1 km, and contract term %2 months. Review the mileage and age ranges in the KINTO Residual Value Matrix.';

    procedure LookupResidualValue(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        RVMatrix: Record "KINTO RV Matrix";
        SelectedRV: Decimal;
    begin
        RVMatrix.SetCurrentKey("Item No.", "Usage Type", "Has Implement", "Effective Start Date", "Max Mileage", "Max Age");
        RVMatrix.SetRange("Item No.", QuoteItem."Item No.");
        RVMatrix.SetRange("Usage Type", QuoteItem."Usage Type");
        RVMatrix.SetRange("Has Implement", false); // Simplified — enhance for implement check
        RVMatrix.SetRange("Status", RVMatrix.Status::Active);
        RVMatrix.SetFilter("Effective Start Date", '<=%1', Today);
        if RVMatrix.FindLast() then begin
            RVMatrix.SetRange("Effective Start Date", RVMatrix."Effective Start Date");
            SelectedRV := SelectByMileageAndAge(RVMatrix, QuoteItem);
            exit(SelectedRV);
        end;

        RVMatrix.Reset();
        RVMatrix.SetCurrentKey("Item No.", "Usage Type", "Has Implement", "Effective Start Date", "Max Mileage", "Max Age");
        RVMatrix.SetRange("Item No.", QuoteItem."Item No.");
        RVMatrix.SetRange("Usage Type", QuoteItem."Usage Type");
        RVMatrix.SetRange("Status", RVMatrix.Status::Active);
        RVMatrix.SetFilter("Effective Start Date", '<=%1', Today);
        RVMatrix.SetRange("MSRP Record", true);
        if RVMatrix.FindLast() then
            exit(RVMatrix."Residual Value %");

        Error(NoResidualValueErr, QuoteItem."Item No.", QuoteItem."Usage Type");
    end;

    local procedure SelectByMileageAndAge(var RVMatrix: Record "KINTO RV Matrix"; QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        ProjectedMileage: Decimal;
        ProjectedAge: Integer;
        BestRV: Decimal;
        Found: Boolean;
    begin
        ProjectedMileage := QuoteItem."Monthly Mileage (km)" * QuoteItem."Contract Term (Months)";
        ProjectedAge := QuoteItem."Contract Term (Months)";

        RVMatrix.SetCurrentKey("Item No.", "Usage Type", "Has Implement", "Effective Start Date", "Max Mileage", "Max Age");
        RVMatrix.SetFilter("Max Mileage", '>=%1', ProjectedMileage);
        RVMatrix.SetFilter("Max Age", '>=%1', ProjectedAge);
        if RVMatrix.FindFirst() then begin
            BestRV := RVMatrix."Residual Value %";
            Found := true;
        end;

        if Found then
            exit(BestRV);

        // If no exact match, use the closest mileage band
        RVMatrix.SetFilter("Max Mileage", '>=%1', ProjectedMileage);
        RVMatrix.SetRange("Max Age");
        if RVMatrix.FindFirst() then
            exit(RVMatrix."Residual Value %");

        Error(NoResidualValueRangeErr,
            ProjectedMileage, ProjectedAge, QuoteItem."Item No.");
    end;
}