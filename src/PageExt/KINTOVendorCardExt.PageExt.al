pageextension 50102 "KINTO Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addafter(General)
        {

            field("KINTO Dealer"; Rec."KINTO Dealer")
            {
                ApplicationArea = All;
            }
            group(KINTODealer)
            {
                Caption = 'KINTO Dealer';
                Visible = Rec."KINTO Dealer";

                field("KINTO Default DLR Sales Comm %"; Rec."KINTO Default DLR Sales Comm %")
                {
                    ApplicationArea = All;
                }
                field("KINTO Default DLR Delivery Comm %"; Rec."KINTO Default DLR Delivery Comm %")
                {
                    ApplicationArea = All;
                }
                field("KINTO Max Sales Commission %"; Rec."KINTO Max Sales Commission %")
                {
                    ApplicationArea = All;
                }
                field("KINTO Max Delivery Commission %"; Rec."KINTO Max Delivery Commission %")
                {
                    ApplicationArea = All;
                }
                field("KINTO Dealer Portal Access"; Rec."KINTO Dealer Portal Access")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}