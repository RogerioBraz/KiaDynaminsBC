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
        }
    }
}