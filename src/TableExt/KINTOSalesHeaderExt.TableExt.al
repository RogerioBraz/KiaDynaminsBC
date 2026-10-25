tableextension 50210 "KINTO Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(50200; "KINTO Contract No."; Code[20])
        {
            Caption = 'KINTO Contract No.';
            DataClassification = CustomerContent;
        }
        field(50201; "KINTO Billing Month"; Date)
        {
            Caption = 'KINTO Billing Month';
            DataClassification = CustomerContent;
        }
    }
}