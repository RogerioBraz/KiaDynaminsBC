pageextension 50107 "KINTO Vendor List Ext" extends "Vendor List"
{
    layout
    {
        addafter(Control1)
        {
            field("KINTO Dealer"; Rec."KINTO Dealer")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("KINTO Default DLR Sales Comm %"; Rec."KINTO Default DLR Sales Comm %")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("KINTO Dealer Portal Access"; Rec."KINTO Dealer Portal Access")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    actions
    {
        addfirst(processing)
        {
            action(KINTOFilterDealers)
            {
                Caption = 'Filter KINTO Dealers';
                ApplicationArea = All;
                Image = Filter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Dealer", true);
                end;
            }
            action(KINTOClearDealerFilter)
            {
                Caption = 'Clear KINTO Filter';
                ApplicationArea = All;
                Image = ClearFilter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Dealer");
                end;
            }
        }
    }
}