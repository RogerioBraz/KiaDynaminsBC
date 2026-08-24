pageextension 50109 "KINTO Vendor Card Pkg Ext" extends "Vendor Card"
{
    layout
    {
        addafter(General)
        {

            group(KINTOCategories)
            {
                Caption = 'KINTO Categorias';

                part(VendorCategories; "KINTO Vendor Cat Assign List")
                {
                    ApplicationArea = All;
                    SubPageLink = "Vendor No." = field("No.");
                }
            }
            group(KINTOContacts)
            {
                Caption = 'KINTO Contatos (Portal)';

                part(VendorContacts; "KINTO Vendor Contact Listpart")
                {
                    ApplicationArea = All;
                    SubPageLink = "Vendor No." = field("No.");
                }
            }
        }
        addafter(KINTOContacts)
        {
            field("KINTO VD Sales Comm %"; Rec."KINTO VD Sales Commission %") { ApplicationArea = All; Visible = IsDealer; }
            field("KINTO VD Delivery Comm %"; Rec."KINTO VD Delivery Commission %") { ApplicationArea = All; Visible = IsDealer; }
            field("KINTO Default DLR Sales Comm %"; Rec."KINTO Default DLR Sales Comm %") { ApplicationArea = All; Visible = IsDealer; }
            field("KINTO Default DLR Delivery Comm %"; Rec."KINTO Default DLR Delivery Comm %") { ApplicationArea = All; Visible = IsDealer; }
            field("KINTO Max Sales Commission %"; Rec."KINTO Max Sales Commission %") { ApplicationArea = All; Visible = IsDealer; }
            field("KINTO Max Delivery Commission %"; Rec."KINTO Max Delivery Commission %") { ApplicationArea = All; Visible = IsDealer; }


        }
    }
    actions
    {
        addfirst(processing)
        {
            action(AddDealerCategory)
            {
                Caption = 'Marcar como Dealer';
                ApplicationArea = All;
                Image = AddAction;
                trigger OnAction()
                var
                    VendorCatAssign: Record "KINTO Vendor Category Assign";
                begin
                    if not VendorCatAssign.Get(Rec."No.", 'DEALER') then begin
                        VendorCatAssign.Init();
                        VendorCatAssign."Vendor No." := Rec."No.";
                        VendorCatAssign."Category Code" := 'DEALER';
                        VendorCatAssign."Is Primary" := true;
                        VendorCatAssign.Insert(true);
                        Message('Fornecedor marcado como Dealer.');
                    end;
                end;
            }
        }
    }

    var
        IsDealer: Boolean;

    trigger OnAfterGetRecord()
    var
        VendorCatAssign: Record "KINTO Vendor Category Assign";
    begin
        IsDealer := VendorCatAssign.Get(Rec."No.", 'DEALER');
    end;

    trigger OnOpenPage()
    var
        VendorCatAssign: Record "KINTO Vendor Category Assign";
    begin
        IsDealer := VendorCatAssign.Get(Rec."No.", 'DEALER');
    end;
}