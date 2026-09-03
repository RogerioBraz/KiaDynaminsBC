codeunit 50104 "KINTO Tax Calculator"
{
    var
        CountrySetupNotFoundErr: Label 'Taxes were not calculated because country setup %1 does not exist. Configure the country in KINTO Country Setup and try again.';

    procedure CalculateTaxes(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if not CountrySetup.Get(QuoteHeader."Country Code") then
            Error(CountrySetupNotFoundErr, QuoteHeader."Country Code");

        QuoteItem."PIS COFINS Tariff %" := CountrySetup."National Revenue Tax %";
        QuoteItem."PIS COFINS Credit %" := CountrySetup."PIS COFINS Credit %";
        QuoteItem."IPVA Rate %" := CountrySetup."IPVA Rate %";
        QuoteItem."Profit Tax Rate %" := CountrySetup."Profit Tax Rate %";
        QuoteItem."Tax Depreciation Period" := CountrySetup."Tax Depreciation Period";
    end;
}