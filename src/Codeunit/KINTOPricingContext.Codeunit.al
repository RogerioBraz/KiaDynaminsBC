codeunit 50158 "KINTO Pricing Context"
{
    // Contexto de execução do pricing: quando o engine roda programaticamente
    // (runner JQ, seed demo, testes), os guards de OnModify do Quote Header
    // e do Quote Item NÃO devem resetar os resultados — o engine controla o
    // ciclo de status. Na UI, a flag fica off e os guards protegem o usuário
    // de editar uma cotação calculada sem recalcular.

    SingleInstance = true;

    var
        SuppressGuards: Boolean;

    procedure BeginPricing()
    begin
        SuppressGuards := true;
    end;

    procedure EndPricing()
    begin
        SuppressGuards := false;
    end;

    procedure GuardsSuppressed(): Boolean
    begin
        exit(SuppressGuards);
    end;
}
