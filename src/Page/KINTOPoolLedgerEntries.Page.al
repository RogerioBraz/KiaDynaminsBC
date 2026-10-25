page 50208 "KINTO Pool Ledger Entries"
{
    Caption = 'KINTO Pool Ledger Entries';
    PageType = List;
    SourceTable = "KINTO Pool Ledger Entry";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Entry Date"; Rec."Entry Date") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Pool Type"; Rec."Pool Type") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Entry Type"; Rec."Entry Type") { ApplicationArea = All; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; }
                field("Monetary Amount"; Rec."Monetary Amount") { ApplicationArea = All; }
                field("Source Type"; Rec."Source Type") { ApplicationArea = All; }
                field("Source No."; Rec."Source No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}