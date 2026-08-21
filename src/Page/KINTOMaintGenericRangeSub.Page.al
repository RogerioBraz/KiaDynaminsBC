page 50153 "KINTO Maint Generic Range Sub"
{
    Caption = 'Generic Range (Corrective)';
    PageType = ListPart;
    SourceTable = "KINTO Mainten Generic Range";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(GenericItems)
            {
                field("Item/Service Name"; Rec."Item/Service Name") { ApplicationArea = All; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field("Part Number"; Rec."Part Number") { ApplicationArea = All; }
                field("Total Cost"; Rec."Total Cost") { ApplicationArea = All; Editable = false; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}