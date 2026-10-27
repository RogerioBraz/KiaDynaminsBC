table 60008 "KINTO Service Level"
{
    Caption = 'KINTO Service Level Agreement';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Service Level List";
    DrillDownPageId = "KINTO Service Level List";

    // D3 — SLA por contrato: prazos de atendimento e metas operacionais.

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract"."Contract No.";
            NotBlank = true;
        }
        field(2; "SLA Profile"; Code[20]) { Caption = 'SLA Profile'; }
        field(3; "Response Time (hours)"; Decimal) { Caption = 'Response Time (hours)'; DecimalPlaces = 0 : 2; }
        field(4; "Resolution Time (hours)"; Decimal) { Caption = 'Resolution Time (hours)'; DecimalPlaces = 0 : 2; }
        field(5; "Replacement Vehicle Hours"; Decimal) { Caption = 'Replacement Vehicle Within (hours)'; DecimalPlaces = 0 : 2; }
        field(6; "Max Downtime Days/Year"; Decimal) { Caption = 'Max Downtime (days/year)'; DecimalPlaces = 0 : 2; }
        field(7; "Penalty Per Hour"; Decimal) { Caption = 'Penalty per Hour Breached'; DecimalPlaces = 2 : 2; }
        field(8; "Penalty Cap %"; Decimal) { Caption = 'Penalty Cap (% of monthly)'; DecimalPlaces = 0 : 5; }
        field(9; "Availability Target %"; Decimal) { Caption = 'Fleet Availability Target %'; DecimalPlaces = 0 : 2; InitValue = 95; }
        field(10; Active; Boolean) { Caption = 'Active'; InitValue = true; }
    }

    keys
    {
        key(PK; "Contract No.") { Clustered = true; }
    }
}
