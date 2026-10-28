page 60022 "KINTO Fine Fee Setup Card"
{
    Caption = 'Fine Fee Setup';
    PageType = Card;
    SourceTable = "KINTO Fine Fee Setup";
    UsageCategory = None;
    ApplicationArea = All;
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;

    // Cartao da configuracao de valor por tipo de taxa de multa. Par da lista
    // 60021 — sem ele a lista nao abriria o registro (mesma licao da 60012).

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Fee Type"; Rec."Fee Type") { ApplicationArea = All; }
            }
            group(Charge)
            {
                Caption = 'Charge';
                field("Financial Product Code"; Rec."Financial Product Code") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
            }
        }
    }
}
