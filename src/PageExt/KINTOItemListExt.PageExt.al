pageextension 50105 "KINTO Item List Ext" extends "Item List"
{
    layout
    {
        addafter(Control1)
        {
            field("KINTO Category"; Rec."KINTO Category")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Vehicle Model No."; Rec."Vehicle Model No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Vehicle Condition"; Rec."Vehicle Condition")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Vehicle Year"; Rec."Vehicle Year")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("MSRP Metallic Paint"; Rec."MSRP Metallic Paint")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Comm. Depreciation %"; Rec."Comm. Depreciation %")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Fixed Asset Eligible"; Rec."Fixed Asset Eligible")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Show on Dealer Portal"; Rec."Show on Dealer Portal")
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
            action(KINTOFilterVehicles)
            {
                Caption = 'Filter KINTO Vehicles';
                ApplicationArea = All;
                Image = Filter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Category", Rec."KINTO Category"::"Vehicle Base");
                end;
            }
            action(KINTOFilterAccessories)
            {
                Caption = 'Filter KINTO Accessories';
                ApplicationArea = All;
                Image = Filter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Category", Rec."KINTO Category"::Accessory);
                end;
            }
            action(KINTOClearFilter)
            {
                Caption = 'Clear KINTO Filter';
                ApplicationArea = All;
                Image = ClearFilter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Category");
                end;
            }
        }
    }
}