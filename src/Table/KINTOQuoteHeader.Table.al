table 50110 "KINTO Quote Header"
{
    Caption = 'KINTO Quote Header';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Quote List";
    DrillDownPageId = "KINTO Quote Card";

    fields
    {
        field(1; "Quote No."; Code[20]) { Caption = 'Quote No.'; }
        field(2; "Customer No."; Code[20]) { Caption = 'Customer No.'; TableRelation = Customer; }
        field(3; "Customer Name"; Text[100]) { Caption = 'Customer Name'; FieldClass = FlowField; CalcFormula = lookup(Customer.Name where("No." = field("Customer No."))); Editable = false; }
        field(4; "Dealer No."; Code[20]) { Caption = 'Dealer No.'; TableRelation = Vendor; }
        field(5; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
        field(6; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency; }
        field(7; "Pricing Status"; Enum "KINTO Pricing Status") { Caption = 'Pricing Status'; }
        field(8; "Pricing Methodology"; Enum "KINTO Pricing Methodology") { Caption = 'Pricing Methodology'; }
        field(9; "Target ROI %"; Decimal) { Caption = 'Target ROI %'; DecimalPlaces = 0 : 5; }
        field(10; "Negotiated Monthly Price"; Decimal) { Caption = 'Negotiated Monthly Price'; }
        field(11; "Calculated Monthly Fee"; Decimal) { Caption = 'Calculated Monthly Fee'; }
        field(12; "Approval Classification"; Enum "KINTO Approval Classification") { Caption = 'Approval Classification'; }
        field(13; "Created By"; Code[50]) { Caption = 'Created By'; }
        field(14; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; }
        field(15; "Expiration Date"; Date) { Caption = 'Expiration Date'; }
        field(16; "Approval Request ID"; Code[20]) { Caption = 'Approval Request ID'; }
        field(17; "Snapshot ID"; Code[20]) { Caption = 'Snapshot ID'; }
        field(18; "Error Message"; Text[250]) { Caption = 'Error Message'; }
        field(19; "Total MSRP"; Decimal) { Caption = 'Total MSRP'; }
        field(20; "Total Purchase Price"; Decimal) { Caption = 'Total Purchase Price'; }
        field(21; "Total Monthly Fee"; Decimal) { Caption = 'Total Monthly Fee'; }
        field(22; "KINTO IRR"; Decimal) { Caption = 'KINTO IRR'; DecimalPlaces = 0 : 10; }
        field(23; "Reference IRR"; Decimal) { Caption = 'Reference IRR'; DecimalPlaces = 0 : 10; }
        field(24; "Calculated ROI"; Decimal) { Caption = 'Calculated ROI'; DecimalPlaces = 0 : 10; }
        field(25; "EBT"; Decimal) { Caption = 'EBT'; }
        field(26; "PAT"; Decimal) { Caption = 'PAT'; }
        field(27; "KINTO FCF"; Decimal) { Caption = 'KINTO Free Cash Flow'; }
        field(28; "Negotiation Buffer %"; Decimal) { Caption = 'Negotiation Buffer %'; DecimalPlaces = 0 : 5; }
        field(29; "Payment Allowance Days"; Integer) { Caption = 'Payment Allowance (days)'; }
        field(30; "Extended Analysis Months"; Integer) { Caption = 'Extended Analysis Months'; }
        field(31; "Contract Start Month"; Integer) { Caption = 'Contract Start Month'; }
        field(32; "Credit Score"; Code[5]) { Caption = 'Credit Score'; }
        field(33; "Credit Risk Factor %"; Decimal) { Caption = 'Credit Risk Factor %'; DecimalPlaces = 0 : 5; }
        field(50; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }

        // CAMPOS DE PRODUTO E PACOTES (integrados diretamente — não usar TableExtension)
        field(60; "Product Type"; Enum "KINTO Product Type") { Caption = 'Product Type'; DataClassification = CustomerContent; }
        field(61; "Glass Coverage Package ID"; Code[20])
        { Caption = 'Glass Coverage'; TableRelation = "KINTO Glass Coverage Package"; DataClassification = CustomerContent; }

        field(62; "24h Assistance Package ID"; Code[20])
        {
            Caption = '24h Assistance';
            TableRelation = "KINTO 24h Assistance Package";
            DataClassification = CustomerContent;
        }

        field(63; "Pickup Delivery Package ID"; Code[20]) { Caption = 'Pick-up & Delivery'; TableRelation = "KINTO Pickup Delivery Package"; DataClassification = CustomerContent; }
        field(64; "Replacement Vehicle Pkg ID"; Code[20]) { Caption = 'Replacement Vehicle'; TableRelation = "KINTO Replacement Vehicle Pkg"; DataClassification = CustomerContent; }
        field(65; "Service Package ID"; Code[20]) { Caption = 'Service (Telematics)'; TableRelation = "KINTO Service Package"; DataClassification = CustomerContent; }
        field(66; "Replacement Vehicle Uses"; Integer) { Caption = 'Replacement Vehicle Uses'; DataClassification = CustomerContent; }
    }

    keys { key(PK; "Quote No.") { Clustered = true; } }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        "Pricing Status" := "Pricing Status"::Draft;

        if "Quote No." = '' then
            if "No. Series" <> '' then
                "Quote No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);

        InitFromCountrySetup();

        if "Expiration Date" = 0D then
            CalcExpirationDate();
    end;

    local procedure CalcExpirationDate()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CountrySetup.Get("Country Code") then
            "Expiration Date" := CalcDate('+' + Format(CountrySetup."Validity Period") + 'D', Today)
        else
            "Expiration Date" := CalcDate('+30D', Today);
    end;

    // CORREÇÃO: procedure (não local) — precisa ser acessível pela API page
    procedure InitFromCountrySetup()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if "Country Code" = '' then exit;
        if not CountrySetup.Get("Country Code") then exit;
        "Pricing Methodology" := CountrySetup."Pricing Methodology";
        "Currency Code" := CountrySetup."Currency Code";
        "Negotiation Buffer %" := CountrySetup."Suggested Negot. Buffer %";
    end;

    // CORREÇÃO CRÍTICA: OnModify compara xRec com Rec
    // Só invalida se o status NÃO mudou (campo de dados alterado enquanto calculado)
    trigger OnModify()
    var
        QuoteItem: Record "KINTO Quote Item";
        CFData: Record "KINTO Cash Flow Data";
        CFHeader: Record "KINTO Cash Flow Header";
    begin
        if (xRec."Pricing Status" in [
            xRec."Pricing Status"::Calculated,
            xRec."Pricing Status"::"Pre-Approved",
            xRec."Pricing Status"::Approved]) and
           (Rec."Pricing Status" = xRec."Pricing Status") then begin
            CFData.SetRange("Quote No.", Rec."Quote No.");
            if CFData.FindSet() then CFData.DeleteAll();

            CFHeader.SetRange("Quote No.", Rec."Quote No.");
            if CFHeader.FindSet() then CFHeader.DeleteAll();

            QuoteItem.SetRange("Quote No.", Rec."Quote No.");
            if QuoteItem.FindSet() then
                repeat
                    QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Draft;
                    QuoteItem.Modify(true);
                until QuoteItem.Next() = 0;

            Rec."Pricing Status" := Rec."Pricing Status"::Draft;
            Rec."Approval Classification" := Rec."Approval Classification"::Standard;
            Rec."Calculated Monthly Fee" := 0;
            Rec."Total MSRP" := 0;
            Rec."Total Purchase Price" := 0;
            Rec."Total Monthly Fee" := 0;
            Rec."KINTO IRR" := 0;
            Rec."Reference IRR" := 0;
            Rec."Calculated ROI" := 0;
            Rec.EBT := 0;
            Rec.PAT := 0;
            Rec."KINTO FCF" := 0;
        end;
    end;

    procedure CalcExtendedAnalysisMonths(Days: Integer): Integer
    var
        Months: Decimal;
    begin
        Months := Days / 30;
        exit(Round(Months, 1, '>'));
    end;
}