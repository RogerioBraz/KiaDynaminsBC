codeunit 50110 "KINTO Install/Upgrade"
{
    Subtype = Install;

    // trigger OnInstallAppPerDatabase()
    trigger OnInstallAppPerCompany()
    begin
        CreateNumberSeries();
        CreateDefaultCountrySetup();
        CreateDefaultCFComponents();
        CreateInsuranceNumberSeries();
    end;

    local procedure CreateNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Quote No. Series
        if not NoSeries.Get('KINTO-QUOTE') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-QUOTE';
            NoSeries.Description := 'KINTO Quote Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-QUOTE';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'Q-00001';
            NoSeriesLine."Ending No." := 'Q-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Approval Request No. Series
        if not NoSeries.Get('KINTO-APPR') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-APPR';
            NoSeries.Description := 'KINTO Approval Request Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-APPR';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'APR-00001';
            NoSeriesLine."Ending No." := 'APR-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Snapshot ID No. Series
        if not NoSeries.Get('KINTO-SNAP') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-SNAP';
            NoSeries.Description := 'KINTO Snapshot Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-SNAP';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'SNP-00001';
            NoSeriesLine."Ending No." := 'SNP-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        // Inventory Vehicle No. Series
        if not NoSeries.Get('KINTO-VEH') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-VEH';
            NoSeries.Description := 'KINTO Inventory Vehicle Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-VEH';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'VH-00001';
            NoSeriesLine."Ending No." := 'VH-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;
    end;

    local procedure CreateDefaultCountrySetup()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        // Brazil
        if not CountrySetup.Get('BR') then begin
            CountrySetup.Init();
            CountrySetup."Country Code" := 'BR';
            CountrySetup."Pricing Methodology" := CountrySetup."Pricing Methodology"::"Target ROI";
            CountrySetup."Currency Code" := 'BRL';
            CountrySetup."National Revenue Tax %" := 9.25;
            CountrySetup."Profit Tax Rate %" := 34;
            CountrySetup."Tax Depreciation Period" := 60;
            CountrySetup."Annual Interest Expense %" := 9.5;
            CountrySetup."Spread" := 4.75;
            CountrySetup."Default Inflation Index %" := 2.0;
            CountrySetup."Inflation Adj. Frequency" := CountrySetup."Inflation Adj. Frequency"::Annually;
            CountrySetup."Annual Tire Inflation %" := 7.0;
            CountrySetup."Idleness Rate %" := 2.0;
            CountrySetup."Credit Risk A %" := 0.4;
            CountrySetup."Credit Risk B %" := 1.0;
            CountrySetup."Credit Risk C %" := 1.2;
            CountrySetup."Credit Risk D %" := 2.0;
            CountrySetup."Credit Risk E %" := 3.0;
            CountrySetup."Credit Risk F %" := 8.5;
            CountrySetup."Default Credit Risk %" := 4.0;
            CountrySetup."Suggested Negot. Buffer %" := 3.0;
            CountrySetup."DLR Commission Model" := CountrySetup."DLR Commission Model"::"One-Shot";
            CountrySetup."reKinto Pre-Approved" := true;
            CountrySetup."Renew Used Car Pre-Approved" := true;
            CountrySetup."Max Projected Vehicle Age" := 120;
            CountrySetup."Max Projected Mileage" := 200000;
            CountrySetup."Standard Grace Period" := 15;
            CountrySetup."Validity Period" := 30;
            CountrySetup."Apply SGA in Cash Flow" := true;
            CountrySetup."Apply Monthly Fee Inflation" := true;
            CountrySetup."Min. Extended Analysis Months" := 1;
            CountrySetup.Insert(true);
        end;

        // Argentina
        if not CountrySetup.Get('AR') then begin
            CountrySetup.Init();
            CountrySetup."Country Code" := 'AR';
            CountrySetup."Pricing Methodology" := CountrySetup."Pricing Methodology"::"KINTO Fee";
            CountrySetup."Currency Code" := 'ARS';
            CountrySetup."Allow USD Contracts" := true;
            CountrySetup."Profit Tax Rate %" := 35;
            CountrySetup."Tax Depreciation Period" := 60;
            CountrySetup."Annual Interest Expense %" := 15.7;
            CountrySetup."Spread" := 1.057;
            CountrySetup."Default Inflation Index %" := 3.99;
            CountrySetup."Inflation Adj. Frequency" := CountrySetup."Inflation Adj. Frequency"::Quarterly;
            CountrySetup."Idleness Rate %" := 0.0;
            CountrySetup."DLR Commission Model" := CountrySetup."DLR Commission Model"::Monthly;
            CountrySetup."Net Contribution Margin %" := 5.0;
            CountrySetup."reKinto Pre-Approved" := false;
            CountrySetup."Renew Used Car Pre-Approved" := false;
            CountrySetup.Insert(true);
        end;
    end;

    local procedure CreateDefaultCFComponents()
    var
        CFComponent: Record "KINTO CF Component";
    begin
        // Revenue components
        InsertCFComponent(CFComponent, 'MONTHLY_TARIFF', 'Monthly Tariff',
            "KINTO CF Component Type"::Revenue, "KINTO CF Calc Method"::"Per Month",
            0, '', "KINTO CF Sign"::Positive, "KINTO CF Frequency"::Monthly,
            false, true, "KINTO Inflation Frequency"::Annually, true, true, 10, '');

        InsertCFComponent(CFComponent, 'PIS_COFINS_CREDIT', 'PIS/COFINS Credit on Depreciation',
            "KINTO CF Component Type"::Tax, "KINTO CF Calc Method"::Percentage,
            9.25, 'PURCHASE_PRICE', "KINTO CF Sign"::Positive, "KINTO CF Frequency"::Monthly,
            false, false, "KINTO Inflation Frequency"::None, false, true, 20, '');

        InsertCFComponent(CFComponent, 'RESALE_PRICE', 'Final Resale Price',
            "KINTO CF Component Type"::Resale, "KINTO CF Calc Method"::"Fixed Value",
            0, '', "KINTO CF Sign"::Positive, "KINTO CF Frequency"::"End-of-Contract",
            false, false, "KINTO Inflation Frequency"::None, false, true, 90, '');

        // Cost components
        InsertCFComponent(CFComponent, 'PURCHASE_PRICE', 'Purchase Price (incl. Equipment)',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Fixed Value",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"Month Zero",
            true, false, "KINTO Inflation Frequency"::None, false, true, 1, '');

        InsertCFComponent(CFComponent, 'PIS_COFINS_TARIFF', 'PIS/COFINS on Tariff',
            "KINTO CF Component Type"::Tax, "KINTO CF Calc Method"::Percentage,
            9.25, 'TARIFF', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 30, '');

        InsertCFComponent(CFComponent, 'TAX_DEPRECIATION', 'Tax Depreciation',
            "KINTO CF Component Type"::Depreciation, "KINTO CF Calc Method"::"Per Month",
            0, 'PURCHASE_PRICE', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, false, "KINTO Inflation Frequency"::None, false, true, 40, '');

        InsertCFComponent(CFComponent, 'MAINTENANCE_COST', 'Maintenance Cost',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Per KM",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"Mileage-Triggered",
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 50, '');

        InsertCFComponent(CFComponent, 'TIRE_EXPENSE', 'Tire Expense',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Per KM",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"Mileage-Triggered",
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 55, '');

        InsertCFComponent(CFComponent, 'IPVA', 'IPVA',
            "KINTO CF Component Type"::Tax, "KINTO CF Calc Method"::Percentage,
            0, 'PURCHASE_PRICE', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Annually,
            false, false, "KINTO Inflation Frequency"::None, false, true, 60, '');

        InsertCFComponent(CFComponent, 'DPVAT_LICENSING', 'DPVAT + Licensing',
            "KINTO CF Component Type"::Tax, "KINTO CF Calc Method"::"Fixed Value",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, false, "KINTO Inflation Frequency"::None, false, true, 65, '');

        InsertCFComponent(CFComponent, 'BODY_INSURANCE', 'Vehicle Body Insurance',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Fixed Value",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"Month Zero",
            true, false, "KINTO Inflation Frequency"::None, false, true, 70, '');

        InsertCFComponent(CFComponent, 'TELEMATICS', 'Telematics',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Per Month",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 75, '');

        InsertCFComponent(CFComponent, 'TRAFFIC_FINE_FEE', 'Traffic Fine System Fee',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Per Month",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 78, '');

        InsertCFComponent(CFComponent, 'SGA', 'SG&A',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Per Month",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 80, '');

        InsertCFComponent(CFComponent, 'INTEREST_EXPENSE', 'Interest Expense',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::Percentage,
            0, 'PURCHASE_PRICE', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, false, "KINTO Inflation Frequency"::None, false, true, 85, '');

        InsertCFComponent(CFComponent, 'DLR_COMMISSION', 'DLR Commission',
            "KINTO CF Component Type"::Commission, "KINTO CF Calc Method"::Percentage,
            0, 'PURCHASE_PRICE', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"Month Zero",
            true, false, "KINTO Inflation Frequency"::None, false, true, 5, '');

        InsertCFComponent(CFComponent, 'RESALE_COST', 'Resale Cost',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::Percentage,
            3, 'FINAL_RESALE_PRICE', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"End-of-Contract",
            false, false, "KINTO Inflation Frequency"::None, false, true, 95, '');

        InsertCFComponent(CFComponent, 'VEH_REGISTRATION', 'Vehicle Registration',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Fixed Value",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"Month Zero",
            true, false, "KINTO Inflation Frequency"::None, false, true, 3, '');

        InsertCFComponent(CFComponent, 'KINTO_SHARE', 'KINTO Share Coupon',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Fixed Value",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::"Month Zero",
            true, false, "KINTO Inflation Frequency"::None, false, true, 7, '');

        InsertCFComponent(CFComponent, 'IDLENESS', 'Idleness Cost',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::Percentage,
            0, 'TARIFF', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, false, "KINTO Inflation Frequency"::None, false, true, 82, '');

        InsertCFComponent(CFComponent, 'CREDIT_RISK', 'Credit Risk',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::Percentage,
            0, 'TARIFF', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, false, "KINTO Inflation Frequency"::None, false, true, 83, '');

        InsertCFComponent(CFComponent, 'ROADSIDE_ASSIST', 'Roadside Assistance',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Fixed Value",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Annually,
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 72, '');

        InsertCFComponent(CFComponent, 'SPARE_CAR', 'Spare Car Expense',
            "KINTO CF Component Type"::Cost, "KINTO CF Calc Method"::"Per Month",
            0, '', "KINTO CF Sign"::Negative, "KINTO CF Frequency"::Monthly,
            false, true, "KINTO Inflation Frequency"::Annually, false, true, 77, '');
    end;

    local procedure InsertCFComponent(
        var CFComponent: Record "KINTO CF Component";
        ComponentID: Code[30];
        Desc: Text[100];
        CompType: Enum "KINTO CF Component Type";
        CalcMethod: Enum "KINTO CF Calc Method";
        ValueDef: Decimal;
        BaseRef: Code[30];
        SignVal: Enum "KINTO CF Sign";
        FreqVal: Enum "KINTO CF Frequency";
        MonthZero: Boolean;
        IndexApplied: Boolean;
        IndexFreq: Enum "KINTO Inflation Frequency";
        ExtendedCalc: Boolean;
        VisibleReports: Boolean;
        SortOrderVal: Integer;
        CountryCode: Code[10])
    begin
        if CFComponent.Get(ComponentID, CountryCode) then exit;

        CFComponent.Init();
        CFComponent."Component ID" := ComponentID;
        CFComponent.Description := Desc;
        CFComponent."Component Type" := CompType;
        CFComponent."Calculation Method" := CalcMethod;
        CFComponent."Value Definition" := ValueDef;
        CFComponent."Base Reference" := BaseRef;
        CFComponent.Sign := SignVal;
        CFComponent.Frequency := FreqVal;
        CFComponent."Calculate in Month Zero" := MonthZero;
        CFComponent."Indexation Applied" := IndexApplied;
        CFComponent."Indexation Frequency" := IndexFreq;
        CFComponent."Extended Calculation" := ExtendedCalc;
        CFComponent."Visible in Reports" := VisibleReports;
        CFComponent."Sort Order" := SortOrderVal;
        CFComponent."Country Code" := CountryCode;
        CFComponent.Insert(true);
    end;

    local procedure CreateInsuranceNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get('KINTO-INS') then begin
            NoSeries.Init();
            NoSeries.Code := 'KINTO-INS';
            NoSeries.Description := 'KINTO Insurance Quote Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'KINTO-INS';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'INS-00001';
            NoSeriesLine."Ending No." := 'INS-99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;
    end;
}