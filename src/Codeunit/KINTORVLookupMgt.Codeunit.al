codeunit 50101 "KINTO RV Lookup Mgt."
{
    procedure LookupResidualValue(QuoteItem: Record "KINTO Quote Item"): Decimal
    var
        RVMatrix: Record "KINTO RV Matrix";
        SelectedRV: Decimal;
    begin
        // Step 1: Effective Version Selection
        RVMatrix.SetRange("Item No.", QuoteItem."Item No.");
        RVMatrix.SetRange("Usage Type", QuoteItem."Usage Type");
        RVMatrix.SetRange("Has Implement", false); // Simplified — enhance for implement check
        RVMatrix.SetRange("Status", RVMatrix.Status::Active);
        RVMatrix.SetFilter("Effective Start Date", '<=%1', Today);
        if RVMatrix.FindLast() then begin
            // Step 2: Vehicle Attribute Filtering (already filtered by Item No.)
            // Step 3: Age Group Determination
            // Step 4: Mileage Band Selection
            SelectedRV := SelectByMileageAndAge(RVMatrix, QuoteItem);
            exit(SelectedRV);
        end;

        // Fallback: try MSRP record
        RVMatrix.SetRange("Has Implement");
        RVMatrix.SetRange("MSRP Record", true);
        if RVMatrix.FindLast() then
            exit(RVMatrix."Residual Value %");

        Error('No Residual Value found for Item %1, Usage Type %2', QuoteItem."Item No.", QuoteItem."Usage Type");
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

        RVMatrix.SetFilter("Max Mileage", '>=%1', ProjectedMileage);
        RVMatrix.SetFilter("Max Age", '>=%1', ProjectedAge);
        if RVMatrix.FindSet() then
            repeat
                if (RVMatrix."Max Mileage" >= ProjectedMileage) and
                   (RVMatrix."Max Age" >= ProjectedAge) then begin
                    BestRV := RVMatrix."Residual Value %";
                    Found := true;
                end;
            until (RVMatrix.Next() = 0) or Found;

        if Found then
            exit(BestRV);

        // If no exact match, use the closest mileage band
        RVMatrix.SetFilter("Max Mileage", '>=%1', ProjectedMileage);
        RVMatrix.SetRange("Max Age");
        if RVMatrix.FindFirst() then
            exit(RVMatrix."Residual Value %");

        Error('No RV Matrix entry matches projected mileage %1 and age %2 for Item %3',
              ProjectedMileage, ProjectedAge, QuoteItem."Item No.");
    end;
}