tableextension 50220 "KINTO Purchase Header Ext" extends "Purchase Header"
{
    fields
    {
        field(50211; "KINTO Return No."; Code[20])
        {
            Caption = 'KINTO Return No.';
            DataClassification = CustomerContent;
        }
    }
}