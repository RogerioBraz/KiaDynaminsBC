page 50214 "KINTO Maintenance Ticket List"
{
    Caption = 'KINTO Maintenance Tickets';
    PageType = List;
    SourceTable = "KINTO Maintenance Ticket";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Maintenance Ticket Card";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field("Ticket Type"; Rec."Ticket Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Service Date"; Rec."Service Date") { ApplicationArea = All; }
                field("Odometer at Service"; Rec."Odometer at Service") { ApplicationArea = All; }
                field("Total Cost"; Rec."Total Cost") { ApplicationArea = All; }
                field("Total Billable"; Rec."Total Billable") { ApplicationArea = All; }
            }
        }
    }
}