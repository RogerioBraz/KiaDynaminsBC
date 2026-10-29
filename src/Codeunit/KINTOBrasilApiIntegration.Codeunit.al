codeunit 60023 "KINTO Brasil API Integration"
{
    // ============================================================
    // INTEGRACOES PUBLICAS GRATUITAS (piloto KINTO)
    //
    // Todas as fontes abaixo sao abertas, sem chave e sem contratacao:
    //   - BrasilAPI  (CEP, CNPJ, DDD, taxas, feriados)
    //   - Minha Receita (CNPJ, sem limite de uso por diretriz do projeto)
    //   - parallelum FIPE (preco de referencia do veiculo)
    //
    // Objetivo no piloto: demonstrar que o Business Central consome fontes
    // oficiais brasileiras sem middleware e sem custo por consulta.
    //
    // Registrado na pesquisa de 29/10/2026 — endpoints testados ao vivo.
    // ============================================================

    var
        // ---- endpoints (base unica para troca facil) ----
        BrasilApiUrl: Label 'https://brasilapi.com.br/api/', Locked = true;
        MinhaReceitaUrl: Label 'https://minhareceita.org/', Locked = true;
        FipeUrl: Label 'https://api.tabelafipe.info/api/v1/', Locked = true;

        // ---- mensagens ----
        CepNotFoundErr: Label 'CEP %1 nao encontrado nas bases publicas.';
        CnpjNotFoundErr: Label 'CNPJ %1 nao encontrado na base da Receita Federal.';
        FipeNotFoundErr: Label 'Nao foi possivel obter o preco FIPE para o codigo %1 / ano %2.';
        HttpStatusErr: Label 'A consulta a %1 retornou HTTP %2.';
        EmptyResponseErr: Label 'A consulta a %1 voltou sem conteudo.';

    // ============================================================
    // CEP -> ENDERECO
    // BrasilAPI CEP v2: devolve logradouro, bairro, cidade, UF, codigo IBGE,
    // timezone e LATITUDE/LONGITUDE. O geolocal permite plotar a frota num
    // mapa sem contratar servico de geocoding.
    // ============================================================
    procedure LookupCep(Cep: Text): JsonObject
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Status: Integer;
        Body: Text;
        JObj: JsonObject;
    begin
        CleanCep(Cep);
        if StrLen(Cep) <> 8 then
            Error(CepNotFoundErr, Cep);

        GetJson(Client, Response, BrasilApiUrl + 'cep/v2/' + Cep, Status, Body);
        if Status = 404 then
            Error(CepNotFoundErr, Cep);
        if Status <> 200 then
            Error(HttpStatusErr, 'BrasilAPI CEP', Status);

        if not JObj.ReadFrom(Body) then
            Error(EmptyResponseErr, 'BrasilAPI CEP');
        exit(JObj);
    end;

    // ============================================================
    // CNPJ -> DADOS DA EMPRESA
    // Tenta BrasilAPI primeiro e Minha Receita como fallback (mesma origem:
    // arquivos abertos da Receita). Devolve razao social, endereco, CNAE,
    // situacao cadastral e o QSA (socios com qualificacao).
    // ============================================================
    procedure LookupCnpj(Cnpj: Text): JsonObject
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Status: Integer;
        Body: Text;
        JObj: JsonObject;
    begin
        CleanCnpj(Cnpj);
        if StrLen(Cnpj) <> 14 then
            Error(CnpjNotFoundErr, Cnpj);

        // 1a tentativa: BrasilAPI
        GetJson(Client, Response, BrasilApiUrl + 'cnpj/v1/' + Cnpj, Status, Body);
        if (Status = 200) and JObj.ReadFrom(Body) then
            exit(JObj);

        // 2a tentativa: Minha Receita (sem limite de uso, mesma base)
        GetJson(Client, Response, MinhaReceitaUrl + Cnpj, Status, Body);
        if Status = 404 then
            Error(CnpjNotFoundErr, Cnpj);
        if Status <> 200 then
            Error(HttpStatusErr, 'Minha Receita', Status);
        if not JObj.ReadFrom(Body) then
            Error(EmptyResponseErr, 'Minha Receita');
        exit(JObj);
    end;

    // ============================================================
    // FIPE -> PRECO DE REFERENCIA DO VEICULO
    // O cap da cobranca de excesso de quilometragem usa o "Booking Value" do
    // veiculo (KINTO Vehicle Downtime / Inventory Vehicle). Hoje esse valor e
    // digitado a mao; a FIPE ancora no preco medio de mercado do mes.
    //
    // Retorna o VALOR ja convertido para Decimal, e devolve por referencia o
    // mes de referencia e o codigo FIPE para auditoria.
    // ============================================================
    procedure GetFipeValue(CodigoFipe: Text; var MesReferencia: Text; var ValorTexto: Text; var ModeloTexto: Text): Decimal
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Status: Integer;
        Body: Text;
        JObj: JsonObject;
        Atual: JsonObject;
        Centavos: Text;
        Valor: Decimal;
    begin
        // tabelafipe.info aceita o CODIGO FIPE direto (ex. 005329-5) e devolve o
        // preco vigente em centavos ("value_cents"), o que evita parse de moeda.
        // Testado em 29/10/2026: retorna atual + historico mensal.
        GetJson(Client, Response, FipeUrl + 'fipe/' + CodigoFipe, Status, Body);
        if Status = 404 then
            Error(FipeNotFoundErr, CodigoFipe, '');
        if Status <> 200 then
            Error(HttpStatusErr, 'tabelafipe.info', Status);
        if not JObj.ReadFrom(Body) then
            Error(EmptyResponseErr, 'FIPE');

        if not GetObject(JObj, 'atual', Atual) then
            Error(FipeNotFoundErr, CodigoFipe, '');

        ValorTexto := GetText(Atual, 'value_label');
        MesReferencia := GetText(Atual, 'mes');
        ModeloTexto := GetText(Atual, 'model_name');
        Centavos := GetText(Atual, 'value_cents');
        if Centavos <> '' then
            // value_cents vem como texto de digitos: converte por aritmetica
            exit(StrToDecimalSafe(Centavos) / 100);
        exit(0);
    end;

    // ============================================================
    // VALIDACAO LOCAL DE CPF E CNPJ (modulo 11)
    // Nao substitui a consulta a Receita (que confirma existencia e situacao),
    // mas pega erro de digitacao e transposicao antes de gravar. Custo zero,
    // ... sem rede.
    // ============================================================
    procedure IsValidCpf(Cpf: Text): Boolean
    var
        D: array[11] of Integer;
        I, Soma, Resto, DV1, DV2: Integer;
        Limpo: Text;
    begin
        Limpo := OnlyDigits(Cpf);
        if StrLen(Limpo) <> 11 then
            exit(false);
        if Limpo = '00000000000' then
            exit(false);
        // rejeita sequencias repetidas (111..., 222...)
        if Limpo = '11111111111' then exit(false);
        if Limpo = '22222222222' then exit(false);
        if Limpo = '33333333333' then exit(false);
        if Limpo = '44444444444' then exit(false);
        if Limpo = '55555555555' then exit(false);
        if Limpo = '66666666666' then exit(false);
        if Limpo = '77777777777' then exit(false);
        if Limpo = '88888888888' then exit(false);
        if Limpo = '99999999999' then exit(false);

        for I := 1 to 11 do
            D[I] := CodeDigit(CopyStr(Limpo, I, 1));

        // 1o digito: pesos 10..2 sobre os 9 primeiros
        Soma := 0;
        for I := 1 to 9 do
            Soma += D[I] * (11 - I);
        Resto := Soma mod 11;
        if Resto < 2 then DV1 := 0 else DV1 := 11 - Resto;
        if DV1 <> D[10] then
            exit(false);

        // 2o digito: pesos 11..2 sobre os 10 primeiros
        Soma := 0;
        for I := 1 to 10 do
            Soma += D[I] * (12 - I);
        Resto := Soma mod 11;
        if Resto < 2 then DV2 := 0 else DV2 := 11 - Resto;
        exit(DV2 = D[11]);
    end;

    procedure IsValidCnpj(Cnpj: Text): Boolean
    var
        D: array[14] of Integer;
        I, Soma, Resto, DV1, DV2: Integer;
        Limpo: Text;
        Peso1: array[13] of Integer;
        Peso2: array[14] of Integer;
    begin
        Limpo := OnlyDigits(Cnpj);
        if StrLen(Limpo) <> 14 then
            exit(false);
        if Limpo = '00000000000000' then
            exit(false);

        for I := 1 to 14 do
            D[I] := CodeDigit(CopyStr(Limpo, I, 1));

        Peso1[1]:=5; Peso1[2]:=4; Peso1[3]:=3; Peso1[4]:=2; Peso1[5]:=9; Peso1[6]:=8; Peso1[7]:=7;
        Peso1[8]:=6; Peso1[9]:=5; Peso1[10]:=4; Peso1[11]:=3; Peso1[12]:=2;
        Soma := 0;
        for I := 1 to 12 do
            Soma += D[I] * Peso1[I];
        Resto := Soma mod 11;
        if Resto < 2 then DV1 := 0 else DV1 := 11 - Resto;
        if DV1 <> D[13] then
            exit(false);

        Peso2[1]:=6; Peso2[2]:=5; Peso2[3]:=4; Peso2[4]:=3; Peso2[5]:=2; Peso2[6]:=9; Peso2[7]:=8;
        Peso2[8]:=7; Peso2[9]:=6; Peso2[10]:=5; Peso2[11]:=4; Peso2[12]:=3; Peso2[13]:=2;
        Soma := 0;
        for I := 1 to 13 do
            Soma += D[I] * Peso2[I];
        Resto := Soma mod 11;
        if Resto < 2 then DV2 := 0 else DV2 := 11 - Resto;
        exit(DV2 = D[14]);
    end;

    // ============================================================
    // HELPERS DE JSON
    // JsonObject.Get exige um JsonToken, nao um Text. Estes wrappers evitam
    // repetir o padrao em cada leitura de campo.
    // ============================================================
    procedure GetText(JObj: JsonObject; Prop: Text): Text
    var
        Tok: JsonToken;
    begin
        if JObj.Get(Prop, Tok) then
            exit(Format(Tok.AsValue().AsText()));
        exit('');
    end;

    procedure GetDecimal(JObj: JsonObject; Prop: Text): Decimal
    var
        Tok: JsonToken;
    begin
        if JObj.Get(Prop, Tok) then
            exit(Tok.AsValue().AsDecimal());
        exit(0);
    end;

    procedure GetObject(JObj: JsonObject; Prop: Text; var Out: JsonObject): Boolean
    var
        Tok: JsonToken;
    begin
        if JObj.Get(Prop, Tok) and Tok.IsObject() then begin
            Out := Tok.AsObject();
            exit(true);
        end;
        exit(false);
    end;

    // ============================================================
    // HELPERS
    // ============================================================
    local procedure GetJson(var Client: HttpClient; var Response: HttpResponseMessage; Url: Text;
        var Status: Integer; var Body: Text)
    var
        ReqMsg: HttpRequestMessage;
    begin
        Client.DefaultRequestHeaders.Clear();
        Client.DefaultRequestHeaders.Add('Accept', 'application/json');
        Client.DefaultRequestHeaders.Add('User-Agent', 'KiaDynBC-Pilot/1.0');
        ReqMsg.Method := 'GET';
        ReqMsg.SetRequestUri(Url);
        if Client.Send(ReqMsg, Response) then begin
            Status := Response.HttpStatusCode;
            if not Response.Content().ReadAs(Body) then
                Body := '';
        end else begin
            Status := 0;
            Body := '';
        end;
    end;

    // Converte "7141500" em 7141500 sem Evaluate (que e para formulas).
    local procedure StrToDecimalSafe(S: Text): Decimal
    var
        I, D: Integer;
        R: Decimal;
    begin
        R := 0;
        for I := 1 to StrLen(S) do begin
            D := CodeDigit(CopyStr(S, I, 1));
            R := R * 10 + D;
        end;
        exit(R);
    end;

    // converte um caractere '0'..'9' no inteiro correspondente sem Evaluate
    local procedure CodeDigit(C: Text): Integer
    var
        Dig: array[10] of Text[1];
    begin
        if C = '0' then exit(0); if C = '1' then exit(1);
        if C = '2' then exit(2); if C = '3' then exit(3);
        if C = '4' then exit(4); if C = '5' then exit(5);
        if C = '6' then exit(6); if C = '7' then exit(7);
        if C = '8' then exit(8); if C = '9' then exit(9);
        exit(0);
    end;

    local procedure CleanCep(var Cep: Text)
    begin
        Cep := OnlyDigits(Cep);
    end;

    local procedure CleanCnpj(var Cnpj: Text)
    begin
        Cnpj := OnlyDigits(Cnpj);
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
