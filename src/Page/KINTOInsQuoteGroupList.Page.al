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

page 50147 "KINTO Ins. Quote Group Card"
{
    Caption = 'KINTO Grupo de Cotação de Seguro';
    PageType = Card;
    SourceTable = "KINTO Insurance Quote Group";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Informações Gerais';

                field("Group ID"; Rec."Group ID") { ApplicationArea = All; Editable = false; }
                field("Group Code"; Rec."Group Code") { ApplicationArea = All; }
                field("Insurer ID"; Rec."Insurer ID") { ApplicationArea = All; }
                field("Insurer Name"; Rec."Insurer Name") { ApplicationArea = All; Editable = false; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Risk Level"; Rec."Risk Level") { ApplicationArea = All; }
                field("Restricted Customer Level"; Rec."Restricted Customer Level") { ApplicationArea = All; }
                field("Armoring"; Rec.Armoring) { ApplicationArea = All; }
                field("Deductible %"; Rec."Deductible %") { ApplicationArea = All; }
                field("Validity Date"; Rec."Validity Date") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
            }
            group(Audit)
            {
                Caption = 'Auditoria';

                field("Registration Date"; Rec."Registration Date") { ApplicationArea = All; Editable = false; }
                field("Created By"; Rec."Created By") { ApplicationArea = All; Editable = false; }
                field("Created Date"; Rec."Created Date") { ApplicationArea = All; Editable = false; }
                field("Modified Date"; Rec."Modified Date") { ApplicationArea = All; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InsuranceQuotes)
            {
                Caption = 'Cotações deste Grupo';
                ApplicationArea = All;
                Image = Insurance;
                trigger OnAction()
                var
                    InsQuote: Record "KINTO Insurance Quote";
                begin
                    InsQuote.SetRange("Quote Group ID", Rec."Group ID");
                    Page.Run(Page::"KINTO Insurance Quote List", InsQuote);
                end;
            }
        }
    }
}