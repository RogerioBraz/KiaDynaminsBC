tableextension 60000 "KINTO Vendor Ext" extends Vendor
{
    fields
    {
        field(60000; "KINTO Labor Rate Managed"; Boolean)
        {
            Caption = 'KINTO Labor Rate Managed';
            DataClassification = CustomerContent;
        }
    }
}
