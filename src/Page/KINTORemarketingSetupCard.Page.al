page 50457 "KINTO Remarketing Setup"
{
    Caption = 'Remarketing Setup';
    PageType = Card;
    SourceTable = "KINTO Remarketing Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Target Sale Days"; Rec."Target Sale Days") { ApplicationArea = All; }
                field("Min. Margin %"; Rec."Min. Margin %") { ApplicationArea = All; }
                field("Target Margin %"; Rec."Target Margin %") { ApplicationArea = All; }
                field("Price Formula"; Rec."Price Formula") { ApplicationArea = All; MultiLine = true; }
            }
            group(Behavior)
            {
                Caption = 'Behavior by Country';
                field("Four Eyes Approval"; Rec."Four Eyes Approval") { ApplicationArea = All; }
                field("Sale to Driver Closes Contract"; Rec."Sale to Driver Closes Contract") { ApplicationArea = All; }
                field("NFe Enabled"; Rec."NFe Enabled") { ApplicationArea = All; }
                field("Write-off Before Payment"; Rec."Write-off Before Payment") { ApplicationArea = All; }
            }
            group(Commercial)
            {
                Caption = 'Commercial';
                field("Sales Product Code"; Rec."Sales Product Code") { ApplicationArea = All; }
                field("Commission %"; Rec."Commission %") { ApplicationArea = All; }
                field("Driver Discount %"; Rec."Driver Discount %") { ApplicationArea = All; }
            }
        }
    }
}
