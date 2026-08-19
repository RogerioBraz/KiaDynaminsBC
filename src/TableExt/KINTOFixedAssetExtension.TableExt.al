tableextension 50103 "KINTO Fixed Asset Extension" extends "Fixed Asset"
{
    fields
    {
        field(50100; "KINTO Inventory Vehicle No."; Code[20])
        {
            Caption = 'KINTO Inventory Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
            DataClassification = CustomerContent;
        }
        field(50101; "KINTO Booking Value"; Decimal)
        {
            Caption = 'KINTO Booking Value (Managerial)';
            DataClassification = CustomerContent;
        }
        field(50102; "KINTO Frozen Booking Value"; Decimal)
        {
            Caption = 'KINTO Frozen Booking Value';
            DataClassification = CustomerContent;
        }
        field(50103; "KINTO Monthly Booking Value"; Decimal)
        {
            Caption = 'KINTO Monthly Booking Value';
            DataClassification = CustomerContent;
        }
        field(50104; "KINTO Initial Value"; Decimal)
        {
            Caption = 'KINTO Initial Value (Contract Start)';
            DataClassification = CustomerContent;
        }
        field(50105; "KINTO Projected Residual Value"; Decimal)
        {
            Caption = 'KINTO Projected Residual Value (Contract End)';
            DataClassification = CustomerContent;
        }
        field(50106; "KINTO Last Contract No."; Code[20])
        {
            Caption = 'KINTO Last Contract No.';
            DataClassification = CustomerContent;
        }
        field(50107; "KINTO Asset Status"; Option)
        {
            Caption = 'KINTO Asset Status';
            OptionMembers = "Not Activated","In Contract","Returned","Remarketing";
            DataClassification = CustomerContent;
        }
    }
}