page 50203 "KINTO Financial Product List"
{
    Caption = 'KINTO Financial Products';
    PageType = List;
    SourceTable = "KINTO Financial Product";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Financial Product Card";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Product Code"; Rec."Product Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Product Type"; Rec."Product Type") { ApplicationArea = All; }
                field("Service Item No."; Rec."Service Item No.") { ApplicationArea = All; }
                field("Unit Price"; Rec."Unit Price") { ApplicationArea = All; }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group") { ApplicationArea = All; }
                field("Separate Invoice"; Rec."Separate Invoice") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}