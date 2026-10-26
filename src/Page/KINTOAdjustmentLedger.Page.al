page 50480 "KINTO Adjustment Ledger"
{
    Caption = 'Price Adjustment Ledger';
    PageType = List;
    SourceTable = "KINTO Adjustment Ledger";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Adjustment Month"; Rec."Adjustment Month") { ApplicationArea = All; }
                field("Index Code"; Rec."Index Code") { ApplicationArea = All; }
                field("Index Variation %"; Rec."Index Variation %") { ApplicationArea = All; }
                field("Cap Applied %"; Rec."Cap Applied %") { ApplicationArea = All; }
                field("Conditions Adjusted"; Rec."Conditions Adjusted") { ApplicationArea = All; }
                field("Prior Letter"; Rec."Prior Letter") { ApplicationArea = All; }
            }
        }
    }
}
