table 50112 "KINTO Cash Flow Header"
{
    Caption = 'KINTO Cash Flow Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Quote No."; Code[20]) { Caption = 'Quote No.'; TableRelation = "KINTO Quote Header"; }
        field(2; "Quote Line No."; Integer) { Caption = 'Quote Line No.'; }
        field(3; "Total Months"; Integer) { Caption = 'Total Months (Contract + Extended)'; }
        field(4; "Contract Term"; Integer) { Caption = 'Contract Term'; }
        field(5; "Extended Months"; Integer) { Caption = 'Extended Analysis Months'; }
        field(6; "Start Date"; Date) { Caption = 'Start Date'; }
        field(7; "End Date"; Date) { Caption = 'End Date'; }
        field(8; "KINTO FCF Total"; Decimal) { Caption = 'KINTO FCF Total'; }
        field(9; "Max Monthly Value"; Decimal) { Caption = 'Max Monthly Value'; }
    }

    keys
    {
        key(PK; "Quote No.", "Quote Line No.") { Clustered = true; }
    }
}