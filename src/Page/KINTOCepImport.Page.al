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
                Caption = 'Origem dos dados';
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Source URL"; Rec."Source URL")
                {
                    ApplicationArea = All;
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
            action(ImportFromUrl)
            {
                Caption = 'Importar da URL';
                ApplicationArea = All;
                Image = Internet;
                trigger OnAction()
                var
                    Loader: Codeunit "KINTO CEP Loader";
                    Count: Integer;
                begin
                    Count := Loader.LoadFromUrl(Rec."Source URL", Rec."UF Filter", Rec."Replace BR");
                    Rec."Last Result" := Format(Count) + ' CEP(s) incluído(s).';
                    Rec.RefreshCounters();
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
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

    trigger OnOpenPage()
    begin
        Rec.GetBuffer();
        Rec.RefreshCounters();
    end;


}
