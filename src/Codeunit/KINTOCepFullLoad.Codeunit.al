codeunit 60026 "KINTO CEP Full Load"
{
    // ============================================================
    // CARGA COMPLETA DA BASE DE CEP EM JOB QUEUE
    //
    // A base nacional tem ~1,2 milhao de CEPs. Rodar isso numa sessao
    // interativa estoura o tempo de execucao e trava a UI do usuario, entao
    // a carga roda como job: baixa o CSV por streaming e importa em blocos,
    // gravando o progresso para poder ser acompanhada na pagina.
    //
    // Parametro (Parameter String da Job Queue): a URL do CSV.
    // Formato esperado: cep,logradouro,complemento,unidade,bairro,
    //                   localidade,uf,ibge,estado,regiao
    // ============================================================

    TableNo = "KINTO CEP Import Buffer";

    trigger OnRun()
    var
        ImportBuf: Record "KINTO CEP Import Buffer";
        Loader: Codeunit "KINTO CEP Loader";
        Url: Text;
        Count: Integer;
    begin
        ImportBuf.GetBuffer();
        Url := ImportBuf."Source URL";
        if Url = '' then
            Url := ImportBuf."Last Url Used";
        if Url = '' then
            Error(NoUrlErr);

        ImportBuf."Load Status" := ImportBuf."Load Status"::Running;
        ImportBuf."Load Started" := CurrentDateTime;
        ImportBuf."Last Result" := 'Baixando ' + Url;
        ImportBuf.Modify();

        Count := Loader.LoadFromUrl(Url, ImportBuf."UF Filter", ImportBuf."Replace BR");

        ImportBuf."Last Url Used" := Url;
        ImportBuf."Load Status" := ImportBuf."Load Status"::Completed;
        ImportBuf."Load Finished" := CurrentDateTime;
        ImportBuf."Last Result" := Format(Count) + ' CEP(s) incluído(s) da base completa.';
        ImportBuf.RefreshCounters();
        ImportBuf.Modify();
    end;

    var
        NoUrlErr: Label 'Informe a URL do CSV da base de CEP antes de agendar a carga.';
}
