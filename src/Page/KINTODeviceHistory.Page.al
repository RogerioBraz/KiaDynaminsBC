page 50453 "KINTO Device History"
{
    Caption = 'Device History';
    PageType = List;
    SourceTable = "KINTO Device History";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Device No."; Rec."Device No.") { ApplicationArea = All; }
                field(Events; Rec.Events) { ApplicationArea = All; }
                field("Event Date"; Rec."Event Date") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Duration Days"; Rec."Duration Days") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}
