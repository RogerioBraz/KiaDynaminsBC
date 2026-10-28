codeunit 60018 "KINTO Downtime Days Recalc"
{
    Subtype = Upgrade;

    // ============================================================
    // 1.2.0.5 — recalculo dos Dias Perdidos de indisponibilidade.
    //
    // Ate a 1.2.0.2 o calculo dividia a diferenca entre as datas por
    // 86.400 (numero de SEGUNDOS de um dia). No AL a data/hora conta
    // MILISSEGUNDOS, entao o divisor certo e 86.400.000: o valor saia
    // 1.000x maior (parada de 7 minutos virava "5 dias").
    //
    // Corrigido o codigo na 1.2.0.3, mas os registros JA GRAVADOS
    // continuaram errados: CalcDays roda em OnInsert/OnModify, nao ha
    // recalculo retroativo. Este upgrade acerta o historico uma vez.
    //
    // Idempotente: so toca nas linhas cujo valor gravado difere do
    // calculo correto, entao reexecutar nao muda nada.
    // ============================================================
    trigger OnUpgradePerCompany()
    var
        Downtime: Record "KINTO Vehicle Downtime";
        Corrected: Integer;
    begin
        if Downtime.IsEmpty() then
            exit;
        Downtime.FindSet();
        repeat
            if (Downtime."Start DateTime" <> 0DT) and (Downtime."End DateTime" <> 0DT) then
                if Downtime."Days Lost" <> Round((Downtime."End DateTime" - Downtime."Start DateTime") / 86400000, 0.01) then begin
                    Downtime.CalcDays();
                    Downtime.Modify(false);
                    Corrected += 1;
                end;
        until Downtime.Next() = 0;
    end;
}
