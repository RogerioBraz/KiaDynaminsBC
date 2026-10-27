tableextension 60002 "KINTO Maint Plan Header Ext" extends "KINTO Maintenance Plan Header"
{
    fields
    {
        field(60000; "Preventive Enabled"; Boolean)
        {
            Caption = 'Generate Preventive Tickets';
            DataClassification = CustomerContent;
        }
        field(60001; "Lead Days"; Integer)
        {
            Caption = 'Lead Days (advance notice)';
            DataClassification = CustomerContent;
            InitValue = 30;
            MinValue = 0;
        }
        field(60002; "Odometer Tolerance (km)"; Decimal)
        {
            Caption = 'Odometer Tolerance (km)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            InitValue = 500;
        }
    }
}
