page 50163 "KINTO Vendor Contact List"
{
    Caption = 'KINTO Vendor Contacts (Portal)';
    PageType = List;
    SourceTable = "KINTO Vendor Contact";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Contact Name"; Rec."Contact Name") { ApplicationArea = All; }
                field("Contact Email"; Rec."Contact Email") { ApplicationArea = All; }
                field("Contact Phone"; Rec."Contact Phone") { ApplicationArea = All; }
                field("Dealer Portal Access"; Rec."Dealer Portal Access") { ApplicationArea = All; }
                field("Portal User ID"; Rec."Portal User ID") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}
