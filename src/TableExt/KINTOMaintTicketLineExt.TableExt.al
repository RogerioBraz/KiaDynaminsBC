tableextension 60001 "KINTO Maint Ticket Line Ext" extends "KINTO Maint Ticket Line"
{
    fields
    {
        field(60000; "Line Type"; Enum "KINTO Maint Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
            InitValue = "Part";
        }
        field(60001; "Service Type"; Enum "KINTO Maint Service Type")
        {
            Caption = 'Service Type';
            DataClassification = CustomerContent;
        }
        field(60002; "Hours"; Decimal)
        {
            Caption = 'Hours';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(60003; "HH Rate"; Decimal)
        {
            Caption = 'HH Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            // preenchida pela tabela de taxas do fornecedor, nao digitada
            Editable = false;
        }
        field(60004; "Minimum Hours Applied"; Boolean)
        {
            Caption = 'Minimum Billable Hours Applied';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // Horas FATURADAS = max(horas trabalhadas, minimo do fornecedor).
        // Fica em campo proprio para NAO destruir o registro do que realmente
        // aconteceu: 'Hours' continua sendo o que o tecnico executou, e este
        // campo e o que se cobra. Sem essa separacao, aplicar o minimo de 8h
        // sobre uma execucao de 2h apagava as 2h do historico.
        field(60005; "Billable Hours"; Decimal)
        {
            Caption = 'Billable Hours';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
    }

    // Mao de obra: valor = horas x taxa HH.
    // A taxa NAO deve ser digitada: vem da KINTO Vendor Labor Rate vigente para
    // o fornecedor do ticket, o tipo de servico da linha e a data do servico.
    // Quando a execucao fica abaixo do minimo faturavel do fornecedor, as horas
    // sobem para o minimo (pratica de oficina) e a linha e marcada.
    //
    // Devolve true quando alguma taxa foi aplicada (a linha mudou).
    procedure ApplyLaborRate(VendorNo: Code[20]; ServiceDate: Date): Boolean
    var
        LaborRate: Record "KINTO Vendor Labor Rate";
    begin
        if Rec."Line Type" <> Rec."Line Type"::Labor then
            exit(false);
        if Rec."Hours" <= 0 then
            exit(false);
        if VendorNo = '' then
            exit(false);

        if not LaborRate.FindRate(VendorNo, Rec."Service Type", ServiceDate) then
            exit(false);

        Rec."HH Rate" := LaborRate."HH Rate";

        // Horas faturadas = max(horas trabalhadas, minimo do fornecedor).
        // 'Hours' NAO e alterado: preserva o que foi executado de fato.
        Rec."Billable Hours" := Rec."Hours";
        Rec."Minimum Hours Applied" := false;
        if (LaborRate."Minimum Hours" > 0) and (Rec."Hours" < LaborRate."Minimum Hours") then begin
            Rec."Billable Hours" := LaborRate."Minimum Hours";
            Rec."Minimum Hours Applied" := true;
        end;

        // valor da mao de obra = horas faturadas x taxa
        Rec.Quantity := Rec."Billable Hours";
        Rec."Unit Cost" := Rec."HH Rate";
        exit(true);
    end;

    // Mantido para compatibilidade: aplica usando a taxa JA preenchida na linha,
    // sem consultar a tabela de taxas (usado quando a data/fornecedor nao estao
    // disponiveis, ex.: reprocessamento de linha antiga).
    procedure ApplyLaborRate()
    begin
        Rec.ApplyLaborRate('', 0D);
        if (Rec."Line Type" = Rec."Line Type"::Labor) and (Rec."Hours" <> 0) and (Rec."HH Rate" <> 0) then begin
            Rec.Quantity := Rec."Hours";
            Rec."Unit Cost" := Rec."HH Rate";
        end;
    end;

    // Minimo faturavel aplicado nesta linha? (para o usuario entender por que o
    // valor cobrado nao bate com as horas que ele lancou)
    procedure HasMinimumApplied(): Boolean
    begin
        exit(Rec."Minimum Hours Applied");
    end;
}
