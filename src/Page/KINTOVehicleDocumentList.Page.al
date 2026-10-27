page 60008 "KINTO Vehicle Document List"
{
    Caption = 'Vehicle Documents';
    PageType = List;
    SourceTable = "KINTO Vehicle Document";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Document Type"; Rec."Document Type") { ApplicationArea = All; }
                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("Version No."; Rec."Version No.") { ApplicationArea = All; }
                field("Issue Date"; Rec."Issue Date") { ApplicationArea = All; }
                field("Expiry Date"; Rec."Expiry Date") { ApplicationArea = All; }
                field("Is Current"; Rec."Is Current") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
            }
        }
    }
}
