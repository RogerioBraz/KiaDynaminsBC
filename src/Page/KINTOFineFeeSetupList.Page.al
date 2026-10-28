page 60021 "KINTO Fine Fee Setup List"
{
    Caption = 'Fine Fee Setup';
    PageType = List;
    SourceTable = "KINTO Fine Fee Setup";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = true;
    CardPageId = "KINTO Fine Fee Setup Card";

    // ============================================================
    // PAGINA NOVA (1.2.0.6).
    //
    // POR QUE EXISTE: a tabela "KINTO Fine Fee Setup" guarda o valor de cada
    // tipo de taxa de multa (base para calcular o que se cobra do cliente) e
    // nao tinha NENHUMA pagina. Pior: o LookupPageId/DrillDownPageId da tabela
    // apontava para "KINTO Issuing Authority List", que e de OUTRA tabela —
    // mesmo defeito que quebrou a pagina 60012. Sem tela, o setup de multas so
    // existia via seed: nao havia como manter.
    // ============================================================

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Fee Type"; Rec."Fee Type") { ApplicationArea = All; }
                field("Financial Product Code"; Rec."Financial Product Code") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
            }
        }
    }
}
