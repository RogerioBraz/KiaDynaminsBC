page 50152 "KINTO Maint Number Subform"
{
    Caption = 'Maintenance Items/Services';
    PageType = ListPart;
    SourceTable = "KINTO Maintenance Number";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Item/Service Name"; Rec."Item/Service Name") { ApplicationArea = All; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field("Part Number"; Rec."Part Number") { ApplicationArea = All; }
                field("Total Cost"; Rec."Total Cost") { ApplicationArea = All; Editable = false; }
            }
        }
    }
}