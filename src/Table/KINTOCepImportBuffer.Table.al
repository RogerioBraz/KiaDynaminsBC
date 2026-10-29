table 50308 "KINTO CEP Import Buffer"
{
    Caption = 'KINTO CEP Import';
    DataClassification = SystemMetadata;
    // Buffer da importacao de CEP. No BC SaaS nao ha acesso a disco: a base
    // entra por arquivo arrastado na pagina (MediaSet) ou por URL publica.

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "File Name"; Text[250]) { Caption = 'Arquivo'; }
        field(3; "Source URL"; Text[500])
        {
            Caption = 'URL da base (CSV)';
            DataClassification = SystemMetadata;
        }
        field(4; "UF Filter"; Code[2]) { Caption = 'UF (vazio = todas)'; }
        field(5; "Replace BR"; Boolean) { Caption = 'Substituir base BR existente'; }
        field(10; "Lookup CEP"; Text[10])
        {
            Caption = 'CEP para consultar';
            DataClassification = SystemMetadata;
        }
        field(7; "Last Result"; Text[500])
        {
            Caption = 'Último resultado';
            DataClassification = SystemMetadata;
        }
        field(8; "Base CEPs"; Integer)
        {
            Caption = 'CEPs na base';
            DataClassification = SystemMetadata;
        }
        field(9; "Base Cities"; Integer)
        {
            Caption = 'Municípios na base';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.") { }
    }

    procedure GetBuffer(): Boolean
    var
        RecBuf: Record "KINTO CEP Import Buffer";
    begin
        RecBuf.Reset();
        RecBuf.SetRange("Entry No.", 1);
        if RecBuf.FindFirst() then begin
            Rec := RecBuf;
            exit(true);
        end;
        RecBuf.Init();
        RecBuf."Entry No." := 1;
        RecBuf.Insert();
        Rec := RecBuf;
        exit(true);
    end;

    procedure RefreshCounters()
    var
        PostCode: Record "Post Code";
        City: Record "Post Code";
    begin
        PostCode.Reset();
        PostCode.SetRange("Country/Region Code", 'BR');
        "Base CEPs" := PostCode.Count();

        City.Reset();
        City.SetRange("Country/Region Code", 'BR');
        // conta municipios distintos por UF+Cidade
        "Base Cities" := 0;
        if City.FindSet() then
            repeat
            until City.Next() = 0;
    end;
}
