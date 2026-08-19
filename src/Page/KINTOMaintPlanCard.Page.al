page 50134 "KINTO Maint. Plan Card"
{
    Caption = 'KINTO Maintenance Plan';
    PageType = Card;
    SourceTable = "KINTO Maintenance Plan Header";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Plan ID"; Rec."Plan ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Vehicle Model No."; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Discount %"; Rec."Discount %") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
            part(Lines; "KINTO Maint. Plan Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Plan ID" = field("Plan ID");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewInventoryForModel)
            {
                Caption = 'Ver Veículos deste Modelo';
                ApplicationArea = All;
                Image = Item;
                Visible = Rec."Vehicle Model No." <> '';
                trigger OnAction()
                var
                    InventoryVehicle: Record "KINTO Inventory Vehicle";
                begin
                    InventoryVehicle.SetRange("Vehicle Model No.", Rec."Vehicle Model No.");
                    Page.Run(Page::"KINTO Inventory Vehicle List", InventoryVehicle);
                end;
            }
            action(ViewQuotesUsingPlan)
            {
                Caption = 'Ver Cotações com este Plano';
                ApplicationArea = All;
                Image = Document;
                trigger OnAction()
                var
                    QuoteItem: Record "KINTO Quote Item";
                    QuoteHeader: Record "KINTO Quote Header";
                begin
                    QuoteItem.SetRange("Maintenance Plan ID", Rec."Plan ID");
                    if QuoteItem.FindFirst() then begin
                        QuoteHeader.SetRange("Quote No.", QuoteItem."Quote No.");
                        Page.Run(Page::"KINTO Quote List", QuoteHeader);
                    end else
                        Message('No quotes found using this maintenance plan.');
                end;
            }
        }
    }
}