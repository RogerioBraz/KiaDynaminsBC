codeunit 50206 "KINTO Termination Management"
{
    Permissions = tabledata "KINTO Vehicle Return" = RIMD,
                  tabledata "KINTO Damage Line" = RIMD,
                  tabledata "KINTO Recovery Case" = RIMD,
                  tabledata "KINTO Termination Setup" = RIMD,
                  tabledata "KINTO Vehicle Contract" = RIMD,
                  tabledata "KINTO Inventory Vehicle" = RIMD;

    var
        NoContractErr: Label 'Contract %1 is not terminated — terminate before creating the return.';
        ReturnExistsErr: Label 'Contract %1 already has a return document.';

    // ============================================================
    // FASE 5 — DEVOLUÇÃO (D5): terminação → return
    // ============================================================
    procedure CreateReturnFromContract(ContractNo: Code[20]; ReturnDate: Date; Location: Text[100]): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        VehicleReturn: Record "KINTO Vehicle Return";
        NotTermErr: Label 'Contract %1 is not terminated yet.';
    begin
        Contract.Get(ContractNo);
        if Contract.Status <> Contract.Status::Terminated then
            Error(NotTermErr, ContractNo);

        VehicleReturn.SetRange("Contract No.", ContractNo);
        if not VehicleReturn.IsEmpty() then
            Error(ReturnExistsErr, ContractNo);

        VehicleReturn.Init();
        VehicleReturn."Return No." := '';
        VehicleReturn."Contract No." := ContractNo;
        VehicleReturn."Vehicle No." := Contract."Vehicle No.";
        VehicleReturn."Customer No." := Contract."Customer No.";
        VehicleReturn."Currency Code" := Contract."Currency Code";
        VehicleReturn."Return Date" := ReturnDate;
        VehicleReturn."Return Location" := CopyStr(Location, 1, MaxStrLen(VehicleReturn."Return Location"));
        VehicleReturn.Status := VehicleReturn.Status::Scheduled;
        VehicleReturn.Insert(true);
        exit(VehicleReturn."Return No.");
    end;

    procedure StartReturn(var VehicleReturn: Record "KINTO Vehicle Return")
    var
        NotSchedErr: Label 'Return %1 is not scheduled.';
    begin
        if VehicleReturn.Status <> VehicleReturn.Status::Scheduled then
            Error(NotSchedErr, VehicleReturn."Return No.");
        VehicleReturn.Status := VehicleReturn.Status::"In Progress";
        VehicleReturn.Modify(true);
    end;

    // ============================================================
    // FASE 5 — TOTAL LOSS (D5): salvage + tarefa de cotação/settlement
    // ============================================================
    procedure HandleTotalLoss(var Contract: Record "KINTO Vehicle Contract")
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        RecoveryCase: Record "KINTO Recovery Case";
        NotLossErr: Label 'Contract %1 termination type is not Total Loss/Theft.';
    begin
        if not (Contract."Termination Type" in [Contract."Termination Type"::"Total Loss",
            Contract."Termination Type"::Theft])
        then
            Error(NotLossErr, Contract."Contract No.");

        // Status salvage na Unit (D5): veículo sai de circulação
        if Vehicle.Get(Contract."Vehicle No.") then begin
            Vehicle.Status := Vehicle.Status::Inactive;
            Vehicle.Modify(true);
        end;

        // Abre recovery case p/ rastrear o sinistro (BR: tarefa de nova cotação)
        RecoveryCase.Init();
        RecoveryCase."Case No." := '';
        RecoveryCase."Contract No." := Contract."Contract No.";
        RecoveryCase."Vehicle No." := Contract."Vehicle No.";
        RecoveryCase."Customer No." := Contract."Customer No.";
        RecoveryCase."Case Date" := WorkDate();
        RecoveryCase."Risk Level" := RecoveryCase."Risk Level"::High;
        RecoveryCase.Insert(true);
    end;

    // ============================================================
    // FASE 5 — RECOVERY: abrir caso manual
    // ============================================================
    procedure CreateRecoveryCase(ContractNo: Code[20]): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        RecoveryCase: Record "KINTO Recovery Case";
        ExistsErr: Label 'Contract %1 already has an open recovery case.';
    begin
        Contract.Get(ContractNo);
        RecoveryCase.SetRange("Contract No.", ContractNo);
        RecoveryCase.SetFilter(Status, '%1|%2', RecoveryCase.Status::Open, RecoveryCase.Status::InNegotiation);
        if not RecoveryCase.IsEmpty() then
            Error(ExistsErr, ContractNo);

        RecoveryCase.Init();
        RecoveryCase."Case No." := '';
        RecoveryCase."Contract No." := ContractNo;
        RecoveryCase."Vehicle No." := Contract."Vehicle No.";
        RecoveryCase."Customer No." := Contract."Customer No.";
        RecoveryCase."Case Date" := WorkDate();
        RecoveryCase.Insert(true);
        RecoveryCase.ClassifyRisk();
        exit(RecoveryCase."Case No.");
    end;

    // ============================================================
    // FASE 5 — JOB: reclassificar casos de recovery abertos (aging)
    // ============================================================
    procedure ReclassifyOpenRecoveryCases(): Integer
    var
        RecoveryCase: Record "KINTO Recovery Case";
        Count: Integer;
    begin
        RecoveryCase.SetFilter(Status, '%1|%2', RecoveryCase.Status::Open, RecoveryCase.Status::InNegotiation);
        if RecoveryCase.FindSet() then
            repeat
                RecoveryCase.ClassifyRisk();
                Count += 1;
            until RecoveryCase.Next() = 0;
        exit(Count);
    end;

    // ============================================================
    // FASE 5 — SETUP PADRÃO (chamado pelo install)
    // ============================================================
    procedure CreateDefaultSetup()
    var
        Setup: Record "KINTO Termination Setup";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup.Insert(true);
        end;

        CreateNoSeries('KINTO-RET', 'KINTO Vehicle Return Numbers', 'R-00001', 'R-99999');
        CreateNoSeries('KINTO-REC', 'KINTO Recovery Case Numbers', 'RC-00001', 'RC-99999');

        if Setup."Return Nos." = '' then begin
            Setup."Return Nos." := 'KINTO-RET';
            Setup."Recovery Nos." := 'KINTO-REC';
            Setup.Modify(true);
        end;
    end;

    local procedure CreateNoSeries(Code: Code[20]; Description: Text[100]; StartNo: Code[20]; EndNo: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(Code) then
            exit;
        NoSeries.Init();
        NoSeries.Code := Code;
        NoSeries.Description := Description;
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := StartNo;
        NoSeriesLine."Ending No." := EndNo;
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);
    end;
}