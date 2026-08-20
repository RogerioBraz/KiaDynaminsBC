tableextension 50104 "KINTO Vehicle Model Ins Ext" extends "KINTO Vehicle Model"
{
    fields
    {
        field(50100; "FIPE Code"; Code[20])
        {
            Caption = 'FIPE Code';
            DataClassification = CustomerContent;
        }

        field(50102; "Manufacturer Name"; Text[50])
        {
            Caption = 'Manufacturer Name';
            DataClassification = CustomerContent;
        }

        field(50103; "Manufacturer Part Code"; Code[20])
        {
            Caption = 'Manufacturer Part Code';
            DataClassification = CustomerContent;
        }
    }
}