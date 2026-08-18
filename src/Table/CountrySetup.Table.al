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

        field(24; "Inflation Adj. Frequency"; Enum "KINTO Inflation Frequency")
        {
            Caption = 'Inflation Adjustment Frequency';
        }

        field(37; "DLR Commission Model"; Enum "KINTO Commission Model")
        {
            Caption = 'DLR Commission Model';
        }

        field(43; "Validity Period"; Integer)
        {
            Caption = 'Validity Period (days)';
        }

        field(44; "Apply SGA in Cash Flow"; Boolean)
        {
            Caption = 'Apply SGA During Cash Flow';
        }

        field(49; "Ref. Interest Rate Period"; Integer)
        {
            Caption = 'Reference Interest Rate Period';
        }

        field(50; "SGA Inflation Adj. Freq."; Enum "KINTO Inflation Frequency")
        {
            Caption = 'SGA Inflation Adjustment Frequency';
        }

        field(51; "Min. Extended Analysis Months"; Integer)
        {
            Caption = 'Minimum Extended Analysis Months';
        }

        field(52; "Extended Analysis Months"; Integer)
        {
            Caption = 'Extended Analysis Months';
        }
    }

    keys
    {
        key(PK; "Country Code")
        {
            Clustered = true;
        }
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