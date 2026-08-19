codeunit 50112 "KINTO RV Matrix Templ Download"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        RVImport: Codeunit "KINTO RV Matrix Excel Import";
    begin
        RVImport.DownloadTemplate();
    end;
}