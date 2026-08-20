tableextension 50105 "KINTO Quote Item Ins Ext" extends "KINTO Quote Item"
{
    fields
    {
        field(50100; "Insurance Quote No."; Code[20])
        {
            Caption = 'Insurance Quote No.';
            TableRelation = "KINTO Insurance Quote";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InsQuote: Record "KINTO Insurance Quote";
                InsQuoteGroup: Record "KINTO Insurance Quote Group";
            begin
                if Rec."Insurance Quote No." = '' then exit;
                if not InsQuote.Get(Rec."Insurance Quote No.") then
                    Error('Cotação de seguro %1 não encontrada.', Rec."Insurance Quote No.");

                // Sincroniza dados do seguro no Quote Item
                Rec."Body Insurance" := InsQuote."Insurance Value";

                // Valida blindagem
                if InsQuote.Armoring then begin
                    if InsQuote."Quote Group ID" <> 0 then begin
                        InsQuoteGroup.Get(InsQuote."Quote Group ID");
                        if not InsQuoteGroup.Armoring then
                            Error('Veículo blindado selecionado, mas o grupo de seguro %1 não permite blindagem.', InsQuoteGroup.Name);
                    end;
                end;

                // Valida validade da cotação de seguro
                if InsQuote."Quote Validity Date" < Today then
                    Error('A cotação de seguro %1 está expirada (validade: %2).', Rec."Insurance Quote No.", InsQuote."Quote Validity Date");

                // Marca vínculo na cotação de seguro
                InsQuote."KINTO Quote No." := Rec."Quote No.";
                InsQuote."KINTO Quote Line No." := Rec."Line No.";
                InsQuote.Modify(true);
            end;
        }
        field(50101; "Insurance Hull Value"; Decimal)
        {
            Caption = 'Insurance Hull Value';
            DataClassification = CustomerContent;
        }
        field(50102; "Insurance Premium"; Decimal)
        {
            Caption = 'Insurance Premium (Faixa Prêmio)';
            DataClassification = CustomerContent;
        }
    }
}