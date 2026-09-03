page 50139 "KINTO Vehicle Model Card"
{
    Caption = 'KINTO Vehicle Model';
    PageType = Card;
    SourceTable = "KINTO Vehicle Model";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Model No."; Rec."Model No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Manufacturer Code"; Rec."Manufacturer Code") { ApplicationArea = All; }
                field(Brand; Rec.Brand) { ApplicationArea = All; }
                field("Vehicle Type"; Rec."Vehicle Type") { ApplicationArea = All; }
                field("Fuel Type"; Rec."Fuel Type") { ApplicationArea = All; }
                field("Transmission Type"; Rec."Transmission Type") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
            group(VDCommission)
            {
                Caption = 'Comissão VD (por Modelo)';

                field("VD Sales Commission %"; Rec."VD Sales Commission %") { ApplicationArea = All; }
                field("VD Delivery Commission %"; Rec."VD Delivery Commission %") { ApplicationArea = All; }
                field("VD Commission Model"; Rec."VD Commission Model") { ApplicationArea = All; }
            }
            group(Defaults)
            {
                Caption = 'Default Parameters';
                field("Default Usage Type"; Rec."Default Usage Type") { ApplicationArea = All; }
                field("Default Monthly Mileage"; Rec."Default Monthly Mileage") { ApplicationArea = All; }
                field("Default Contract Term"; Rec."Default Contract Term") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewRVMatrix)
            {
                Caption = 'Ver Matriz RV';
                ApplicationArea = All;
                Image = View;
                trigger OnAction()
                var
                    RVMatrix: Record "KINTO RV Matrix";
                    Item: Record Item;
                begin
                    Item.SetRange("Vehicle Model No.", Rec."Model No.");
                    if Item.FindFirst() then begin
                        RVMatrix.SetRange("Item No.", Item."No.");
                        Page.Run(Page::"KINTO RV Matrix List", RVMatrix);
                    end;
                end;
            }
            action(ViewInventoryVehicles)
            {
                Caption = 'Ver Veículos em Estoque';
                ApplicationArea = All;
                Image = Item;
                trigger OnAction()
                var
                    InventoryVehicle: Record "KINTO Inventory Vehicle";
                begin
                    InventoryVehicle.SetRange("Vehicle Model No.", Rec."Model No.");
                    Page.Run(Page::"KINTO Inventory Vehicle List", InventoryVehicle);
                end;
            }
            action(ViewItems)
            {
                Caption = 'Ver Itens deste Modelo';
                ApplicationArea = All;
                Image = Item;
                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.SetRange("Vehicle Model No.", Rec."Model No.");
                    Page.Run(Page::"Item List", Item);
                end;
            }
        }
    }
}