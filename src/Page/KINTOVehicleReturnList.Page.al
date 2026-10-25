page 50401 "KINTO Vehicle Return List"
{
    Caption = 'KINTO Vehicle Returns';
    PageType = List;
    SourceTable = "KINTO Vehicle Return";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Vehicle Return Card";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Return No."; Rec."Return No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Return Date"; Rec."Return Date") { ApplicationArea = All; }
                field("Odometer at Return"; Rec."Odometer at Return") { ApplicationArea = All; }
                field("Total Damage Amount"; Rec."Total Damage Amount") { ApplicationArea = All; }
                field("Customer Damage Amount"; Rec."Customer Damage Amount") { ApplicationArea = All; }
                field("Pending Items"; Rec."Pending Items") { ApplicationArea = All; }
            }
        }
    }
}