tableextension 60003 "KINTO Vehicle Contract Ext" extends "KINTO Vehicle Contract"
{
    fields
    {
        field(60000; "Maintenance Plan ID"; Code[20])
        {
            Caption = 'Maintenance Plan';
            DataClassification = CustomerContent;
            TableRelation = "KINTO Maintenance Plan Header"."Plan ID";
        }
        field(60001; "Last Preventive Date"; Date)
        {
            Caption = 'Last Preventive Date';
            DataClassification = CustomerContent;
        }
        field(60002; "Last Preventive Odometer"; Decimal)
        {
            Caption = 'Last Preventive Odometer';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
        }
        field(60003; "Next Preventive Date"; Date)
        {
            Caption = 'Next Preventive Date';
            DataClassification = CustomerContent;
        }
        field(60004; "Next Preventive Odometer"; Decimal)
        {
            Caption = 'Next Preventive Odometer';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
        }
    }
}
