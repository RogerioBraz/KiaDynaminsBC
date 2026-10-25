page 50404 "KINTO Recovery Case List"
{
    Caption = 'KINTO Recovery Cases';
    PageType = List;
    SourceTable = "KINTO Recovery Case";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Recovery Case Card";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Case No."; Rec."Case No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Case Date"; Rec."Case Date") { ApplicationArea = All; }
                field("Aging Days"; Rec."Aging Days") { ApplicationArea = All; }
                field("Risk Level"; Rec."Risk Level") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}