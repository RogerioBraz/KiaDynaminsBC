codeunit 60019 "KINTO Lifecycle Job Queue"
{
    TableNo = "Job Queue Entry";

    // ============================================================
    // Wrapper de Job Queue para o ciclo de vida do contrato.
    //
    // POR QUE EXISTE: o codeunit 60001 (KINTO Contract Lifecycle Mgt.) tem a
    // rotina RunContractLifecycle implementada desde a D1 — aviso previo,
    // expiracao, renovacao e log — mas NENHUM objeto a chamava. Nem pagina, nem
    // Job Queue. Na pratica o ciclo de vida nunca rodava: o Log de Expiracao
    // ficava vazio em producao e o aviso ao cliente nunca saia.
    //
    // Agendar: Job Queue Entry apontando para este codeunit, periodicidade
    // diaria. Idempotente — cada acao do log e gravada uma vez por contrato.
    // ============================================================
    trigger OnRun()
    var
        Lifecycle: Codeunit "KINTO Contract Lifecycle Mgt.";
    begin
        Lifecycle.RunContractLifecycle(WorkDate());
    end;
}
