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
                field(Armoring; Rec.Armoring) { ApplicationArea = All; }
                field("Deductible %"; Rec."Deductible %") { ApplicationArea = All; }
                field("Validity Date"; Rec."Validity Date") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
            }
            group(InsuranceParams)
            {
                Caption = 'Parâmetros de Seguro';

                field("Deductible Type"; Rec."Deductible Type") { ApplicationArea = All; }
                field("Deductible Value"; Rec."Deductible Value") { ApplicationArea = All; }
                field("Insurance Loading %"; Rec."Insurance Loading %") { ApplicationArea = All; }
                field("Vehicle Value Basis"; Rec."Vehicle Value Basis") { ApplicationArea = All; }
            }
            group(Audit)
            {
                Caption = 'Auditoria';

                field("Registration Date"; Rec."Registration Date") { ApplicationArea = All; Editable = false; }
                field("Created By"; Rec."Created By") { ApplicationArea = All; Editable = false; }
                field("Created Date"; Rec."Created Date") { ApplicationArea = All; Editable = false; }
                field("Modified Date"; Rec."Modified Date") { ApplicationArea = All; Editable = false; }
            }

            // CORREÇÃO: Subform de Coverage Limits anexado ao Group Card
            group(CoverageLimits)
            {
                Caption = 'Limites de Cobertura (Pricing)';

                part(CoverageLimitSubform; "KINTO Ins Coverage Limit Sub")
                {
                    ApplicationArea = All;
                    SubPageLink = "Insurance Package ID" = field("Group ID");
                }
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