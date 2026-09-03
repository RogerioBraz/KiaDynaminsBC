codeunit 50150 "KINTO Test Setup"
{
    Subtype = Normal;

    procedure SetupCountrySetupBR(var CountrySetup: Record "KINTO Country Setup")
    begin
        CountrySetup.Init();
        CountrySetup."Country Code" := 'BR';
        CountrySetup."Pricing Methodology" := CountrySetup."Pricing Methodology"::"Target ROI";
        CountrySetup."Currency Code" := 'BRL';
        CountrySetup."National Revenue Tax %" := 9.25;
        CountrySetup."PIS COFINS Credit %" := 9.25;
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
        if CountrySetup.Insert() then;
    end;

    procedure SetupCountrySetupAR(var CountrySetup: Record "KINTO Country Setup")
    begin
        CountrySetup.Init();
        CountrySetup."Country Code" := 'AR';
        CountrySetup."Pricing Methodology" := CountrySetup."Pricing Methodology"::"KINTO Fee";
        CountrySetup."Currency Code" := 'ARS';
        CountrySetup."Allow USD Contracts" := true;
        CountrySetup."Profit Tax Rate %" := 0.35;
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
        if CountrySetup.Insert() then;
    end;

    procedure SetupVehicleModel(var VehicleModel: Record "KINTO Vehicle Model")
    begin
        VehicleModel.Init();
        VehicleModel."Model No." := 'COROLLA-XRE';
        VehicleModel.Description := 'Corolla Cross 2.0L XRE CVT';
        VehicleModel.Brand := 'Toyota';
        VehicleModel."Vehicle Type" := 'SUV';
        VehicleModel."Fuel Type" := VehicleModel."Fuel Type"::Flex;
        VehicleModel."Transmission Type" := VehicleModel."Transmission Type"::CVT;
        VehicleModel."Default Usage Type" := VehicleModel."Default Usage Type"::Normal;
        VehicleModel."Default Monthly Mileage" := 1000;
        VehicleModel."Default Contract Term" := 12;
        VehicleModel."Status" := VehicleModel."Status"::Active;
        if VehicleModel.Insert() then;
    end;

    procedure SetupRVMatrix(var RVMatrix: Record "KINTO RV Matrix"; ItemNo: Code[20])
    begin
        RVMatrix.Init();
        RVMatrix."Item No." := ItemNo;
        RVMatrix."Usage Type" := RVMatrix."Usage Type"::Normal;
        RVMatrix."Has Implement" := false;
        RVMatrix."Effective Start Date" := Today;
        RVMatrix."Max Mileage" := 20000;
        RVMatrix."Max Age" := 12;
        RVMatrix."Tabulated Age" := 12;
        RVMatrix."Residual Value %" := 87.81;
        RVMatrix."Status" := RVMatrix."Status"::Active;
        RVMatrix."MSRP Record" := false;
        if RVMatrix.Insert() then;
    end;

    procedure SetupMaintenancePlan(var MaintHeader: Record "KINTO Maintenance Plan Header"; var MaintLine: Record "KINTO Maintenance Plan Line")
    begin
        MaintHeader.Init();
        MaintHeader."Plan ID" := 'COROLLA-MAIN';
        MaintHeader.Description := 'Corolla Cross Maintenance Plan';
        MaintHeader."Discount %" := 10.0;
        MaintHeader."Status" := MaintHeader."Status"::Active;
        if MaintHeader.Insert() then;

        MaintLine.Init();
        MaintLine."Plan ID" := 'COROLLA-MAIN';
        MaintLine."KM Interval" := 10000;
        MaintLine."Maintenance Cost" := 609.51;
        MaintLine."Labor Cost" := 0;
        MaintLine."Parts Cost" := 609.51;
        MaintLine."Discounted Cost" := 548.56;
        if MaintLine.Insert() then;
    end;

    procedure SetupQuoteHeader(var QuoteHeader: Record "KINTO Quote Header"; CountryCode: Code[10])
    begin
        EnsureNumberSeriesExist();

        QuoteHeader.Init();
        // Não setar Quote No. — deixar o OnInsert auto-gerar via Number Series
        QuoteHeader."Country Code" := CountryCode;
        QuoteHeader."Target ROI %" := 2.0;
        QuoteHeader."Payment Allowance Days" := 30;
        QuoteHeader."Credit Score" := 'A';
        QuoteHeader.Insert(true);
        // Após Insert, Quote No. é auto-gerado e disponível
    end;

    procedure SetupQuoteItem(var QuoteItem: Record "KINTO Quote Item"; QuoteNo: Code[20])
    begin
        QuoteItem.Init();
        QuoteItem."Quote No." := QuoteNo;
        QuoteItem."Line No." := 10000;
        QuoteItem."Item No." := 'CC-XRE';
        QuoteItem.Description := 'Corolla Cross 2.0L XRE CVT';
        QuoteItem."Vehicle Model No." := 'COROLLA-XRE';
        QuoteItem."Usage Type" := QuoteItem."Usage Type"::Normal;
        QuoteItem."Vehicle Condition" := QuoteItem."Vehicle Condition"::New;
        QuoteItem."Contract Term (Months)" := 12;
        QuoteItem."Monthly Mileage (km)" := 1000;
        QuoteItem."Payment Allowance (days)" := 30;
        QuoteItem."Lead Time (days)" := 1;
        QuoteItem."Target ROI %" := 2.0;

        // Setar MSRP e Discount ANTES de Insert para que OnValidate calcule Purchase Price
        //QuoteItem.MSRP := 191190;
        //QuoteItem."Discount Rate %" := 15;
        QuoteItem.Validate(MSRP, 191190);
        QuoteItem.Validate("Discount Rate %", 15);
        // Purchase Price será auto-calculado pelo OnValidate de MSRP/Discount
        // Equipment Price = 0, então Purchase Price = 191190 * 0.85 = 162511.5

        QuoteItem."Depreciation Market %" := 12.19;
        // Final Resale Price será auto-calculado pelo OnValidate de Depreciation Market %
        // se Purchase Price já estiver setado

        QuoteItem."Discount to DLR %" := 9;
        QuoteItem."Resale Cost %" := 0;
        QuoteItem."DLR Sales Commission %" := 2;
        QuoteItem."IPVA Rate %" := 0.6;
        QuoteItem."Vehicle Registration Cost" := 184;
        QuoteItem."Body Insurance" := 1773.45;
        QuoteItem."Telematics Monthly" := 91.05;
        QuoteItem."Traffic Fine Fee Monthly" := 9.9;
        QuoteItem."SGA Amount" := 678;
        QuoteItem."Tire Expense" := 0;
        QuoteItem."Tire Change Timing (km)" := 50000;
        QuoteItem."Roadside Assistance Y1" := 7;
        QuoteItem."Spare Car Expense" := 30;
        QuoteItem."Maintenance Plan ID" := 'COROLLA-MAIN';
        QuoteItem."Incl. Preventive Maint." := true;
        QuoteItem."Contract Start Month" := 9;
        QuoteItem."Tax Depreciation Period" := 60;
        /*if CountrySetup.Get('BR') then begin
        QuoteItem."Tax Depreciation Period" :=
        CountrySetup."Tax Depreciation Period";
        end;*/
        QuoteItem.Insert(true);
    end;

    procedure SetupInventoryVehicle(var InventoryVehicle: Record "KINTO Inventory Vehicle"; VehicleNo: Code[20])
    begin
        EnsureNumberSeriesExist();

        InventoryVehicle.Init();
        // Não setar Vehicle No. — deixar OnInsert auto-gerar
        // Mas para testes determinísticos, podemos setar manualmente
        InventoryVehicle."Vehicle No." := VehicleNo;
        InventoryVehicle."Vehicle Condition" := InventoryVehicle."Vehicle Condition"::Used;
        InventoryVehicle."Status" := InventoryVehicle."Status"::Available;
        InventoryVehicle."Booking Value" := 100000;
        InventoryVehicle.Insert(true);
    end;

    local procedure EnsureNumberSeriesExist()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        EnsureSingleNoSeries(NoSeries, NoSeriesLine, 'KINTO-QUOTE', 'Q-00001', 'Q-99999');
        EnsureSingleNoSeries(NoSeries, NoSeriesLine, 'KINTO-APPR', 'APR-00001', 'APR-99999');
        EnsureSingleNoSeries(NoSeries, NoSeriesLine, 'KINTO-SNAP', 'SNP-00001', 'SNP-99999');
        EnsureSingleNoSeries(NoSeries, NoSeriesLine, 'KINTO-VEH', 'VH-00001', 'VH-99999');
    end;

    local procedure EnsureSingleNoSeries(var NoSeries: Record "No. Series"; var NoSeriesLine: Record "No. Series Line"; SeriesCode: Code[20]; StartNo: Code[20]; EndNo: Code[20])
    begin
        if not NoSeries.Get(SeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := SeriesCode;
            NoSeries.Description := 'KINTO Test ' + SeriesCode;
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := SeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := StartNo;
            NoSeriesLine."Ending No." := EndNo;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;
    end;

    procedure CleanupTestData()
    var
        CountrySetup: Record "KINTO Country Setup";
        VehicleModel: Record "KINTO Vehicle Model";
        RVMatrix: Record "KINTO RV Matrix";
        MaintHeader: Record "KINTO Maintenance Plan Header";
        MaintLine: Record "KINTO Maintenance Plan Line";
        QuoteHeader: Record "KINTO Quote Header";
        QuoteItem: Record "KINTO Quote Item";
        CFHeader: Record "KINTO Cash Flow Header";
        CFData: Record "KINTO Cash Flow Data";
        Snapshot: Record "KINTO Simulation Snapshot";
        ApprovalReq: Record "KINTO Approval Request";
        InventoryVehicle: Record "KINTO Inventory Vehicle";
        OdometerHist: Record "KINTO Vehicle Odometer History";
        PricingCue: Record "KINTO Pricing Cue";
    begin
        CFData.DeleteAll();
        CFHeader.DeleteAll();
        Snapshot.DeleteAll();
        ApprovalReq.DeleteAll();
        QuoteItem.DeleteAll();
        QuoteHeader.DeleteAll();
        MaintLine.DeleteAll();
        MaintHeader.DeleteAll();
        RVMatrix.DeleteAll();
        VehicleModel.DeleteAll();
        CountrySetup.DeleteAll();
        InventoryVehicle.DeleteAll();
        OdometerHist.DeleteAll();
        PricingCue.DeleteAll();
        // NÃO deletar No. Series — podem ser usados por outros processos
    end;
}