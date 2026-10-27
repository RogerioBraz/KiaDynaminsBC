codeunit 60002 "KINTO Downtime Mgt."
{
    // ============================================================
    // D3 — DOWNTIME -> SERVICE CREDIT + SLA
    // Converte dias de indisponibilidade em credito ao cliente
    // (via KINTO Service Credit Mgt.) e apura violacoes de SLA.
    // ============================================================

    procedure CreateServiceCredits(AsOfDate: Date): Integer
    var
        Downtime: Record "KINTO Vehicle Downtime";
        Contract: Record "KINTO Vehicle Contract";
        CreditMgt: Codeunit "KINTO Service Credit Mgt.";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
        BillingMonth: Date;
        Created: Integer;
        Days: Decimal;
        CreditAmount: Decimal;
    begin
        BillingMonth := CalcDate('<-CM>', AsOfDate);
        Downtime.Reset();
        Downtime.SetRange("Service Credit Created", false);
        Downtime.SetFilter("Chargeable to KINTO", '%1', true);
        Downtime.SetFilter("End DateTime", '<>%1', 0DT);
        if Downtime.FindSet() then
            repeat
                Days := Downtime."Days Lost";
                if Contract.Get(Downtime."Contract No.") and (Contract.Status = Contract.Status::Active) and
                   (Days > 0) and HasBilling(Contract."Contract No.", BillingMonth) then begin
                    CreditAmount := CreditMgt.RequestServiceCredit(Contract."Contract No.", BillingMonth,
                        Days, StrSubstNo('Downtime %1 (%2 days)', Downtime.Reason, Days));
                    if CreditAmount > 0 then begin
                        Downtime."Service Credit Created" := true;
                        Downtime.Modify(false);
                        Created += 1;
                    end;
                end;
            until Downtime.Next() = 0;
        exit(Created);
    end;

    local procedure HasBilling(ContractNo: Code[20]; BillingMonth: Date): Boolean
    var
        BillingLine: Record "KINTO Billing Line";
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Billing Month", BillingMonth);
        BillingLine.SetFilter(Status, '<>%1', BillingLine.Status::Cancelled);
        exit(not BillingLine.IsEmpty());
    end;

    // ============================================================
    // SLA — apuracao de violacoes de tempo de resposta/resolucao
    // ============================================================
    procedure CheckSLAViolations(AsOfDate: Date): Integer
    var
        Ticket: Record "KINTO Maintenance Ticket";
        SLA: Record "KINTO Service Level";
        Violation: Record "KINTO SLA Violation";
        ViolationType: Enum "KINTO SLA Violation Type";
        HoursElapsed: Decimal;
        Count: Integer;
    begin
        Ticket.Reset();
        Ticket.SetFilter(Status, '%1|%2', Ticket.Status::Open, Ticket.Status::"In Execution");
        if Ticket.FindSet() then
            repeat
                if SLA.Get(Ticket."Contract No.") and SLA.Active then begin
                    // Horas desde a abertura do ticket
                    HoursElapsed := Round((CurrentDateTime - Ticket."Created DateTime") / 3600, 0.01);
                    if (SLA."Resolution Time (hours)" > 0) and (HoursElapsed > SLA."Resolution Time (hours)") then
                        if RegisterViolation(Ticket, SLA, HoursElapsed, ViolationType::"Resolution Breach") then
                            Count += 1;
                end;
            until Ticket.Next() = 0;
        exit(Count);
    end;

    local procedure RegisterViolation(var Ticket: Record "KINTO Maintenance Ticket"; var SLA: Record "KINTO Service Level";
        HoursElapsed: Decimal; ViolationType: Enum "KINTO SLA Violation Type"): Boolean
    var
        Violation: Record "KINTO SLA Violation";
        Penalty: Decimal;
    begin
        Violation.SetRange("Ticket No.", Ticket."Ticket No.");
        Violation.SetRange("Violation Type", ViolationType);
        if not Violation.IsEmpty() then
            exit(false);

        Penalty := SLA."Penalty Per Hour" * (HoursElapsed - SLA."Resolution Time (hours)");
        Violation.Init();
        Violation."Ticket No." := Ticket."Ticket No.";
        Violation."Contract No." := Ticket."Contract No.";
        Violation."Violation Type" := ViolationType;
        Violation."Detected DateTime" := CurrentDateTime;
        Violation."Hours Elapsed" := HoursElapsed;
        Violation."SLA Target Hours" := SLA."Resolution Time (hours)";
        Violation."Penalty Amount" := Round(Penalty, 0.01);
        Violation.Insert(false);
        exit(true);
    end;
}
