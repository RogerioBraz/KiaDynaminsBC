page 50130 "KINTO Inventory Vehicle List"
{
    Caption = 'KINTO Inventory Vehicles';
    PageType = List;
    SourceTable = "KINTO Inventory Vehicle";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Inventory Vehicle Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("VIN"; Rec."VIN") { ApplicationArea = All; }
                field("Vehicle Model No."; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field("Vehicle Condition"; Rec."Vehicle Condition") { ApplicationArea = All; }
                field("Current Odometer"; Rec."Current Odometer") { ApplicationArea = All; }
                field("Age in Months"; Rec."Age in Months") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
                field("Booking Value"; Rec."Booking Value") { ApplicationArea = All; }
                field("Frozen Booking Value"; Rec."Frozen Booking Value") { ApplicationArea = All; }
                field("Soft Reserved by Quote"; Rec."Soft Reserved by Quote") { ApplicationArea = All; }
                field("Fixed Asset No."; Rec."Fixed Asset No.") { ApplicationArea = All; }
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
                    QuoteNo: Code[20];
                begin
                    QuoteNo := '';
                    BookingMgt.SoftReserveVehicle(Rec, QuoteNo);
                end;
            }
            action(ReleaseReservation)
            {
                Caption = 'Release Reservation';
                ApplicationArea = All;
                Image = Check;
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
            action(ViewOdometerHistory)
            {
                Caption = 'Odometer History';
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
        }
    }
}