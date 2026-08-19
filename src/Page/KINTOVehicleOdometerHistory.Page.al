page 50132 "KINTO Odometer History List"
{
    Caption = 'KINTO Vehicle Odometer History';
    PageType = List;
    SourceTable = "KINTO Vehicle Odometer History";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Reading Date"; Rec."Reading Date") { ApplicationArea = All; }
                field("Odometer Reading"; Rec."Odometer Reading") { ApplicationArea = All; }
                field("Source"; Rec."Source") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
            }
        }
    }
}