codeunit 60025 "KINTO CEP Loader"
{
    // ============================================================
    // CARGA E MANUTENCAO DA BASE DE CEP NA "Post Code" DO BC
    //
    // O BC SaaS nao le disco, entao a entrada da base e por:
    //   1. LoadFromStream -> nucleo (recebe qualquer InStream)
    //   2. LoadFromUrl    -> CSV publicado numa URL (Azure Blob, CDN)
    //   3. LoadFromMedia  -> arquivo arrastado na pagina (MediaSet)
    //   4. LookupAndCreate-> consulta UM CEP na API publica e cria
    //
    // Formato CSV (cabecalho obrigatorio, ordem livre, virgula ou ';'):
    //   cep,logradouro,complemento,unidade,bairro,localidade,uf,ibge,estado,regiao
    //
    // Base de referencia: OpenCEP/Correios — 1.209.314 CEPs, 27 UFs.
    // ============================================================

    var
        Api: Codeunit "KINTO Brasil API Integration";
        ImportedLabel: Label '%1 CEP(s) incluído(s), %2 atualizado(s), %3 ignorado(s).';
        NoFileErr: Label 'Nenhum arquivo informado. Envie o CSV ou preencha a URL.';
        BadCepErr: Label 'CEP inválido: %1';
        CreatedLabel: Label 'CEP %1 criado: %2 — %3/%4';
        ExistsLabel: Label 'CEP %1 já existe: %2 — %3/%4';
        UrlEmptyErr: Label 'Informe a URL do arquivo CSV.';
        DownloadErr: Label 'Falha ao baixar o arquivo (HTTP %1).';
        NoHeaderErr: Label 'Cabeçalho do CSV não contém a coluna "cep".';
        ZipNotSupportedErr: Label 'A URL aponta para um arquivo ZIP, não para o CSV. O ZIP do OpenCEP traz um JSON por CEP e não pode ser lido direto pelo BC. Use a URL de um CSV já convertido (colunas cep,logradouro,complemento,bairro,localidade,uf,ibge).';
        EmptyFileErr: Label 'Arquivo vazio ou sem linhas de dados.';
        BlobVazioErr: Label 'O arquivo anexado não foi gravado no Blob (0 bytes). Anexe o CSV novamente pelo menu Importação > Anexar arquivo CSV.';

    // ============================================================
    // 1. NUCLEO — importa de qualquer InStream
    // ============================================================
    procedure LoadFromStream(SourceStream: InStream; UfFilter: Code[2]; ReplaceBR: Boolean): Integer
    var
        TempBlob: Codeunit "Temp Blob";
        ReopenOut: OutStream;
        Stream: InStream;
        Line: Text;
        Headers: Dictionary of [Text, Integer];
        PostCode: Record "Post Code";
        Separator: Text[1];
        Inserted: Integer;
        Updated: Integer;
        Skipped: Integer;
        Cep, Street, Complement, Neighborhood, City, Uf, Ibge: Text;
        Cells: List of [Text];
        Total: Integer;
    begin
        // ENCODING — causa dos acentos quebrados (São -> São):
        // o ReadText do AL assume MS-DOS quando o arquivo nao tem BOM. O CSV
        // em UTF-8 sem BOM era lido byte a byte como ANSI. Aqui o stream de
        // origem (upload, Blob ou URL) e copiado em BYTES para um Temp Blob e
        // reaberto com TextEncoding::UTF8 — a copia nao interpreta encoding,
        // so a reabertura, que agora decodifica certo.
        TempBlob.CreateOutStream(ReopenOut);
        CopyStream(ReopenOut, SourceStream);
        Clear(ReopenOut);
        TempBlob.CreateInStream(Stream, TextEncoding::UTF8);

        // InStream.ReadText le UMA LINHA por chamada — nao precisa de split manual
        if Stream.EOS() then
            Error(EmptyFileErr);

        Stream.ReadText(Line);
        // BOM UTF-8: quando o arquivo tem BOM, o primeiro caractere da
        // primeira linha vem como U+FEFF e a coluna vira "\ufeffcep" — o
        // BuildIndex nao acha "cep" e a importacao morre no NoHeaderErr.
        // O pacote oficial do OpenCEP e um ZIP com um JSON por CEP (326 MB),
        // nao um CSV. Avisar em vez de importar lixo.
        if CopyStr(Line, 1, 2) = 'PK' then
            Error(ZipNotSupportedErr);

        if StrPos(Line, ';') > 0 then
            Separator := ';'
        else
            Separator := ',';

        Headers := BuildIndex(SplitLine(Line, Separator));
        // BOM UTF-8: se o arquivo vier com BOM, o primeiro caractere da
        // primeira linha e U+FEFF e a coluna vira "<BOM>cep" — o BuildIndex
        // nao acha "cep" e a carga morre com NoHeaderErr. Em vez de mexer em
        // codeunits de caractere, refaz o indice sem o primeiro caractere.
        if not Headers.ContainsKey('cep') then begin
            Line := CopyStr(Line, 2, StrLen(Line));
            Headers := BuildIndex(SplitLine(Line, Separator));
        end;
        if not Headers.ContainsKey('cep') then
            Error(NoHeaderErr);

        if ReplaceBR then begin
            PostCode.Reset();
            PostCode.SetRange("Country/Region Code", 'BR');
            PostCode.DeleteAll(true);
        end;

        while not Stream.EOS() do begin
            Stream.ReadText(Line);
            if Line.Trim() = '' then
                continue;

            Cells := SplitLine(Line, Separator);
            Cep := OnlyDigits(FieldAt(Cells, Headers, 'cep'));
            if StrLen(Cep) <> 8 then begin
                Skipped += 1;
                continue;
            end;

            Uf := FieldAt(Cells, Headers, 'uf');
            if (UfFilter <> '') and (Uf <> UfFilter) then begin
                Skipped += 1;
                continue;
            end;

            Street := FieldAt(Cells, Headers, 'logradouro');
            Complement := FieldAt(Cells, Headers, 'complemento');
            Neighborhood := FieldAt(Cells, Headers, 'bairro');
            City := FieldAt(Cells, Headers, 'localidade');
            Ibge := FieldAt(Cells, Headers, 'ibge');
            if City = '' then
                City := '-';

            if UpsertPostCode(Cep, City, Street, Complement, Neighborhood, Uf, Ibge) then
                Inserted += 1
            else
                Updated += 1;

            Total += 1;
            if Total mod 25000 = 0 then
                Commit();
        end;

        Commit();
        Message(ImportedLabel, Inserted, Updated, Skipped);
        exit(Inserted);
    end;

    // ============================================================
    // 1b. CARGA A PARTIR DO BLOB DA PAGINA (caminho principal)
    // ============================================================
    // O usuario anexa o CSV no campo Blob da pagina e o loader consome dali.
    procedure LoadFromBlob(var ImportBuf: Record "KINTO CEP Import Buffer"): Integer
    var
        InStr: InStream;
        Size: Integer;
    begin
        if ImportBuf."File Name" = '' then
            Error(NoFileErr);
        ImportBuf."CSV Blob".CreateInStream(InStr, TextEncoding::UTF8);
        // O Blob pode estar vazio mesmo com nome de arquivo preenchido (foi o
        // que aconteceu no teste de 29/10: gravacao em duas etapas perdia o
        // conteudo). Aqui a checagem e no CONTEUDO, nao no nome.
        Size := InStr.Length();
        if Size = 0 then
            Error(BlobVazioErr);
        ImportBuf."CSV Size (KB)" := Size div 1024;
        exit(LoadFromStream(InStr, ImportBuf."UF Filter", ImportBuf."Replace BR"));
    end;

    // ============================================================
    // 2. URL — baixa o CSV e delega ao nucleo
    // ============================================================
    procedure LoadFromUrl(Url: Text; UfFilter: Code[2]; ReplaceBR: Boolean): Integer
    var
        InStr: InStream;
        RangeFrom, Total: Integer;
        ChunkSize: Integer;
    begin
        if Url = '' then
            Error(UrlEmptyErr);
        // O BC online aceita resposta de ate 150 MiB. A base completa em CSV
        // tem ~88 MB, entao cabe numa requisicao so. O download vai em
        // streaming para o InStream e o parse le linha a linha — nada de
        // carregar o corpo inteiro em Text (isso estourava a memoria).
        ChunkSize := DownloadChunk(Url, 0, InStr);
        exit(LoadFromStream(InStr, UfFilter, ReplaceBR));
    end;

    // Baixa a URL e devolve um InStream para leitura linha a linha.
    // RangeFrom permite baixar em partes (0 = arquivo inteiro) para fontes
    // que exigem fatias menores que o limite de 150 MiB do BC online.
    procedure DownloadChunk(Url: Text; RangeFrom: Integer; var OutStream: InStream): Integer
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Status: Integer;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        ChunkIn: InStream;
    begin
        Client.DefaultRequestHeaders.Clear();
        Client.DefaultRequestHeaders.Add('Accept', 'text/csv, text/plain, application/octet-stream');
        if RangeFrom > 0 then
            Client.DefaultRequestHeaders.Add('Range', 'bytes=' + Format(RangeFrom) + '-');

        if not Client.Get(Url, Response) then
            Error(DownloadErr, 'sem resposta');
        Status := Response.HttpStatusCode;
        if (Status <> 200) and (Status <> 206) then
            Error(DownloadErr, Status);

        // ReadAs espera InStream (nao OutStream): cria os dois no Temp Blob
        TempBlob.CreateOutStream(OutStr);
        TempBlob.CreateInStream(ChunkIn);
        if not Response.Content().ReadAs(ChunkIn) then
            Error(DownloadErr, 'corpo vazio');
        TempBlob.CreateInStream(OutStream, TextEncoding::UTF8);
        exit(TempBlob.Length());
    end;

    // ============================================================
    // 4. CONSULTA PONTUAL — API publica + cria se nao existir
    // ============================================================
    procedure LookupAndCreate(Cep: Text): Boolean
    var
        J: JsonObject;
        PostCode: Record "Post Code";
        CepLimpo: Text;
        City, Street, Neighborhood, Uf, Ibge: Text;
    begin
        CepLimpo := OnlyDigits(Cep);
        if StrLen(CepLimpo) <> 8 then
            Error(BadCepErr, Cep);

        PostCode.SetRange(Code, CopyStr(CepLimpo, 1, 20));
        if PostCode.FindFirst() then begin
            Message(ExistsLabel, CepLimpo, PostCode.City, PostCode."KINTO State", PostCode."KINTO Neighborhood");
            exit(false);
        end;

        J := Api.LookupCep(CepLimpo);
        City := Api.GetText(J, 'city');
        Street := Api.GetText(J, 'street');
        Neighborhood := Api.GetText(J, 'neighborhood');
        Uf := Api.GetText(J, 'state');
        Ibge := Api.GetText(J, 'ibge');

        PostCode.Init();
        PostCode.Code := CopyStr(CepLimpo, 1, 20);
        PostCode.City := CopyStr(City, 1, 30);
        PostCode."Search City" := CopyStr(City, 1, 30);
        PostCode."Country/Region Code" := 'BR';
        PostCode.County := CopyStr(Neighborhood, 1, 30);
        PostCode."KINTO Street" := CopyStr(Street, 1, 150);
        PostCode."KINTO Neighborhood" := CopyStr(Neighborhood, 1, 80);
        PostCode."KINTO State" := CopyStr(Uf, 1, 2);
        PostCode."KINTO IBGE City" := CopyStr(Ibge, 1, 10);
        PostCode."KINTO CEP Source" := PostCode."KINTO CEP Source"::API;
        PostCode."KINTO CEP Updated" := CurrentDateTime;
        PostCode.Insert(true);

        Message(CreatedLabel, CepLimpo, Street, City, Uf);
        exit(true);
    end;

    // ============================================================
    // UPSERT — devolve TRUE se incluiu, FALSE se atualizou
    // ============================================================
    local procedure UpsertPostCode(Cep: Text; City: Text; Street: Text; Complement: Text;
        Neighborhood: Text; Uf: Text; Ibge: Text): Boolean
    var
        PostCode: Record "Post Code";
    begin
        PostCode.SetRange(Code, CopyStr(Cep, 1, 20));
        PostCode.SetRange(City, CopyStr(City, 1, 30));
        if PostCode.FindFirst() then begin
            // nao sobrescreve registro que veio da API ou foi ajustado a mao
            if PostCode."KINTO CEP Source" = PostCode."KINTO CEP Source"::API then
                exit(false);
            PostCode."KINTO Street" := CopyStr(Street, 1, 150);
            PostCode."KINTO Complement" := CopyStr(Complement, 1, 80);
            PostCode."KINTO Neighborhood" := CopyStr(Neighborhood, 1, 80);
            PostCode."KINTO State" := CopyStr(Uf, 1, 2);
            PostCode."KINTO IBGE City" := CopyStr(Ibge, 1, 10);
            PostCode."KINTO CEP Source" := PostCode."KINTO CEP Source"::Base;
            PostCode."KINTO CEP Updated" := CurrentDateTime;
            PostCode.Modify(false);
            exit(false);
        end;

        PostCode.Init();
        PostCode.Code := CopyStr(Cep, 1, 20);
        PostCode.City := CopyStr(City, 1, 30);
        PostCode."Search City" := CopyStr(City, 1, 30);
        PostCode."Country/Region Code" := 'BR';
        PostCode.County := CopyStr(Neighborhood, 1, 30);
        PostCode."KINTO Street" := CopyStr(Street, 1, 150);
        PostCode."KINTO Complement" := CopyStr(Complement, 1, 80);
        PostCode."KINTO Neighborhood" := CopyStr(Neighborhood, 1, 80);
        PostCode."KINTO State" := CopyStr(Uf, 1, 2);
        PostCode."KINTO IBGE City" := CopyStr(Ibge, 1, 10);
        PostCode."KINTO CEP Source" := PostCode."KINTO CEP Source"::Base;
        PostCode."KINTO CEP Updated" := CurrentDateTime;
        PostCode.Insert(true);
        exit(true);
    end;

    // ============================================================
    // HELPERS DE CSV
    // ============================================================
    local procedure SplitLine(Line: Text; Separator: Text[1]): List of [Text]
    var
        Res: List of [Text];
        Cur: Text;
        C: Text[1];
        I: Integer;
        InQuotes: Boolean;
    begin
        Cur := '';
        InQuotes := false;
        for I := 1 to StrLen(Line) do begin
            C := CopyStr(Line, I, 1);
            if C = '"' then
                InQuotes := not InQuotes
            else if (C = Separator) and (not InQuotes) then begin
                Res.Add(Cur);
                Cur := '';
            end else
                Cur += C;
        end;
        Res.Add(Cur);
        exit(Res);
    end;

    local procedure BuildIndex(Headers: List of [Text]): Dictionary of [Text, Integer]
    var
        Idx: Dictionary of [Text, Integer];
        I: Integer;
    begin
        for I := 1 to Headers.Count() do
            if not Idx.ContainsKey(LowerCase(Headers.Get(I).Trim())) then
                Idx.Add(LowerCase(Headers.Get(I).Trim()), I);
        exit(Idx);
    end;

    local procedure FieldAt(Cells: List of [Text]; Idx: Dictionary of [Text, Integer]; Name: Text): Text
    var
        P: Integer;
    begin
        if not Idx.Get(Name, P) then
            exit('');
        if P > Cells.Count() then
            exit('');
        exit(Cells.Get(P).Trim());
    end;

    local procedure OnlyDigits(Value: Text): Text
    var
        I: Integer;
        C: Text[1];
        Out: Text;
    begin
        Out := '';
        for I := 1 to StrLen(Value) do begin
            C := CopyStr(Value, I, 1);
            if (C >= '0') and (C <= '9') then
                Out := Out + C;
        end;
        exit(Out);
    end;
}
