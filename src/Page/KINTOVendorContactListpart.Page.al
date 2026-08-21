page 50167 "KINTO Vendor Contact Listpart"
{
    Caption = 'Contatos do Fornecedor';
    PageType = ListPart;
    SourceTable = "KINTO Vendor Contact";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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