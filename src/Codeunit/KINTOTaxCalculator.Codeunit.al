codeunit 50104 "KINTO Tax Calculator"
{

    procedure CalculateTaxes(var QuoteHeader: Record "KINTO Quote Header"; var QuoteItem: Record "KINTO Quote Item")
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if not CountrySetup.Get(QuoteHeader."Country Code") then exit;

        // PIS/COFINS rates
        QuoteItem."PIS COFINS Tariff %" := 9.25; // 1.65% PIS + 7.6% COFINS
        QuoteItem."PIS COFINS Credit %" := 9.25;

        // IPVA
        if QuoteItem."IPVA Rate %" = 0 then
            QuoteItem."IPVA Rate %" := 0.019; // 1.9% default for BR

        // Profit Tax
        QuoteItem."Profit Tax Rate %" := CountrySetup."Profit Tax Rate %";

        // Tax Depreciation Period
        if QuoteItem."Tax Depreciation Period" = 0 then
            QuoteItem."Tax Depreciation Period" := CountrySetup."Tax Depreciation Period";
    end;
}