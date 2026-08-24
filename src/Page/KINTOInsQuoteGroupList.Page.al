page 50146 "KINTO Ins. Quote Group List"
{
    Caption = 'KINTO Grupos de Cotação de Seguro';
    PageType = List;
    SourceTable = "KINTO Insurance Quote Group";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Ins. Quote Group Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Group ID"; Rec."Group ID") { ApplicationArea = All; }
                field("Group Code"; Rec."Group Code") { ApplicationArea = All; }
                field("Insurer Name"; Rec."Insurer Name") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Risk Level"; Rec."Risk Level") { ApplicationArea = All; }
                field("Armoring"; Rec.Armoring) { ApplicationArea = All; }
                field("Deductible %"; Rec."Deductible %") { ApplicationArea = All; }
                field("Restricted Customer Level"; Rec."Restricted Customer Level") { ApplicationArea = All; }
                field("Validity Date"; Rec."Validity Date") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}
