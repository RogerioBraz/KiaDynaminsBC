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

                action(AttachFile)
                {
                    Caption = 'Anexar arquivo CSV...';
                    ApplicationArea = All;
                    Image = Import;
                    trigger OnAction()
                    var
                        InStr: InStream;
                        FileName: Text;
                        Size: Integer;
                        Ok: Boolean;
                    begin
                        // UploadIntoStream e a funcao nativa do cliente:
                        // (titulo, pasta, filtro, var nome, var stream)
                        Ok := UploadIntoStream(
                            'Selecione a base de CEP em CSV',
                            '', 'Arquivo CSV (*.csv)|*.csv', FileName, InStr);
                        if (not Ok) or (FileName = '') then
                            exit;
                        Size := Rec.StoreFile(FileName, InStr);
                        Rec.Modify();
                        Rec."Last Result" := 'Arquivo ' + FileName + ' anexado (' +
                            Format(Size div 1024) + ' KB). Agora use "Importar arquivo anexado".';
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
        NenhumArquivoErr: Label 'Anexe um arquivo CSV antes de importar (menu Importação > Anexar arquivo CSV).';

    trigger OnOpenPage()
    begin
        Rec.GetBuffer();
        Rec.RefreshCounters();
    end;


}
