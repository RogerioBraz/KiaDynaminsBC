page 60024 "KINTO Integration Test"
{
    Caption = 'Integration Test (Public APIs)';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "KINTO Country Setup";
    SourceTableTemporary = true;
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = false;

    // ============================================================
    // Tela de demonstracao das integracoes gratuitas (piloto KINTO).
    //
    // Mostra, na mesma pagina, o resultado de cada fonte publica:
    //   - CEP  -> endereco + lat/long (BrasilAPI)
    //   - CNPJ -> razao social, situacao e socios (BrasilAPI / Minha Receita)
    //   - FIPE -> valor de referencia do veiculo por codigo FIPE
    //   - CPF/CNPJ -> validacao de digito verificador (local, sem rede)
    //
    // Serve para provar capacidade sem custo: nenhuma destas consultas passa
    // por contratacao de terceiro.
    // ============================================================

    layout
    {
        area(Content)
        {
            group(Test)
            {
                Caption = 'Consultar';
                field(TestCep; TestCep)
                {
                    ApplicationArea = All;
                    Caption = 'CEP';
                }
                field(TestCnpj; TestCnpj)
                {
                    ApplicationArea = All;
                    Caption = 'CNPJ';
                }
                field(TestCpf; TestCpf)
                {
                    ApplicationArea = All;
                    Caption = 'CPF (validação local)';
                }
                field(TestFipe; TestFipe)
                {
                    ApplicationArea = All;
                    Caption = 'Código FIPE';
                }
            }
            group(Result)
            {
                Caption = 'Resultado';
                field(ResultText; ResultText)
                {
                    ApplicationArea = All;
                    Caption = 'Retorno';
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActConsultCep)
            {
                Caption = 'Consultar CEP';
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                var
                    Api: Codeunit "KINTO Brasil API Integration";
                    J: JsonObject;
                    Street, City, Uf, Ibge: Text;
                begin
                    J := Api.LookupCep(TestCep);
                    Street := Api.GetText(J, 'street'); City := Api.GetText(J, 'city');
                    Uf := Api.GetText(J, 'state'); Ibge := Api.GetText(J, 'ibge');
                    ResultText := 'CEP: ' + Street + ', ' + City + '/' + Uf + ' | IBGE ' + Ibge;
                    CurrPage.Update(false);
                end;
            }
            action(ActConsultCnpj)
            {
                Caption = 'Consultar CNPJ';
                ApplicationArea = All;
                Image = Company;
                trigger OnAction()
                var
                    Api: Codeunit "KINTO Brasil API Integration";
                    J: JsonObject;
                    Razao, Situacao, Municipio, Uf: Text;
                begin
                    J := Api.LookupCnpj(TestCnpj);
                    Razao := Api.GetText(J, 'razao_social');
                    Situacao := Api.GetText(J, 'descricao_situacao_cadastral');
                    Municipio := Api.GetText(J, 'municipio'); Uf := Api.GetText(J, 'uf');
                    ResultText := 'CNPJ: ' + Razao + ' | ' + Situacao + ' | ' + Municipio + '/' + Uf;
                    CurrPage.Update(false);
                end;
            }
            action(ActValidateCpf)
            {
                Caption = 'Validar CPF';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                var
                    Api: Codeunit "KINTO Brasil API Integration";
                begin
                    if Api.IsValidCpf(TestCpf) then
                        ResultText := 'CPF ' + TestCpf + ': dígitos verificadores CORRETOS (validação local, sem consulta)'
                    else
                        ResultText := 'CPF ' + TestCpf + ': INVÁLIDO (dígito verificador não confere)';
                    CurrPage.Update(false);
                end;
            }
            action(ActConsultFipe)
            {
                Caption = 'Consultar FIPE';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                var
                    Api: Codeunit "KINTO Brasil API Integration";
                    Valor: Decimal;
                    Mes, ValorTxt, Modelo: Text;
                begin
                    Valor := Api.GetFipeValue(TestFipe, Mes, ValorTxt, Modelo);
                    ResultText := 'FIPE ' + TestFipe + ': ' + ValorTxt + ' (' + Mes + ') — ' + Modelo +
                        Format(Valor, 0, '<Precision,2><Standard Format,1>');
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        TestCep: Text[10];
        TestCnpj: Text[20];
        TestCpf: Text[14];
        TestFipe: Text[20];
        ResultText: Text[500];
}
