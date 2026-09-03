codeunit 50105 "KINTO Commission Calculator"
{
    var
        CountrySetupNotFoundErr: Label 'Commissions were not calculated because country setup %1 does not exist. Configure the country in KINTO Country Setup and try again.';

    procedure CalculateCommissions(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if not CountrySetup.Get(QuoteHeader."Country Code") then
            Error(CountrySetupNotFoundErr, QuoteHeader."Country Code");

        // DLR Commission
        case CountrySetup."DLR Commission Model" of
            CountrySetup."DLR Commission Model"::"One-Shot":
                QuoteItem."DLR Commission Amount" := QuoteItem."Purchase Price" * QuoteItem."DLR Sales Commission %" / 100;
            CountrySetup."DLR Commission Model"::Monthly:
                QuoteItem."DLR Commission Amount" := 0; // Calculated monthly in cash flow
        end;

        // Total Manufacturer Discount
        QuoteItem."Total Mfr. Discount %" := QuoteItem."Discount Rate %" +
            (QuoteItem."Mfr. Sales Commission %" - QuoteItem."DLR Sales Commission %") +
            (QuoteItem."Mfr. Delivery Commission %" - QuoteItem."DLR Delivery Commission %");
    end;
}