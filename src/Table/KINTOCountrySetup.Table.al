table 50100 "KINTO Country Setup"
{
    Caption = 'KINTO Country Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "Country/Region";
        }
        field(2; "Pricing Methodology"; Enum "KINTO Pricing Methodology")
        {
            Caption = 'Pricing Methodology';
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(4; "Allow USD Contracts"; Boolean)
        {
            Caption = 'Allow USD-Only Contracts';
        }
        field(5; "National Revenue Tax %"; Decimal)
        {
            Caption = 'National/Federal Revenue Tax %';
            DecimalPlaces = 0 : 5;
        }
        field(6; "National Revenue Tax Desc."; Text[100])
        {
            Caption = 'National Revenue Tax Description';
        }
        field(7; "State Revenue Tax %"; Decimal)
        {
            Caption = 'State/Provincial Revenue Tax %';
            DecimalPlaces = 0 : 5;
        }
        field(8; "State Revenue Tax Desc."; Text[100])
        {
            Caption = 'State Revenue Tax Description';
        }
        field(9; "Municipal Tax %"; Decimal)
        {
            Caption = 'Municipal Tax %';
            DecimalPlaces = 0 : 5;
        }
        field(10; "Municipal Tax Desc."; Text[100])
        {
            Caption = 'Municipal Tax Description';
        }
        field(11; "Financial Trans. Tax %"; Decimal)
        {
            Caption = 'Financial Transactions Tax %';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Financial Trans. Tax Desc."; Text[100])
        {
            Caption = 'Financial Transactions Tax Description';
        }
        field(13; "Stamp Tax %"; Decimal)
        {
            Caption = 'Stamp Tax %';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Stamp Tax Desc."; Text[100])
        {
            Caption = 'Stamp Tax Description';
        }
        field(15; "Security Fee %"; Decimal)
        {
            Caption = 'Security Fee (Surety Insurance) %';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Security Fee Desc."; Text[100])
        {
            Caption = 'Security Fee Description';
        }
        field(17; "Contingencies %"; Decimal)
        {
            Caption = 'Contingencies %';
            DecimalPlaces = 0 : 5;
        }
        field(18; "Contingencies Desc."; Text[100])
        {
            Caption = 'Contingencies Description';
        }
        field(19; "Profit Tax Rate %"; Decimal)
        {
            Caption = 'Profit Tax Rate %';
            DecimalPlaces = 0 : 5;
        }
        field(20; "Tax Depreciation Period"; Integer)
        {
            Caption = 'Tax Depreciation Period (Months)';
        }
        field(21; "Annual Interest Expense %"; Decimal)
        {
            Caption = 'Annual Interest Expense Rate %';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Spread"; Decimal)
        {
            Caption = 'Spread';
            DecimalPlaces = 0 : 5;
        }
        field(23; "Default Inflation Index %"; Decimal)
        {
            Caption = 'Default Inflation Index %';
            DecimalPlaces = 0 : 5;
        }
        field(24; "Inflation Adj. Frequency"; Enum "KINTO Inflation Frequency")
        {
            Caption = 'Inflation Adjustment Frequency';
        }
        field(25; "Annual Tire Inflation %"; Decimal)
        {
            Caption = 'Annual Tire Inflation Index %';
            DecimalPlaces = 0 : 5;
        }
        field(26; "Idleness Rate %"; Decimal)
        {
            Caption = 'Idleness Rate %';
            DecimalPlaces = 0 : 5;
        }
        field(27; "Credit Risk A %"; Decimal) { Caption = 'Credit Risk Factor A %'; DecimalPlaces = 0 : 5; }
        field(28; "Credit Risk B %"; Decimal) { Caption = 'Credit Risk Factor B %'; DecimalPlaces = 0 : 5; }
        field(29; "Credit Risk C %"; Decimal) { Caption = 'Credit Risk Factor C %'; DecimalPlaces = 0 : 5; }
        field(30; "Credit Risk D %"; Decimal) { Caption = 'Credit Risk Factor D %'; DecimalPlaces = 0 : 5; }
        field(31; "Credit Risk E %"; Decimal) { Caption = 'Credit Risk Factor E %'; DecimalPlaces = 0 : 5; }
        field(32; "Credit Risk F %"; Decimal) { Caption = 'Credit Risk Factor F %'; DecimalPlaces = 0 : 5; }
        field(33; "Default Credit Risk %"; Decimal)
        {
            Caption = 'Default Credit Risk Factor %';
            DecimalPlaces = 0 : 5;
        }
        field(34; "Suggested Negot. Buffer %"; Decimal)
        {
            Caption = 'Suggested Negotiation Buffer %';
            DecimalPlaces = 0 : 5;
        }
        field(35; "Net Contribution Margin %"; Decimal)
        {
            Caption = 'Net Contribution Margin %';
            DecimalPlaces = 0 : 5;
        }
        field(36; "Emergency Stop"; Boolean)
        {
            Caption = 'Emergency Stop of Pricing Engine';
        }
        field(37; "DLR Commission Model"; Enum "KINTO Commission Model")
        {
            Caption = 'DLR Commission Model';
        }
        field(38; "reKinto Pre-Approved"; Boolean) { Caption = 'reKinto Pricing Pre-Approved'; }
        field(39; "Renew Used Car Pre-Approved"; Boolean) { Caption = 'Renew Used Car Pricing Pre-Approved'; }
        field(40; "Max Projected Vehicle Age"; Integer) { Caption = 'Maximum Projected Vehicle Age (months)'; }
        field(41; "Max Projected Mileage"; Decimal) { Caption = 'Maximum Projected Accumulated Mileage'; }
        field(42; "Standard Grace Period"; Integer) { Caption = 'Standard Grace Period (days)'; }
        field(43; "Validity Period"; Integer) { Caption = 'Validity Period (days)'; }
        field(44; "Apply SGA in Cash Flow"; Boolean) { Caption = 'Apply SG&A During Cash Flow Analysis'; }
        field(45; "Apply Monthly Fee Inflation"; Boolean) { Caption = 'Apply Monthly Fee Inflation in Cash Flow'; }
        field(46; "Exceeded Mileage Cost Cap"; Decimal) { Caption = 'Exceeded Mileage Cost Cap'; }
        field(47; "Excess Mileage Aggrav. %"; Decimal) { Caption = 'Excess Mileage Aggravation Threshold %'; DecimalPlaces = 0 : 5; }
        field(48; "Aggravated Excess Mileage"; Decimal) { Caption = 'Aggravated Excess Mileage Value'; }
        field(49; "Ref. Interest Rate Period"; Integer) { Caption = 'Reference Interest Rate Index Periodicity'; }
        field(50; "SGA Inflation Adj. Freq."; Enum "KINTO Inflation Frequency") { Caption = 'SG&A Inflation Adjustment Frequency'; }
        field(51; "Min. Extended Analysis Months"; Integer) { Caption = 'Minimum Extended Analysis Months'; }
        field(52; "Extended Analysis Months"; Integer) { Caption = 'Extended Analysis Period (Months)'; }
        // ============================================================
        // FASE 6 — COMPORTAMENTO POR PAÍS (Fleet Control)
        // ============================================================
        field(53; "Fleet Behavior"; Enum "KINTO Fleet Behavior") { Caption = 'Fleet Behavior'; }
        field(54; "Demob. SLA Days (Lot)"; Integer) { Caption = 'Demobilization SLA: Lot (days)'; }
        field(55; "Demob. SLA Days (Wash)"; Integer) { Caption = 'Demobilization SLA: Wash (days)'; }
        field(56; "Demob. SLA Days (Save)"; Integer) { Caption = 'Demobilization SLA: Salvage (days)'; }
        field(57; "Device Aging Charge Days"; Integer) { Caption = 'Device Aging Charge Threshold (days)'; }
        field(58; "Closing Reconcile By VIN"; Boolean) { Caption = 'Monthly Closing Reconcile by VIN'; }
        field(59; "Closing Reconcile By Plate"; Boolean) { Caption = 'Monthly Closing Reconcile by Plate'; }

        field(149; "IPVA Rate %"; Decimal) { Caption = 'IPVA Rate %'; DecimalPlaces = 0 : 5; }
        field(150; "PIS COFINS Credit %"; Decimal) { Caption = 'PIS/COFINS Credit on Depreciation %'; DecimalPlaces = 0 : 5; }

        // ============================================================
        // SERIES DE NUMERACAO (configuraveis por pais/empresa)
        // Antes ficavam hardcoded no OnInsert das tabelas: o usuario nao
        // conseguia trocar a numeracao e um ambiente sem a serie gravava
        // PK vazia ("Ja existe o registro ... No.=''").
        // ============================================================
        field(200; "Pricing Series"; Code[20])
        {
            Caption = 'Quote No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(201; "Contract Series"; Code[20])
        {
            Caption = 'Contract No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(202; "Condition Series"; Code[20])
        {
            Caption = 'Condition No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(203; "Billing Series"; Code[20])
        {
            Caption = 'Billing No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(204; "Ticket Series"; Code[20])
        {
            Caption = 'Maintenance Ticket No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(205; "Return Series"; Code[20])
        {
            Caption = 'Return No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(206; "Substitution Series"; Code[20])
        {
            Caption = 'Substitution No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(207; "Settlement Series"; Code[20])
        {
            Caption = 'Settlement No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(208; "Recovery Series"; Code[20])
        {
            Caption = 'Recovery Case No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(209; "Claim Series"; Code[20])
        {
            Caption = 'Claim No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(210; "Fine Series"; Code[20])
        {
            Caption = 'Traffic Fine No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(211; "Policy Series"; Code[20])
        {
            Caption = 'Insurance Policy No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(212; "Device Series"; Code[20])
        {
            Caption = 'Telematic Device No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(213; "Vehicle Series"; Code[20])
        {
            Caption = 'Vehicle No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(214; "Approval Series"; Code[20])
        {
            Caption = 'Approval Request No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(215; "Remarketing Offer Series"; Code[20])
        {
            Caption = 'Remarketing Offer No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(216; "Remarketing Sale Series"; Code[20])
        {
            Caption = 'Remarketing Sale No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(217; "Evaluation Series"; Code[20])
        {
            Caption = 'Contract Evaluation No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(218; "Pre-Closure Series"; Code[20])
        {
            Caption = 'Pre-Closure No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        // ============================================================
        // LIMITES DE CALCULO (antes hardcoded nos codeunits)
        // ============================================================
        field(230; "Excess Km Band 1 %"; Decimal)
        {
            Caption = 'Excess Km Band 1 Threshold %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 10;
        }
        field(231; "Service Credit Cap %"; Decimal)
        {
            Caption = 'Service Credit Cap % of Monthly Billing';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 2;
        }
        field(232; "SLA Penalty Cap %"; Decimal)
        {
            Caption = 'Default SLA Penalty Cap %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(233; "Preventive Interval Months"; Integer)
        {
            Caption = 'Default Preventive Interval (months)';
            DataClassification = CustomerContent;
            InitValue = 6;
        }
        field(234; "Contract Notice Days"; Integer)
        {
            Caption = 'Expiry Notice Days';
            DataClassification = CustomerContent;
            InitValue = 60;
        }
        field(235; "Auto Extend Contracts"; Boolean)
        {
            Caption = 'Auto-Extend Expired Contracts';
            DataClassification = CustomerContent;
        }
        field(236; "Remarketing Km Deprec. Base"; Decimal)
        {
            Caption = 'Remarketing Depreciation Base (km)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            InitValue = 300000;
        }
        field(237; "Remarketing Km Deprec. %"; Decimal)
        {
            Caption = 'Remarketing Max Depreciation % at Base Km';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 15;
        }
        field(238; "Device Daily Charge"; Decimal)
        {
            Caption = 'Device Storage Daily Charge';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            InitValue = 5;
        }
        field(239; "Total Loss Threshold %"; Decimal)
        {
            Caption = 'Total Loss Threshold % of Vehicle Value';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 70;
        }
        field(240; "Odometer Tolerance (km)"; Decimal)
        {
            Caption = 'Default Preventive Odometer Tolerance (km)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            InitValue = 500;
        }
    }

    keys
    {
        key(PK; "Country Code") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        ValidateDefaults();
    end;



    // ============================================================
    // VINCULO EMPRESA -> PAIS
    // O pais usado pela empresa vem da Company Information
    // ("KINTO Country Code"). Assim duas empresas no mesmo tenant
    // podem rodar regras BR e AR sem conflito.
    // ============================================================
    procedure GetForCompany(): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            exit(false);
        if CompanyInformation."KINTO Country Code" = '' then
            exit(false);
        exit(Get(CompanyInformation."KINTO Country Code"));
    end;

    // Prefere o vinculo da empresa; cai para o codigo do documento quando a
    // empresa ainda nao foi configurada (compatibilidade com base existente).
    procedure GetForCompanyOr(DocumentCountryCode: Code[10]): Boolean
    begin
        if GetForCompany() then
            exit(true);
        if DocumentCountryCode <> '' then
            exit(Get(DocumentCountryCode));
        exit(GetSingleSetup());
    end;

    // Ultimo recurso: existe exatamente um setup -> usa (base antiga, 1 pais).
    procedure GetSingleSetup(): Boolean
    var
        Count: Integer;
        FoundCode: Code[10];
    begin
        Reset();
        if FindSet() then
            repeat
                Count += 1;
                FoundCode := "Country Code";
            until (Next() = 0) or (Count > 1);
        if Count = 1 then
            exit(Get(FoundCode));
        exit(false);
    end;

    // Codigo do pais usado pela empresa (Company Info), com fallback ao setup unico
    procedure GetCompanyCountryCode(): Code[10]
    var
        CompanyInformation: Record "Company Information";
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CompanyInformation.Get() and (CompanyInformation."KINTO Country Code" <> '') then
            exit(CompanyInformation."KINTO Country Code");
        if CountrySetup.GetSingleSetup() then
            exit(CountrySetup."Country Code");
        exit('');
    end;

    // Devolve a serie configurada para o pais do documento. Se o pais nao tiver
    // setup ou o campo estiver vazio, devolve o default historico — assim nada
    // quebra em ambiente que ainda nao configurou as series novas.
    procedure GetDefaultSeries(FieldName: Text; Fallback: Code[20]): Code[20]
    var
        CountrySetup: Record "KINTO Country Setup";
        CountryCode: Code[10];
    begin
        CountryCode := GetCompanyCountryCode();
        if (CountryCode <> '') and CountrySetup.Get(CountryCode) then
            case FieldName of
                'Contract Series':
                    if CountrySetup."Contract Series" <> '' then
                        exit(CountrySetup."Contract Series");
                'Condition Series':
                    if CountrySetup."Condition Series" <> '' then
                        exit(CountrySetup."Condition Series");
                'Ticket Series':
                    if CountrySetup."Ticket Series" <> '' then
                        exit(CountrySetup."Ticket Series");
                'Return Series':
                    if CountrySetup."Return Series" <> '' then
                        exit(CountrySetup."Return Series");
                'Substitution Series':
                    if CountrySetup."Substitution Series" <> '' then
                        exit(CountrySetup."Substitution Series");
                'Settlement Series':
                    if CountrySetup."Settlement Series" <> '' then
                        exit(CountrySetup."Settlement Series");
                'Recovery Series':
                    if CountrySetup."Recovery Series" <> '' then
                        exit(CountrySetup."Recovery Series");
                'Claim Series':
                    if CountrySetup."Claim Series" <> '' then
                        exit(CountrySetup."Claim Series");
                'Fine Series':
                    if CountrySetup."Fine Series" <> '' then
                        exit(CountrySetup."Fine Series");
                'Policy Series':
                    if CountrySetup."Policy Series" <> '' then
                        exit(CountrySetup."Policy Series");
                'Device Series':
                    if CountrySetup."Device Series" <> '' then
                        exit(CountrySetup."Device Series");
                'Vehicle Series':
                    if CountrySetup."Vehicle Series" <> '' then
                        exit(CountrySetup."Vehicle Series");
                'Approval Series':
                    if CountrySetup."Approval Series" <> '' then
                        exit(CountrySetup."Approval Series");
                'Remarketing Offer Series':
                    if CountrySetup."Remarketing Offer Series" <> '' then
                        exit(CountrySetup."Remarketing Offer Series");
                'Remarketing Sale Series':
                    if CountrySetup."Remarketing Sale Series" <> '' then
                        exit(CountrySetup."Remarketing Sale Series");
                'Evaluation Series':
                    if CountrySetup."Evaluation Series" <> '' then
                        exit(CountrySetup."Evaluation Series");
                'Pre-Closure Series':
                    if CountrySetup."Pre-Closure Series" <> '' then
                        exit(CountrySetup."Pre-Closure Series");
                'Pricing Series':
                    if CountrySetup."Pricing Series" <> '' then
                        exit(CountrySetup."Pricing Series");
            end;
        exit(Fallback);
    end;


    local procedure ValidateDefaults()
    begin
        if "Tax Depreciation Period" = 0 then
            "Tax Depreciation Period" := 60;
        if "Validity Period" = 0 then
            "Validity Period" := 30;
        if "Standard Grace Period" = 0 then
            "Standard Grace Period" := 15;
        if "Min. Extended Analysis Months" = 0 then
            "Min. Extended Analysis Months" := 1;
    end;
}