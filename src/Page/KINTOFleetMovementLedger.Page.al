page 50450 "KINTO Fleet Movement Ledger"
{
    Caption = 'Fleet Movement Ledger';
    PageType = List;
    SourceTable = "KINTO Fleet Movement Ledger";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Movement Type"; Rec."Movement Type") { ApplicationArea = All; }
                field("From Status"; Rec."From Status") { ApplicationArea = All; }
                field("To Status"; Rec."To Status") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field(VIN; Rec.VIN) { ApplicationArea = All; }
                field("Odometer"; Rec."Odometer") { ApplicationArea = All; }
                field("SLA Due Date"; Rec."SLA Due Date") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
            }
        }
    }
}
