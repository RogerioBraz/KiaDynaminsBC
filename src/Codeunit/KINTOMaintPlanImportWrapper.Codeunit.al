codeunit 50113 "KINTO MaintPlan Import Wrapper"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        MaintImport: Codeunit "KINTO Maint. Plan Excel Import";
        PlanID: Code[20];
        PlanDescription: Text[100];
        DiscountPct: Decimal;
    begin
        // Em produção, abrir uma dialog page para capturar PlanID, Description, Discount
        // Por enquanto, usa valores vazios e a codeunit pedirá os parâmetros
        MaintImport.ImportMaintenancePlanFromExcel(PlanID, PlanDescription, DiscountPct);
    end;
}