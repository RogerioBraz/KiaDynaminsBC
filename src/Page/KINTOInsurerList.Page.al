page 50144 "KINTO Insurer List"
{
    Caption = 'KINTO Seguradoras';
    PageType = List;
    SourceTable = "KINTO Insurer";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Insurer Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Insurer ID"; Rec."Insurer ID") { ApplicationArea = All; }
                field("Insurer Code"; Rec."Insurer Code") { ApplicationArea = All; }
                field("Legal Name"; Rec."Legal Name") { ApplicationArea = All; }
                field("Trade Name"; Rec."Trade Name") { ApplicationArea = All; }
                field("CNPJ"; Rec."CNPJ") { ApplicationArea = All; }
                field("Active"; Rec.Active) { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InsuranceQuoteGroups)
            {
                Caption = 'Grupos de Cotação';
                ApplicationArea = All;
                Image = ItemGroups;
                trigger OnAction()
                var
                    InsGroup: Record "KINTO Insurance Quote Group";
                begin
                    InsGroup.SetRange("Insurer ID", Rec."Insurer ID");
                    Page.Run(Page::"KINTO Ins. Quote Group List", InsGroup);
                end;
            }
            action(InsuranceQuotes)
            {
                Caption = 'Cotações de Seguro';
                ApplicationArea = All;
                Image = Insurance;
                trigger OnAction()
                var
                    InsQuote: Record "KINTO Insurance Quote";
                begin
                    InsQuote.SetRange("Insurer ID", Rec."Insurer ID");
                    Page.Run(Page::"KINTO Insurance Quote List", InsQuote);
                end;
            }
        }
    }
}

page 50145 "KINTO Insurer Card"
{
    Caption = 'KINTO Seguradora';
    PageType = Card;
    SourceTable = "KINTO Insurer";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Informações Gerais';

                field("Insurer ID"; Rec."Insurer ID") { ApplicationArea = All; Editable = false; }
                field("Insurer Code"; Rec."Insurer Code") { ApplicationArea = All; }
                field("Legal Name"; Rec."Legal Name") { ApplicationArea = All; }
                field("Trade Name"; Rec."Trade Name") { ApplicationArea = All; }
                field("CNPJ"; Rec."CNPJ") { ApplicationArea = All; }
                field("Active"; Rec.Active) { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
            }
            group(Contact)
            {
                Caption = 'Contato';

                field("Contact Name"; Rec."Contact Name") { ApplicationArea = All; }
                field("Contact Phone"; Rec."Contact Phone") { ApplicationArea = All; }
                field("Contact Email"; Rec."Contact Email") { ApplicationArea = All; }
            }
            group(Audit)
            {
                Caption = 'Auditoria';

                field("Created Date"; Rec."Created Date") { ApplicationArea = All; Editable = false; }
                field("Modified Date"; Rec."Modified Date") { ApplicationArea = All; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InsuranceQuoteGroups)
            {
                Caption = 'Grupos de Cotação';
                ApplicationArea = All;
                Image = ItemGroups;
                trigger OnAction()
                var
                    InsGroup: Record "KINTO Insurance Quote Group";
                begin
                    InsGroup.SetRange("Insurer ID", Rec."Insurer ID");
                    Page.Run(Page::"KINTO Ins. Quote Group List", InsGroup);
                end;
            }
            action(InsuranceQuotes)
            {
                Caption = 'Cotações de Seguro';
                ApplicationArea = All;
                Image = Insurance;
                trigger OnAction()
                var
                    InsQuote: Record "KINTO Insurance Quote";
                begin
                    InsQuote.SetRange("Insurer ID", Rec."Insurer ID");
                    Page.Run(Page::"KINTO Insurance Quote List", InsQuote);
                end;
            }
        }
    }
}