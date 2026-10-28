page 60017 "KINTO SLA Violation Card"
{
    Caption = 'SLA Violation';
    PageType = Card;
    SourceTable = "KINTO SLA Violation";
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;

    // D3 — cartao da violacao de SLA.
    //
    // Por que existe: a lista (60012) nao tinha CardPageId. Sem cartao proprio,
    // o BC procurava uma pagina de cartao para a tabela 60010 "KINTO SLA
    // Violation" e encontrava a pagina 60010 "KINTO Service Level Card" (mesmo
    // numero da tabela, mas de OUTRA tabela). Resultado: ao abrir o registro, o
    // cartao recebia um RecordID de "KINTO Service Level Agreement" junto com um
    // registro de "KINTO SLA Violation" e a pagina quebrava com
    // 'Uma RecordID da tabela ... nao pode ser usada com um registro da tabela ...'.
    //

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Violation Type"; Rec."Violation Type") { ApplicationArea = All; }
                field("Detected DateTime"; Rec."Detected DateTime") { ApplicationArea = All; }
            }
            group(Calculation)
            {
                Caption = 'Calculation';
                field("Hours Elapsed"; Rec."Hours Elapsed") { ApplicationArea = All; }
                field("SLA Target Hours"; Rec."SLA Target Hours") { ApplicationArea = All; }
                field("Penalty Amount"; Rec."Penalty Amount") { ApplicationArea = All; }
                field("Credit Created"; Rec."Credit Created") { ApplicationArea = All; }
            }
            group(NotesGroup)
            {
                Caption = 'Notes';
                field(Notes; Rec.Notes) { ApplicationArea = All; }
            }
        }
    }
}
