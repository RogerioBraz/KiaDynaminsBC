pageextension 50107 "KINTO Vendor List Ext" extends "Vendor List"
{
    layout
    {
        addafter("Payments (LCY)")
        {
            // CORREÇÃO: Usa FlowField "KINTO Is Dealer" em vez do campo removido "KINTO Dealer"
            field("KINTO Is Dealer"; Rec."KINTO Is Dealer")
            {
                ApplicationArea = All;
                Caption = 'KINTO Dealer';
            }
            field("KINTO Default DLR Sales Comm %"; Rec."KINTO Default DLR Sales Comm %")
            {
                ApplicationArea = All;
            }
            // CORREÇÃO: Usa FlowField "KINTO Has Portal Access" em vez do campo removido "KINTO Dealer Portal Access"
            field("KINTO Has Portal Access"; Rec."KINTO Has Portal Access")
            {
                ApplicationArea = All;
                Caption = 'Dealer Portal Access';
            }
            field("KINTO VD Sales Commission %"; Rec."KINTO VD Sales Commission %")
            {
                ApplicationArea = All;
            }
            field("KINTO VD Delivery Commission %"; Rec."KINTO VD Delivery Commission %")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addfirst(processing)
        {
            action(KINTOFilterDealers)
            {
                Caption = 'Filter KINTO Dealers';
                ApplicationArea = All;
                Image = Filter;
                trigger OnAction()
                begin
                    // CORREÇÃO: Filtra pelo FlowField que verifica a categoria DEALER
                    Rec.SetRange("KINTO Is Dealer", true);
                end;
            }
            action(KINTOClearDealerFilter)
            {
                Caption = 'Clear KINTO Filter';
                ApplicationArea = All;
                Image = ClearFilter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Is Dealer");
                end;
            }
            action(KINTOFilterPortalAccess)
            {
                Caption = 'Filter Portal Access';
                ApplicationArea = All;
                Image = Filter;
                trigger OnAction()
                begin
                    Rec.SetRange("KINTO Has Portal Access", true);
                end;
            }
            action(KINTOViewContacts)
            {
                Caption = 'Contacts (Portal)';
                ApplicationArea = All;
                Image = ContactPerson;
                trigger OnAction()
                var
                    VendorContact: Record "KINTO Vendor Contact";
                begin
                    VendorContact.SetRange("Vendor No.", Rec."No.");
                    Page.Run(Page::"KINTO Vendor Contact List", VendorContact);
                end;
            }
            action(KINTOViewCategories)
            {
                Caption = 'Categories';
                ApplicationArea = All;
                Image = Category;
                trigger OnAction()
                var
                    VendorCatAssign: Record "KINTO Vendor Category Assign";
                begin
                    VendorCatAssign.SetRange("Vendor No.", Rec."No.");
                    Page.Run(Page::"KINTO Vendor Cat Assign List", VendorCatAssign);
                end;
            }
        }
    }
}