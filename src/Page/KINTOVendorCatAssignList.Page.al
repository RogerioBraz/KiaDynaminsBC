page 50166 "KINTO Vendor Cat Assign List"
{
    Caption = 'Categorias do Fornecedor';
    PageType = ListPart;
    SourceTable = "KINTO Vendor Category Assign";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec."Category Code") { ApplicationArea = All; }
                field("Category Description"; Rec."Category Description") { ApplicationArea = All; Editable = false; }
                field("Is Primary"; Rec."Is Primary") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddCategory)
            {
                Caption = 'Adicionar Categoria';
                ApplicationArea = All;
                Image = New;
                trigger OnAction()
                var
                    VendorCat: Record "KINTO Vendor Category";
                begin
                    Page.RunModal(Page::"KINTO Vendor Category List", VendorCat);
                end;
            }
        }
    }
}