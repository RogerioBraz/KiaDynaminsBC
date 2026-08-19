tableextension 50102 "KINTO Vendor Extension" extends Vendor
{
    fields
    {
        field(50100; "KINTO Dealer"; Boolean)
        {
            Caption = 'KINTO Dealer';
            DataClassification = CustomerContent;
        }
        field(50101; "KINTO Default DLR Sales Comm %"; Decimal)
        {
            Caption = 'KINTO Default DLR Sales Commission %';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(50102; "KINTO Default DLR Delivery Comm %"; Decimal)
        {
            Caption = 'KINTO Default DLR Delivery Commission %';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(50103; "KINTO Dealer Portal Access"; Boolean)
        {
            Caption = 'KINTO Dealer Portal Access';
            DataClassification = CustomerContent;
        }
        field(50104; "KINTO Max Sales Commission %"; Decimal)
        {
            Caption = 'KINTO Max Sales Commission %';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(50105; "KINTO Max Delivery Commission %"; Decimal)
        {
            Caption = 'KINTO Max Delivery Commission %';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
    }
}