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

        field(149; "IPVA Rate %"; Decimal) { Caption = 'IPVA Rate %'; DecimalPlaces = 0 : 5; }
    }

    keys
    {
        key(PK; "Country Code") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        ValidateDefaults();
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