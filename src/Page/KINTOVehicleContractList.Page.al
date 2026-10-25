page 50201 "KINTO Vehicle Contract List"
{
    Caption = 'KINTO Vehicle Contracts';
    PageType = List;
    SourceTable = "KINTO Vehicle Contract";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Vehicle Contract Card";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Customer Name"; Rec."Customer Name") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("Current End Date"; Rec."Current End Date") { ApplicationArea = All; }
                field("Total Monthly Fee"; Rec."Total Monthly Fee") { ApplicationArea = All; }
                field("Termination Type"; Rec."Termination Type") { ApplicationArea = All; }
            }
        }
    }
}