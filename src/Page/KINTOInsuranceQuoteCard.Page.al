page 50148 "KINTO Insurance Quote Card"
{
    Caption = 'KINTO Cotação de Seguro';
    PageType = Card;
    SourceTable = "KINTO Insurance Quote";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Informações Gerais';

                field("Insurance Quote No."; Rec."Insurance Quote No.") { ApplicationArea = All; }
                field("Insurer ID"; Rec."Insurer ID") { ApplicationArea = All; }
                field("Insurer Name"; Rec."Insurer Name") { ApplicationArea = All; Editable = false; }
                field("Quote Group ID"; Rec."Quote Group ID") { ApplicationArea = All; }
                field("Group Name"; Rec."Group Name") { ApplicationArea = All; Editable = false; }
                field("Quote Validity Date"; Rec."Quote Validity Date") { ApplicationArea = All; }
                field("Active"; Rec.Active) { ApplicationArea = All; }
            }
            group(VehicleData)
            {
                Caption = 'Dados do Veículo';

                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Vehicle Name"; Rec."Vehicle Name") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Vehicle Model No."; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field("Manufacturer Code"; Rec."Manufacturer Code") { ApplicationArea = All; }
                field("Manufacturer Name"; Rec."Manufacturer Name") { ApplicationArea = All; }
                field("Manufacturer Part Code"; Rec."Manufacturer Part Code") { ApplicationArea = All; }
                field("FIPE Code"; Rec."FIPE Code") { ApplicationArea = All; }
                field(Armoring; Rec.Armoring) { ApplicationArea = All; }
            }
            group(Financial)
            {
                Caption = 'Valores Financeiros';

                field("Hull Value"; Rec."Hull Value") { ApplicationArea = All; }
                field("Deductible Value"; Rec."Deductible Value") { ApplicationArea = All; }
                field("FIPE %"; Rec."FIPE %") { ApplicationArea = All; }
                field("Insurance %"; Rec."Insurance %") { ApplicationArea = All; }
                field("Insurance Value"; Rec."Insurance Value") { ApplicationArea = All; Editable = false; }
                field("Premium Range"; Rec."Premium Range") { ApplicationArea = All; }
            }
            group(Integration)
            {
                Caption = 'Integração KINTO';

                field("KINTO Quote No."; Rec."KINTO Quote No.") { ApplicationArea = All; Editable = false; }
                field("KINTO Quote Line No."; Rec."KINTO Quote Line No.") { ApplicationArea = All; Editable = false; }
            }
            group(Coverages)
            {
                Caption = 'Coberturas';

                part(CoverageSubform; "KINTO Insurance Coverage Subf")
                {
                    ApplicationArea = All;
                    SubPageLink = "Insurance Quote No." = field("Insurance Quote No.");
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateInsuranceValue)
            {
                Caption = 'Calcular Valor do Seguro';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                begin
                    Rec."Insurance Value" := Rec.CalculateInsuranceValue();
                    Rec.Modify(true);
                    Message('Valor do Seguro calculado: %1', Rec."Insurance Value");
                end;
            }
            action(ViewKINTOQuote)
            {
                Caption = 'Ver Cotação KINTO';
                ApplicationArea = All;
                Image = Document;
                Visible = Rec."KINTO Quote No." <> '';
                trigger OnAction()
                var
                    QuoteHeader: Record "KINTO Quote Header";
                begin
                    if QuoteHeader.Get(Rec."KINTO Quote No.") then
                        Page.Run(Page::"KINTO Quote Card", QuoteHeader);
                end;
            }
            action(ViewInsurer)
            {
                Caption = 'Ver Seguradora';
                ApplicationArea = All;
                Image = Vendor;
                trigger OnAction()
                var
                    Insurer: Record "KINTO Insurer";
                begin
                    if Insurer.Get(Rec."Insurer ID") then
                        Page.Run(Page::"KINTO Insurer Card", Insurer);
                end;
            }
            action(ViewQuoteGroup)
            {
                Caption = 'Ver Grupo de Cotação';
                ApplicationArea = All;
                Image = Group;
                trigger OnAction()
                var
                    InsGroup: Record "KINTO Insurance Quote Group";
                begin
                    if InsGroup.Get(Rec."Quote Group ID") then
                        Page.Run(Page::"KINTO Ins. Quote Group Card", InsGroup);
                end;
            }
        }
    }
}

page 50149 "KINTO Insurance Quote List"
{
    Caption = 'KINTO Cotações de Seguro';
    PageType = List;
    SourceTable = "KINTO Insurance Quote";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Insurance Quote Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Insurance Quote No."; Rec."Insurance Quote No.") { ApplicationArea = All; }
                field("Insurer Name"; Rec."Insurer Name") { ApplicationArea = All; }
                field("Group Name"; Rec."Group Name") { ApplicationArea = All; }
                field("Vehicle Name"; Rec."Vehicle Name") { ApplicationArea = All; }
                field("Hull Value"; Rec."Hull Value") { ApplicationArea = All; }
                field("Insurance Value"; Rec."Insurance Value") { ApplicationArea = All; }
                field("Quote Validity Date"; Rec."Quote Validity Date") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("KINTO Quote No."; Rec."KINTO Quote No.") { ApplicationArea = All; }
            }
        }
    }
}