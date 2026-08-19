pageextension 50100 "KINTO Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            group(KINTO)
            {
                Caption = 'KINTO';
                Visible = true;

                field("KINTO Customer Type"; Rec."KINTO Customer Type")
                {
                    ApplicationArea = All;
                }
                field("KINTO Credit Score"; Rec."KINTO Credit Score")
                {
                    ApplicationArea = All;
                }
                field("KINTO Credit Risk Override %"; Rec."KINTO Credit Risk Override %")
                {
                    ApplicationArea = All;
                }
                field("KINTO Eligible for reKINTO"; Rec."KINTO Eligible for reKINTO")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}