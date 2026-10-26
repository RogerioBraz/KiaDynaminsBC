page 50452 "KINTO Telematic Device List"
{
    Caption = 'Telematic Devices';
    PageType = List;
    SourceTable = "KINTO Telematic Device";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Telematic Device";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Device No."; Rec."Device No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Serial Number"; Rec."Serial Number") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Installed Vehicle No."; Rec."Installed Vehicle No.") { ApplicationArea = All; }
                field("Install Date"; Rec."Install Date") { ApplicationArea = All; }
                field("Install Count"; Rec."Install Count") { ApplicationArea = All; }
                field("Aging Days"; Rec."Aging Days") { ApplicationArea = All; }
                field("Aging Charge Vendor"; Rec."Aging Charge Vendor") { ApplicationArea = All; Style = Attention; }
                field("Paid Plan Code"; Rec."Paid Plan Code") { ApplicationArea = All; }
            }
        }
    }
}
