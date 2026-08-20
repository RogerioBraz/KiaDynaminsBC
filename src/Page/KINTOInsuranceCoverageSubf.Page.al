page 50150 "KINTO Insurance Coverage Subf"
{
    Caption = 'Coberturas';
    PageType = ListPart;
    SourceTable = "KINTO Insurance Coverage";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Premium Range"; Rec."Premium Range") { ApplicationArea = All; }
                field("Property Damage"; Rec."Property Damage") { ApplicationArea = All; }
                field("Moral Damages"; Rec."Moral Damages") { ApplicationArea = All; }
                field("Bodily Injury"; Rec."Bodily Injury") { ApplicationArea = All; }
                field("APP Death"; Rec."APP Death") { ApplicationArea = All; }
                field("APP Disability"; Rec."APP Disability") { ApplicationArea = All; }
                field("Registration Date"; Rec."Registration Date") { ApplicationArea = All; Editable = false; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}