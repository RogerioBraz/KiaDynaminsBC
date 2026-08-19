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
        field(29; "Payment Allowance Days"; Integer)
        {
            Caption = 'Payment Allowance (days)';
            trigger OnValidate()
            begin
                if "Payment Allowance Days" <> 0 then
                    "Extended Analysis Months" := CalcExtendedAnalysisMonths("Payment Allowance Days");
            end;
        }
        field(30; "Extended Analysis Months"; Integer) { Caption = 'Extended Analysis Months'; }
        field(31; "Contract Start Month"; Integer) { Caption = 'Contract Start Month'; }
        field(32; "Credit Score"; Code[5]) { Caption = 'Credit Score'; }
        field(33; "Credit Risk Factor %"; Decimal) { Caption = 'Credit Risk Factor %'; DecimalPlaces = 0 : 5; }
        field(50; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Quote No.") { Clustered = true; }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        "Pricing Status" := "Pricing Status"::Draft;

        // Auto-gerar Quote No. se vazio
        if "Quote No." = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-QUOTE';
            "Quote No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;

        InitFromCountrySetup();

        // Calcular data de expiração
        if "Expiration Date" = 0D then
            CalcExpirationDate();
    end;

    trigger OnModify()
    var
        QuoteItem: Record "KINTO Quote Item";
        CFData: Record "KINTO Cash Flow Data";
        CFHeader: Record "KINTO Cash Flow Header";
    begin
        // Se a cotação já foi calculada e está sendo modificada, invalidar resultados
        if Rec."Pricing Status" in [
            Rec."Pricing Status"::Calculated,
            Rec."Pricing Status"::"Pre-Approved",
            Rec."Pricing Status"::Approved] then begin
            // Invalidar cash flow de todos os itens
            CFData.SetRange("Quote No.", Rec."Quote No.");
            if CFData.FindSet() then
                CFData.DeleteAll();

            CFHeader.SetRange("Quote No.", Rec."Quote No.");
            if CFHeader.FindSet() then
                CFHeader.DeleteAll();

            // Resetar status dos itens
            QuoteItem.SetRange("Quote No.", Rec."Quote No.");
            if QuoteItem.FindSet() then
                repeat
                    QuoteItem."Pricing Status" := QuoteItem."Pricing Status"::Draft;
                    QuoteItem.Modify(true);
                until QuoteItem.Next() = 0;

            // Resetar status do header
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

    local procedure CalcExpirationDate()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if CountrySetup.Get("Country Code") then
            "Expiration Date" := CalcDate('+' + Format(CountrySetup."Validity Period") + 'D', Today)
        else
            "Expiration Date" := CalcDate('+30D', Today);
    end;

    procedure InitFromCountrySetup()
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if "Country Code" = '' then exit;
        if not CountrySetup.Get("Country Code") then exit;

        "Pricing Methodology" := CountrySetup."Pricing Methodology";
        "Currency Code" := CountrySetup."Currency Code";
        "Negotiation Buffer %" := CountrySetup."Suggested Negot. Buffer %";
        Validate("Payment Allowance Days", 30);
    end;

    procedure CalcExtendedAnalysisMonths(Days: Integer): Integer
    var
        Months: Decimal;
    begin
        Months := Days / 30;
        exit(Round(Months, 1, '>'));
    end;
}