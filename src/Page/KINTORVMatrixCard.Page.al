page 50102 "KINTO RV Matrix Card"
{
    Caption = 'KINTO RV Matrix Entry';
    PageType = Card;
    SourceTable = "KINTO RV Matrix";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Usage Type"; Rec."Usage Type") { ApplicationArea = All; }
                field("Has Implement"; Rec."Has Implement") { ApplicationArea = All; }
                field("Effective Start Date"; Rec."Effective Start Date") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
            group(Dimensions)
            {
                field("Max Mileage"; Rec."Max Mileage") { ApplicationArea = All; }
                field("Max Age"; Rec."Max Age") { ApplicationArea = All; }
                field("Tabulated Age"; Rec."Tabulated Age") { ApplicationArea = All; }
            }
            group(Value)
            {
                field("Residual Value %"; Rec."Residual Value %") { ApplicationArea = All; }
                field("MSRP Record"; Rec."MSRP Record") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewItem)
            {
                Caption = 'Ver Item';
                ApplicationArea = All;
                Image = Item;
                Visible = Rec."Item No." <> '';
                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    if Item.Get(Rec."Item No.") then
                        Page.Run(Page::"Item Card", Item);
                end;
            }
            action(ViewInventoryVehicles)
            {
                Caption = 'Ver Veículos em Estoque';
                ApplicationArea = All;
                Image = Item;
                Visible = Rec."Item No." <> '';
                trigger OnAction()
                var
                    InventoryVehicle: Record "KINTO Inventory Vehicle";
                begin
                    InventoryVehicle.SetRange("Item No.", Rec."Item No.");
                    Page.Run(Page::"KINTO Inventory Vehicle List", InventoryVehicle);
                end;
            }
            action(ViewAllRVEntries)
            {
                Caption = 'Ver Todas as Entradas RV';
                ApplicationArea = All;
                Image = Matrix;
                trigger OnAction()
                var
                    RVMatrix: Record "KINTO RV Matrix";
                begin
                    RVMatrix.SetRange("Item No.", Rec."Item No.");
                    Page.Run(Page::"KINTO RV Matrix List", RVMatrix);
                end;
            }
        }
    }
}