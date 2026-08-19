page 50114 "KINTO Quote List"
{
    Caption = 'KINTO Quotes';
    PageType = List;
    SourceTable = "KINTO Quote Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Quote Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Quote No."; Rec."Quote No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Pricing Status"; Rec."Pricing Status") { ApplicationArea = All; }
                field("Pricing Methodology"; Rec."Pricing Methodology") { ApplicationArea = All; }
                field("Calculated Monthly Fee"; Rec."Calculated Monthly Fee") { ApplicationArea = All; }
                field("KINTO IRR"; Rec."KINTO IRR") { ApplicationArea = All; }
                field("Calculated ROI"; Rec."Calculated ROI") { ApplicationArea = All; }
                field("Approval Classification"; Rec."Approval Classification") { ApplicationArea = All; }
            }
        }
    }
}