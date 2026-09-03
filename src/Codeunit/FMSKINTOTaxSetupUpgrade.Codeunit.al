codeunit 50115 "FMS KINTO Tax Setup Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CountrySetup.Get('BR') and (CountrySetup."PIS COFINS Credit %" = 0) then begin
            CountrySetup."PIS COFINS Credit %" := CountrySetup."National Revenue Tax %";
            CountrySetup.Modify(false);
        end;
    end;
}