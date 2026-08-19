pageextension 50103 "KINTO Fixed Asset Card Ext" extends "Fixed Asset Card"
{
    layout
    {
        addafter(General)
        {
            group(KINTOBooking)
            {
                Caption = 'KINTO Booking Value';
                Visible = Rec."KINTO Inventory Vehicle No." <> '';

                field("KINTO Inventory Vehicle No."; Rec."KINTO Inventory Vehicle No.")
                {
                    ApplicationArea = All;
                }
                field("KINTO Asset Status"; Rec."KINTO Asset Status")
                {
                    ApplicationArea = All;
                }
                field("KINTO Initial Value"; Rec."KINTO Initial Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("KINTO Booking Value"; Rec."KINTO Booking Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("KINTO Monthly Booking Value"; Rec."KINTO Monthly Booking Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("KINTO Projected Residual Value"; Rec."KINTO Projected Residual Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("KINTO Frozen Booking Value"; Rec."KINTO Frozen Booking Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("KINTO Last Contract No."; Rec."KINTO Last Contract No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        addfirst(processing)
        {
            action(KINTOFreezeBooking)
            {
                Caption = 'Freeze Booking Value';
                ApplicationArea = All;
                Image = Freeze;
                Visible = Rec."KINTO Inventory Vehicle No." <> '';

                trigger OnAction()
                var
                    InventoryVehicle: Record "KINTO Inventory Vehicle";
                    BookingMgt: Codeunit "KINTO Booking Value Mgt.";
                begin
                    if Rec."KINTO Inventory Vehicle No." <> '' then
                        if InventoryVehicle.Get(Rec."KINTO Inventory Vehicle No.") then begin
                            InventoryVehicle."Booking Value" := Rec."KINTO Booking Value";
                            BookingMgt.FreezeBookingValue(InventoryVehicle);
                            Rec."KINTO Frozen Booking Value" := InventoryVehicle."Frozen Booking Value";
                            Rec."KINTO Asset Status" := Rec."KINTO Asset Status"::Returned;
                            Rec.Modify(true);
                            Message('Booking Value frozen at %1', Rec."KINTO Frozen Booking Value");
                        end;
                end;
            }
        }
    }
}