table 50115 "KINTO Maintenance Plan Header"
{
    Caption = 'KINTO Maintenance Plan Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Plan ID"; Code[20]) { Caption = 'Plan ID'; }
        field(2; "Description"; Text[100]) { Caption = 'Description'; }
        field(3; "Vehicle Model No."; Code[20]) { Caption = 'Vehicle Model'; TableRelation = "KINTO Vehicle Model"; }
        field(4; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item; }
        field(5; "Discount %"; Decimal) { Caption = 'Discount Rate %'; DecimalPlaces = 0 : 5; }
        field(6; "Status"; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; }
    }

    keys
    {
        key(PK; "Plan ID") { Clustered = true; }
    }
}