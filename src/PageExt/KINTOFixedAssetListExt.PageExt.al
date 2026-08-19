pageextension 50108 "KINTO Fixed Asset List Ext" extends "Fixed Asset List"
{
    layout
    {
        addafter(Control1)
        {
            field("KINTO Inventory Vehicle No."; Rec."KINTO Inventory Vehicle No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("KINTO Asset Status"; Rec."KINTO Asset Status")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("KINTO Booking Value"; Rec."KINTO Booking Value")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("KINTO Frozen Booking Value"; Rec."KINTO Frozen Booking Value")
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
            action(KINTOFilterKINTOAssets)
            {
                Caption = 'Filter KINTO Assets';
                ApplicationArea = All;
                Image = Filter;
                trigger OnAction()
                begin
                    Rec.SetFilter("KINTO Inventory Vehicle No.", '<>%1', '');
                end;
            }
            action(KINTOFilterInContract)
            {
                Caption = 'Filter In Contract';
                ApplicationArea = All;
                Image = Filter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Asset Status", Rec."KINTO Asset Status"::"In Contract");
                end;
            }
            action(KINTOClearAssetFilter)
            {
                Caption = 'Clear KINTO Filter';
                ApplicationArea = All;
                Image = ClearFilter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Inventory Vehicle No.");
                    Rec.SetRange("KINTO Asset Status");
                end;
            }
        }
    }
}