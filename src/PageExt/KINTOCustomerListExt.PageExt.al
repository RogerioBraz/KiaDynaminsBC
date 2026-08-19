pageextension 50101 "KINTO Customer List Ext" extends "Customer List"
{
    layout
    {
        addafter("Payments (LCY)")
        {
            field("KINTO Customer Type"; Rec."KINTO Customer Type")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("KINTO Credit Score"; Rec."KINTO Credit Score")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}