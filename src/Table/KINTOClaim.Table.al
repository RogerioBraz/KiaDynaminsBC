table 50469 "KINTO Claim"
{
    Caption = 'KINTO Claim';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Claim List";
    DrillDownPageId = "KINTO Claim List";

    // D3c: ciclo do sinistro — classificação em 5 trilhas, franquia,
    // indenização do segurador, total >= 70% -> total destruction ->
    // baixa do ativo fixo.

    fields
    {
        field(1; "Claim No."; Code[20]) { Caption = 'Claim No.'; }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; "Contract No."; Code[20]) { Caption = 'Contract No.'; TableRelation = "KINTO Vehicle Contract"; }
        field(4; "Vehicle No."; Code[20]) { Caption = 'Vehicle No.'; TableRelation = "KINTO Inventory Vehicle"; }
        field(5; "Policy No."; Code[20]) { Caption = 'Policy No.'; TableRelation = "KINTO Insurance Policy"; }
        field(6; "Claim Class"; Enum "KINTO Claim Class Type") { Caption = 'Claim Class'; }
        field(7; Status; Enum "KINTO Claim Status") { Caption = 'Status'; }
        field(8; "Claim Date"; Date) { Caption = 'Claim Date'; }
        field(9; "Insurer Claim No."; Text[50]) { Caption = 'Insurer Claim No.'; }
        field(10; "Market Value"; Decimal) { Caption = 'Market Value (FIPE)'; }
        field(11; "Damage Amount"; Decimal) { Caption = 'Damage Amount'; }
        field(12; "Deductible Amount"; Decimal) { Caption = 'Deductible (customer)'; }
        field(13; "Indemnity Amount"; Decimal) { Caption = 'Insurer Indemnity'; }
        field(14; "Loss Ratio %"; Decimal)
        {
            Caption = 'Loss Ratio %';
            DecimalPlaces = 0 : 2;
        }
        field(15; "Total Destruction"; Boolean) { Caption = 'Total Destruction (>= 70%)'; }
        field(16; "FA Written Off"; Boolean) { Caption = 'Fixed Asset Written Off'; Editable = false; }
        field(17; "Settlement No."; Code[20]) { Caption = 'Settlement No.'; TableRelation = "KINTO Settlement"; Editable = false; }
        field(18; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(19; Description; Text[250]) { Caption = 'Description'; }
    }

    keys
    {
        key(PK; "Claim No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
        key(Idx2; "Vehicle No.") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "Claim No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Claim Series', 'KINTO-CLM');
            "Claim No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    procedure Classify()
    begin
        TestField("Market Value");
        TestField("Damage Amount");
        if "Market Value" = 0 then
            Error(MarketValueZeroErr);
        "Loss Ratio %" := Round("Damage Amount" / "Market Value" * 100, 0.01);
        "Total Destruction" := "Loss Ratio %" >= GetTotalLossThreshold();
        if "Total Destruction" then
            "Claim Class" := "Claim Class"::"Total Destruction";
        Modify(true);
    end;

    var
        MarketValueZeroErr: Label 'Market Value must be informed to classify.';

    // Limite de destruicao total configuravel por pais (Country Setup, default 70%)
    local procedure GetTotalLossThreshold(): Decimal
    var
        CountrySetup: Record "KINTO Country Setup";
        Contract: Record "KINTO Vehicle Contract";
    begin
        if ("Contract No." <> '') and Contract.Get("Contract No.") then
            if (Contract."Country Code" <> '') and CountrySetup.Get(Contract."Country Code") then
                if CountrySetup."Total Loss Threshold %" > 0 then
                    exit(CountrySetup."Total Loss Threshold %");
        exit(70);
    end;
}
