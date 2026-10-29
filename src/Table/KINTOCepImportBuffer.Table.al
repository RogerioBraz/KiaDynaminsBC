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
        field(3; "CSV Blob"; Blob)
        {
            Caption = 'Arquivo CSV';
            DataClassification = SystemMetadata;
        }
        field(12; "Source URL"; Text[500])
        {
            Caption = 'URL da base completa';
            DataClassification = SystemMetadata;
        }
        field(13; "Last Url Used"; Text[500])
        {
            Caption = 'Última URL carregada';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Load Status"; Option)
        {
            Caption = 'Status da carga';
            DataClassification = SystemMetadata;
            OptionMembers = " ","Not started",Running,Completed,Failed;
            OptionCaption = ' ,Não iniciada,Executando,Concluída,Falhou';
        }
        field(15; "Load Started"; DateTime)
        {
            Caption = 'Início da carga';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(16; "Load Finished"; DateTime)
        {
            Caption = 'Fim da carga';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "CSV Size (KB)"; Integer)
        {
            Caption = 'Tamanho (KB)';
            DataClassification = SystemMetadata;
            Editable = false;
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
        CityKey: Text;
        CitiesTmp: Dictionary of [Text, Boolean];
    begin
        PostCode.Reset();
        PostCode.SetRange("Country/Region Code", 'BR');
        "Base CEPs" := PostCode.Count();

        // municipios distintos = UF + municipio (a Post Code repete a cidade
        // em cada faixa de CEP, entao contar linhas inflaria o numero)
        Clear(CitiesTmp);
        if PostCode.FindSet() then
            repeat
                CityKey := PostCode."KINTO State" + '|' + PostCode.City;
                if not CitiesTmp.ContainsKey(CityKey) then
                    CitiesTmp.Add(CityKey, true);
            until PostCode.Next() = 0;
        "Base Cities" := CitiesTmp.Count;
    end;

    // Guarda o arquivo enviado pelo usuario no campo Blob.
    // ANEXA o CSV ao campo Blob e devolve o tamanho REALMENTE persistido.
    //
    // Historico de "0 bytes gravados" neste campo (1.2.0.9, 1.2.1.1), sempre
    // com nome e tamanho certos na tela:
    //
    //  1. Abrir CreateInStream() no Blob com um OutStream dele ainda vivo:
    //     invalida a escrita pendente e o campo fica zerado.
    //  2. Gravar o Blob numa instancia e chamar Modify() em OUTRA: o Modify
    //     grava o registro inteiro e sobrescreve o Blob com o buffer vazio da
    //     segunda instancia. Era este o caso — a pagina gravava no Rec dela e
    //     o Modify saia em outro momento.
    //
    // Por isso tudo acontece aqui, numa unica instancia obtida por Get():
    // escreve com CreateOutStream INLINE (liberado no fim da instrucao, como
    // em Report Layouts), faz Modify(), rele e devolve o tamanho conferido.
    procedure AttachFile(FileName: Text; var InStr: InStream): Integer
    var
        Buf: Record "KINTO CEP Import Buffer";
        ChkIn: InStream;
        OutStr: OutStream;
        Size: Integer;
    begin
        if not Buf.Get("Entry No.") then
            Buf.Insert();

        Size := InStr.Length();
        Buf."CSV Blob".CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        Clear(OutStr);
        Buf."File Name" := FileName;
        Buf."CSV Size (KB)" := Size div 1024;
        Buf.Modify();

        Buf.Get("Entry No.");
        Buf."CSV Blob".CreateInStream(ChkIn);
        exit(ChkIn.Length());
    end;

    procedure FileIntoStream(var InStr: InStream): Boolean
    begin
        if "File Name" = '' then
            exit(false);
        "CSV Blob".CreateInStream(InStr);
        exit(InStr.Length() > 0);
    end;

    procedure ClearFile()
    var
        OutStr: OutStream;
    begin
        // Escrever num OutStream vazio zera o Blob de forma confiavel
        "CSV Blob".CreateOutStream(OutStr);
        "File Name" := '';
        "CSV Size (KB)" := 0;
    end;
}
