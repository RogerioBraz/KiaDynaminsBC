page 50461 "KINTO Remarketing Sale List"
{
    Caption = 'Remarketing Sales';
    PageType = List;
    SourceTable = "KINTO Remarketing Sale";
    SourceTableView = sorting("Sale No.") order(descending);
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Remarketing Sale";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Sale No."; Rec."Sale No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Buyer Type"; Rec."Buyer Type") { ApplicationArea = All; }
                field("Buyer Name"; Rec."Buyer Name") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Sale Price"; Rec."Sale Price") { ApplicationArea = All; }
                field("Total Cost"; Rec."Total Cost") { ApplicationArea = All; }
                field("Gross Margin"; Rec."Gross Margin") { ApplicationArea = All; }
                field("Margin %"; Rec."Margin %") { ApplicationArea = All; }
                field("Sale Date"; Rec."Sale Date") { ApplicationArea = All; }
                field("Payment Date"; Rec."Payment Date") { ApplicationArea = All; }
            }
        }
    }
}
