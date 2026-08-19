page 50131 "KINTO Inventory Vehicle Card"
{
    Caption = 'KINTO Inventory Vehicle';
    PageType = Card;
    SourceTable = "KINTO Inventory Vehicle";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("VIN"; Rec."VIN") { ApplicationArea = All; }
                field("Vehicle Model No."; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field("Vehicle Condition"; Rec."Vehicle Condition") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
            group(Mileage)
            {
                Caption = 'Mileage & Age';
                field("Current Odometer"; Rec."Current Odometer") { ApplicationArea = All; }
                field("Age in Months"; Rec."Age in Months") { ApplicationArea = All; }
            }
            group(Booking)
            {
                Caption = 'Booking Value';
                field("Booking Value"; Rec."Booking Value") { ApplicationArea = All; }
                field("Frozen Booking Value"; Rec."Frozen Booking Value") { ApplicationArea = All; }
                field("Last Contract No."; Rec."Last Contract No.") { ApplicationArea = All; }
            }
            group(Asset)
            {
                Caption = 'Fixed Asset';
                field("Fixed Asset No."; Rec."Fixed Asset No.") { ApplicationArea = All; }
                field("Acquisition Date"; Rec."Acquisition Date") { ApplicationArea = All; }
                field("Acquisition Cost"; Rec."Acquisition Cost") { ApplicationArea = All; }
            }
            group(Reservation)
            {
                Caption = 'Reservation';
                field("Soft Reserved by Quote"; Rec."Soft Reserved by Quote") { ApplicationArea = All; }
                field("Reservation Date"; Rec."Reservation Date") { ApplicationArea = All; }
            }
            group(Other)
            {
                Caption = 'Other';
                field("Color Code"; Rec."Color Code") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SoftReserve)
            {
                Caption = 'Soft Reserve';
                ApplicationArea = All;
                Image = Reserve;
                trigger OnAction()
                var
                    BookingMgt: Codeunit "KINTO Booking Value Mgt.";
                begin
                    BookingMgt.SoftReserveVehicle(Rec, '');
                end;
            }
            action(ReleaseReservation)
            {
                Caption = 'Release Reservation';
                ApplicationArea = All;
                Image = Release;
                trigger OnAction()
                var
                    BookingMgt: Codeunit "KINTO Booking Value Mgt.";
                begin
                    BookingMgt.ReleaseReservation(Rec);
                end;
            }
            action(FreezeBookingValue)
            {
                Caption = 'Freeze Booking Value';
                ApplicationArea = All;
                Image = Freeze;
                trigger OnAction()
                var
                    BookingMgt: Codeunit "KINTO Booking Value Mgt.";
                begin
                    BookingMgt.FreezeBookingValue(Rec);
                end;
            }
            action(ViewFixedAsset)
            {
                Caption = 'Ver Ativo Fixo';
                ApplicationArea = All;
                Image = FixedAssets;
                Visible = Rec."Fixed Asset No." <> '';
                trigger OnAction()
                var
                    FixedAsset: Record "Fixed Asset";
                begin
                    if FixedAsset.Get(Rec."Fixed Asset No.") then
                        Page.Run(Page::"Fixed Asset Card", FixedAsset);
                end;
            }
            action(ViewItem)
            {
                Caption = 'Ver Item (Veículo)';
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
            action(ViewVehicleModel)
            {
                Caption = 'Ver Modelo do Veículo';
                ApplicationArea = All;
                Image = ItemLedger;
                Visible = Rec."Vehicle Model No." <> '';
                trigger OnAction()
                var
                    VehicleModel: Record "KINTO Vehicle Model";
                begin
                    if VehicleModel.Get(Rec."Vehicle Model No.") then
                        Page.Run(Page::"KINTO Vehicle Model Card", VehicleModel);
                end;
            }
            action(ViewOdometerHistory)
            {
                Caption = 'Ver Histórico de Odômetro';
                ApplicationArea = All;
                Image = History;
                trigger OnAction()
                var
                    OdometerHist: Record "KINTO Vehicle Odometer History";
                begin
                    OdometerHist.SetRange("Vehicle No.", Rec."Vehicle No.");
                    Page.Run(Page::"KINTO Odometer History List", OdometerHist);
                end;
            }
            action(ViewRVMatrix)
            {
                Caption = 'Ver Matriz RV deste Veículo';
                ApplicationArea = All;
                Image = Matrix;
                Visible = Rec."Item No." <> '';
                trigger OnAction()
                var
                    RVMatrix: Record "KINTO RV Matrix";
                begin
                    RVMatrix.SetRange("Item No.", Rec."Item No.");
                    Page.Run(Page::"KINTO RV Matrix List", RVMatrix);
                end;
            }
            action(ViewQuotesForVehicle)
            {
                Caption = 'Ver Cotações deste Veículo';
                ApplicationArea = All;
                Image = Document;
                trigger OnAction()
                var
                    QuoteItem: Record "KINTO Quote Item";
                    QuoteHeader: Record "KINTO Quote Header";
                begin
                    QuoteItem.SetRange("Inventory Vehicle No.", Rec."Vehicle No.");
                    if QuoteItem.FindFirst() then begin
                        QuoteHeader.SetRange("Quote No.", QuoteItem."Quote No.");
                        Page.Run(Page::"KINTO Quote List", QuoteHeader);
                    end else
                        Message('No quotes found for this vehicle.');
                end;
            }

        }
    }
}