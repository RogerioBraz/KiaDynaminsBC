table 50116 "KINTO Maintenance Plan Line"
{
    Caption = 'KINTO Maintenance Plan Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Plan ID"; Code[20]) { Caption = 'Plan ID'; TableRelation = "KINTO Maintenance Plan Header"; }
        field(2; "KM Interval"; Decimal) { Caption = 'KM Interval'; }
        field(3; "Maintenance Cost"; Decimal) { Caption = 'Maintenance Cost'; }
        field(4; "Labor Cost"; Decimal) { Caption = 'Labor Cost'; }
        field(5; "Parts Cost"; Decimal) { Caption = 'Parts Cost'; }
        field(6; "Discounted Cost"; Decimal) { Caption = 'Discounted Maintenance Cost'; }
    }

    keys
    {
        key(PK; "Plan ID", "KM Interval") { Clustered = true; }
    }
}