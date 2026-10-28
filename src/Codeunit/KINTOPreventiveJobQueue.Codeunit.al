codeunit 60020 "KINTO Preventive Job Queue"
{
    TableNo = "Job Queue Entry";

    // ============================================================
    // Wrapper de Job Queue para a manutencao preventiva.
    //
    // POR QUE EXISTE: o codeunit 60000 (KINTO Preventive Maint. Mgt.) tem
    // GeneratePreventiveTickets implementada desde a D1 — compara odometro e
    // ultima data preventiva, abre o ticket e reagenda — mas nenhum objeto a
    // chamava. O manual (16.1) descreve a rotina como "roda pelo Job Queue";
    // nao havia Job Queue nenhum para ela.
    //
    // Agendar: Job Queue Entry apontando para este codeunit, periodicidade
    // diaria. Idempotente — nao abre segundo preventivo se ja existe um aberto.
    // ============================================================
    trigger OnRun()
    var
        Preventive: Codeunit "KINTO Preventive Maint. Mgt.";
    begin
        Preventive.GeneratePreventiveTickets(WorkDate());
    end;
}
