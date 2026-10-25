page 50204 "KINTO Financial Product Card"
{
    Caption = 'KINTO Financial Product Card';
    PageType = Card;
    SourceTable = "KINTO Financial Product";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Product Code"; Rec."Product Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Product Type"; Rec."Product Type") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
            group(ServiceItem)
            {
                Caption = 'Sales Service Item';
                field("Service Item No."; Rec."Service Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'Service Item (Type=Service)';
                    ShowMandatory = true;
                }
                field("Service Item Description"; Rec."Service Item Description") { ApplicationArea = All; }
                field("Unit Price"; Rec."Unit Price") { ApplicationArea = All; }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; ShowMandatory = true; }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group") { ApplicationArea = All; ShowMandatory = true; }
                field("Separate Invoice"; Rec."Separate Invoice") { ApplicationArea = All; }
            }
            group(Credits)
            {
                Caption = 'Credits';
                field("Credit Allowed"; Rec."Credit Allowed") { ApplicationArea = All; }
                field("Credit Limit % of Billing"; Rec."Credit Limit % of Billing") { ApplicationArea = All; }
            }
        }
    }
}