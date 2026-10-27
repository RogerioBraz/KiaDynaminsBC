codeunit 60004 "KINTO Series Setup Upgrade"
{
    Subtype = Upgrade;

    // ============================================================
    // Garante que as series de numeracao e os limites de calculo
    // existam em ambientes JA INSTALADOS.
    // OnInstallAppPerCompany so roda no primeiro publish — quem ja tem
    // o app publicado nunca recebia as series novas, e o documento
    // nascia com PK vazia ("Ja existe o registro ... No.=''").
    // ============================================================
    trigger OnUpgradePerCompany()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        EnsureSeries(NoSeries, NoSeriesLine);
        SeedCompanyCountryBinding(CountrySetup);
        SeedCountrySeriesFields(CountrySetup);
        SeedCountryCalcLimits(CountrySetup);
    end;

    local procedure CreateSeries(Code: Code[20]; Descr: Text[100]; StartNo: Code[20]; EndNo: Code[20];
        var NoSeries: Record "No. Series"; var NoSeriesLine: Record "No. Series Line")
    begin
        if NoSeries.Get(Code) then
            exit;
        NoSeries.Init();
        NoSeries.Code := Code;
        NoSeries.Description := Descr;
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := StartNo;
        NoSeriesLine."Ending No." := EndNo;
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);
    end;

    local procedure EnsureSeries(var NoSeries: Record "No. Series"; var NoSeriesLine: Record "No. Series Line")
    begin
        CreateSeries('KINTO-EVAL', 'KINTO Contract Evaluations', 'EV-00001', 'EV-99999', NoSeries, NoSeriesLine);
        CreateSeries('KINTO-PCL', 'KINTO Pre-Closures', 'PC-00001', 'PC-99999', NoSeries, NoSeriesLine);
        CreateSeries('KINTO-RET', 'KINTO Vehicle Returns', 'R-00001', 'R-99999', NoSeries, NoSeriesLine);
        CreateSeries('KINTO-REC', 'KINTO Recovery Cases', 'RC-00001', 'RC-99999', NoSeries, NoSeriesLine);
        CreateSeries('KINTO-BILL', 'KINTO Billing', 'B-00001', 'B-99999', NoSeries, NoSeriesLine);
    end;


    // Vincula a EMPRESA ao Country Setup. Sem isso, os processos nao sabem qual
    // pais usar. Regra: se a empresa ja tem vinculo, respeita; senao usa o setup
    // unico (base antiga, 1 pais) ou, havendo mais de um, o setup 'BR' como
    // default historico — o usuario ajusta na Company Information.
    local procedure SeedCompanyCountryBinding(var CountrySetup: Record "KINTO Country Setup")
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            exit;
        if CompanyInformation."KINTO Country Code" <> '' then
            exit; // ja configurado pelo usuario: nao sobrescreve
        if CountrySetup.GetSingleSetup() then begin
            CompanyInformation."KINTO Country Code" := CountrySetup."Country Code";
            CompanyInformation.Modify(false);
            exit;
        end;
        if CountrySetup.Get('BR') then begin
            CompanyInformation."KINTO Country Code" := 'BR';
            CompanyInformation.Modify(false);
        end;
    end;

    // Preenche os campos de serie do Country Setup com as series existentes,
    // para o usuario ver o valor na tela (em vez de campo vazio com default oculto).
    local procedure SeedCountrySeriesFields(var CountrySetup: Record "KINTO Country Setup")
    var
        NoSeries: Record "No. Series";
    begin
        CountrySetup.Reset();
        if CountrySetup.FindSet() then
            repeat
                if IsBlankSeries(CountrySetup."Contract Series") then
                    CountrySetup."Contract Series" := ExistingSeries('KINTO-CONTR', NoSeries);
                if IsBlankSeries(CountrySetup."Pricing Series") then
                    CountrySetup."Pricing Series" := ExistingSeries('KINTO-QUOTE', NoSeries);
                if IsBlankSeries(CountrySetup."Condition Series") then
                    CountrySetup."Condition Series" := ExistingSeries('KINTO-COND', NoSeries);
                if IsBlankSeries(CountrySetup."Ticket Series") then
                    CountrySetup."Ticket Series" := ExistingSeries('KINTO-TICK', NoSeries);
                if IsBlankSeries(CountrySetup."Return Series") then
                    CountrySetup."Return Series" := ExistingSeries('KINTO-RET', NoSeries);
                if IsBlankSeries(CountrySetup."Substitution Series") then
                    CountrySetup."Substitution Series" := ExistingSeries('KINTO-SUB', NoSeries);
                if IsBlankSeries(CountrySetup."Settlement Series") then
                    CountrySetup."Settlement Series" := ExistingSeries('KINTO-STL', NoSeries);
                if IsBlankSeries(CountrySetup."Recovery Series") then
                    CountrySetup."Recovery Series" := ExistingSeries('KINTO-REC', NoSeries);
                if IsBlankSeries(CountrySetup."Claim Series") then
                    CountrySetup."Claim Series" := ExistingSeries('KINTO-CLM', NoSeries);
                if IsBlankSeries(CountrySetup."Fine Series") then
                    CountrySetup."Fine Series" := ExistingSeries('KINTO-FINE', NoSeries);
                if IsBlankSeries(CountrySetup."Policy Series") then
                    CountrySetup."Policy Series" := ExistingSeries('KINTO-POL', NoSeries);
                if IsBlankSeries(CountrySetup."Device Series") then
                    CountrySetup."Device Series" := ExistingSeries('KINTO-DEV', NoSeries);
                if IsBlankSeries(CountrySetup."Vehicle Series") then
                    CountrySetup."Vehicle Series" := ExistingSeries('KINTO-VEH', NoSeries);
                if IsBlankSeries(CountrySetup."Approval Series") then
                    CountrySetup."Approval Series" := ExistingSeries('KINTO-APPR', NoSeries);
                if IsBlankSeries(CountrySetup."Remarketing Offer Series") then
                    CountrySetup."Remarketing Offer Series" := ExistingSeries('KINTO-RMK', NoSeries);
                if IsBlankSeries(CountrySetup."Remarketing Sale Series") then
                    CountrySetup."Remarketing Sale Series" := ExistingSeries('KINTO-RMS', NoSeries);
                if IsBlankSeries(CountrySetup."Evaluation Series") then
                    CountrySetup."Evaluation Series" := ExistingSeries('KINTO-EVAL', NoSeries);
                if IsBlankSeries(CountrySetup."Pre-Closure Series") then
                    CountrySetup."Pre-Closure Series" := ExistingSeries('KINTO-PCL', NoSeries);
                CountrySetup.Modify(false);
            until CountrySetup.Next() = 0;
    end;

    local procedure IsBlankSeries(SeriesCode: Code[20]): Boolean
    var
        NoSeries: Record "No. Series";
    begin
        exit((SeriesCode = '') or not NoSeries.Get(SeriesCode));
    end;

    local procedure ExistingSeries(Preferred: Code[20]; var NoSeries: Record "No. Series"): Code[20]
    begin
        if NoSeries.Get(Preferred) then
            exit(Preferred);
        exit('');
    end;

    // Limites de calculo: preenche com os defaults que estavam no codigo,
    // para o usuario ver e poder alterar (antes era invisivel).
    local procedure SeedCountryCalcLimits(var CountrySetup: Record "KINTO Country Setup")
    begin
        CountrySetup.Reset();
        if CountrySetup.FindSet() then
            repeat
                if CountrySetup."Excess Km Band 1 %" = 0 then
                    CountrySetup."Excess Km Band 1 %" := 10;
                if CountrySetup."Service Credit Cap %" = 0 then
                    CountrySetup."Service Credit Cap %" := 2;
                if CountrySetup."Preventive Interval Months" = 0 then
                    CountrySetup."Preventive Interval Months" := 6;
                if CountrySetup."Contract Notice Days" = 0 then
                    CountrySetup."Contract Notice Days" := 60;
                if CountrySetup."Remarketing Km Deprec. Base" = 0 then
                    CountrySetup."Remarketing Km Deprec. Base" := 300000;
                if CountrySetup."Remarketing Km Deprec. %" = 0 then
                    CountrySetup."Remarketing Km Deprec. %" := 15;
                if CountrySetup."Device Daily Charge" = 0 then
                    CountrySetup."Device Daily Charge" := 5;
                if CountrySetup."Total Loss Threshold %" = 0 then
                    CountrySetup."Total Loss Threshold %" := 70;
                if CountrySetup."Odometer Tolerance (km)" = 0 then
                    CountrySetup."Odometer Tolerance (km)" := 500;
                CountrySetup.Modify(false);
            until CountrySetup.Next() = 0;
    end;
}
