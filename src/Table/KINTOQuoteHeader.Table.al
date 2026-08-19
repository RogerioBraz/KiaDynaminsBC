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
        field(17; "Snapshot ID"; Integer) { Caption = 'Snapshot ID'; }
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
    }

    keys
    {
        key(PK; "Quote No.") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        "Pricing Status" := "Pricing Status"::Draft;
        InitFromCountrySetup();
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