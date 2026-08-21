page 50156 "KINTO Glass Coverage Card"
{
    Caption = 'Glass Coverage Package';
    PageType = Card;
    SourceTable = "KINTO Glass Coverage Package";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Package ID"; Rec."Package ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Deductible"; Rec."Deductible") { ApplicationArea = All; }
                field("Coverage Limit"; Rec."Coverage Limit") { ApplicationArea = All; }
                field("Balance Uses"; Rec."Balance Uses") { ApplicationArea = All; }
                field("Monetary Balance"; Rec."Monetary Balance") { ApplicationArea = All; }
                field(Armoring; Rec.Armoring) { ApplicationArea = All; }
                field("Insurance Supplier ID"; Rec."Insurance Supplier ID") { ApplicationArea = All; }
            }
            group(Pricing)
            {
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
            }
            group(Validity)
            {
                field("Active Start Date"; Rec."Active Start Date") { ApplicationArea = All; }
                field("Active End Date"; Rec."Active End Date") { ApplicationArea = All; }
                field("Show on Dealer Portal"; Rec."Show on Dealer Portal") { ApplicationArea = All; }
                field("Block Pre-Approved Pricing"; Rec."Block Pre-Approved Pricing") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}

