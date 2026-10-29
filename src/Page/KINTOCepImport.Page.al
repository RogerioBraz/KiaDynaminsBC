page 50309 "KINTO CEP Import"
{
    Caption = 'Importar Base de CEP';
    PageType = Card;
    SourceTable = "KINTO CEP Import Buffer";
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    // ============================================================
    // Tela de carga da base de CEP na "Post Code" do BC.
    //
    // Duas formas, porque o BC SaaS nao le disco:
    //   1. Arrastar o CSV no campo Arquivo (base OpenCEP/Correios)
    //   2. Informar uma URL publica do CSV (Azure Blob, CDN)
    //
    // Filtro por UF permite carregar so o estado da frota piloto — 331 mil
    // CEPs em SP contra 1,2 milhao do Brasil inteiro.
    // ============================================================

    layout
    {
        area(Content)
        {
            group(Source)
            {
                Caption = 'Arquivo da base';
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("CSV Size (KB)"; Rec."CSV Size (KB)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(FullBase)
            {
                Caption = 'Base completa pela URL';
                field("Source URL"; Rec."Source URL")
                {
                    ApplicationArea = All;
                    ShowMandatory = false;
                }
                field("Last Url Used"; Rec."Last Url Used") { ApplicationArea = All; }
                field("Load Status"; Rec."Load Status") { ApplicationArea = All; }
                field("Load Started"; Rec."Load Started") { ApplicationArea = All; }
                field("Load Finished"; Rec."Load Finished") { ApplicationArea = All; }
            }
            group(Options)
            {
                Caption = 'Opções';
                field("UF Filter"; Rec."UF Filter") { ApplicationArea = All; }
                field("Lookup CEP"; Rec."Lookup CEP") { ApplicationArea = All; }
                field("Replace BR"; Rec."Replace BR") { ApplicationArea = All; }
            }
            group(Status)
            {
                Caption = 'Situação da base';
                field("Base CEPs"; Rec."Base CEPs")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Base Cities"; Rec."Base Cities")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Result"; Rec."Last Result")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ImportGroup)
            {
                Caption = 'Importação';

                action(ImportFromFile)
                {
                    Caption = 'Importar arquivo CSV...';
                    ApplicationArea = All;
                    Image = Import;
                    trigger OnAction()
                    var
                        InStr: InStream;
                        FileName: Text;
                        Ok: Boolean;
                        Count: Integer;
                        Loader: Codeunit "KINTO CEP Loader";
                        Api2: Codeunit "KINTO Brasil API Integration";
                    begin
                        // CAMINHO CONFIRMADO: o stream do upload vai DIRETO
                        // para o parser, sem passar por Blob. O round-trip
                        // upload -> Blob -> leitura falhou 3x nesta tabela
                        // (Blob vazio), e Blob nao tem ImportStream em AL.
                        // Gravar no Blob fica como cortesia, sem depender dele.
                        Ok := UploadIntoStream(
                            'Selecione a base de CEP em CSV',
                            '', 'Arquivo CSV (*.csv)|*.csv', FileName, InStr);
                        if (not Ok) or (FileName = '') then
                            exit;

                        if not Confirm(ImportarConfirm, false) then
                            exit;

                        Count := Loader.LoadFromStream(InStr, Rec."UF Filter", Rec."Replace BR");

                        Rec."Last Result" := Format(Count) + ' CEP(s) importado(s) de ' +
                            FileName + '.';
                        Rec.RefreshCounters();
                        Rec.Modify();
                        CurrPage.Update(false);
                    end;
                }

                action(ImportFromBlob)
                {
                    Caption = 'Importar arquivo anexado';
                    ApplicationArea = All;
                    Image = Import;
                    trigger OnAction()
                    var
                        Loader: Codeunit "KINTO CEP Loader";
                        Count: Integer;
                    begin
                        if Rec."File Name" = '' then
                            Error(NenhumArquivoErr);
                        Count := Loader.LoadFromBlob(Rec);
                        Rec."Last Result" := Format(Count) + ' CEP(s) incluído(s) de ' + Rec."File Name" + '.';
                        Rec.RefreshCounters();
                        Rec.Modify();
                        CurrPage.Update(false);
                    end;
                }

                action(LoadFullBaseFromUrl)
                {
                    Caption = 'Carregar base completa da URL (job)';
                    ApplicationArea = All;
                    Image = Start;
                    trigger OnAction()
                    var
                        JobQueue: Record "Job Queue Entry";
                        JobMgt: Codeunit "Job Queue Management";
                        FullLoad: Codeunit "KINTO CEP Full Load";
                    begin
                        if Rec."Source URL" = '' then
                            Error(UrlObrigatoriaErr);
                        if not Confirm(CarregarBaseConfirm, false) then
                            exit;

                        // 1,2 milhao de CEPs nao cabem numa sessao interativa:
                        // enfileira para o job queue rodar em background.
                        Rec."Source URL" := Rec."Source URL";
                        Rec.Modify();

                        JobQueue.Init();
                        JobQueue."Object Type to Run" := JobQueue."Object Type to Run"::Codeunit;
                        JobQueue."Object ID to Run" := Codeunit::"KINTO CEP Full Load";
                        JobQueue.Description := 'KINTO CEP - carga completa da base';
                        JobQueue."Parameter String" := Rec."Source URL";
                        JobQueue."Earliest Start Date/Time" := CurrentDateTime;
                        JobQueue."Recurring Job" := false;
                        JobQueue."Job Queue Category Code" := '';
                        JobQueue.Insert(true);

                        Rec."Load Status" := Rec."Load Status"::"Not started";
                        Rec."Last Result" := 'Carga agendada na fila de trabalhos (ID ' +
                            Format(JobQueue.ID) + '). Acompanhe em "Job Queue Entries".';
                        Rec.Modify();
                        CurrPage.Update(false);
                    end;
                }

                action(ClearFile)
                {
                    Caption = 'Remover arquivo anexado';
                    ApplicationArea = All;
                    Image = Delete;
                    trigger OnAction()
                    begin
                        Rec.ClearFile();
                        Rec.Modify();
                        Rec."Last Result" := 'Arquivo removido.';
                        CurrPage.Update(false);
                    end;
                }
            }
            action(LookupOne)
            {
                Caption = 'Consultar um CEP';
                ApplicationArea = All;
                Image = Search;
                trigger OnAction()
                var
                    Loader: Codeunit "KINTO CEP Loader";
                begin
                    if Rec."Lookup CEP" = '' then
                        Error(CepVazioErr);
                    if Loader.LookupAndCreate(Rec."Lookup CEP") then
                        Rec."Last Result" := 'CEP ' + Rec."Lookup CEP" + ' criado na Post Code.'
                    else
                        Rec."Last Result" := 'CEP ' + Rec."Lookup CEP" + ' já existia na base.';
                    Rec.RefreshCounters();
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }
            action(OpenPostCodes)
            {
                Caption = 'Abrir Post Codes';
                ApplicationArea = All;
                Image = List;
                trigger OnAction()
                begin
                    Page.Run(Page::"Post Codes");
                end;
            }
        }
    }

    var
        CepVazioErr: Label 'Informe o CEP no campo "CEP para consultar".';
        UrlObrigatoriaErr: Label 'Informe a URL do CSV da base completa.';
        CarregarBaseConfirm: Label 'A carga completa tem cerca de 1,2 milhão de CEPs e roda em background. Confirma?', Locked = true;
        ImportarConfirm: Label 'Importar os CEPs deste arquivo para a base (Post Code) do Business Central?', Locked = true;
        GravacaoFalhouErr: Label 'Não foi possível gravar o arquivo %1 no Blob do Business Central. Nada foi importado.';
        NenhumArquivoErr: Label 'Anexe um arquivo CSV antes de importar (menu Importação > Anexar arquivo CSV).';

    trigger OnOpenPage()
    begin
        Rec.GetBuffer();
        Rec.RefreshCounters();
    end;


}
