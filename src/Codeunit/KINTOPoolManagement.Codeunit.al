codeunit 50203 "KINTO Pool Management"
{
    Permissions = tabledata "KINTO Pool Ledger Entry" = RIMD,
                  tabledata "KINTO Pool Type" = R;

    // ============================================================
    // POOL LEDGER (RN-036 do D1: saldos compartilháveis; EXC-16: restauração)
    // ============================================================
    procedure Consume(ContractNo: Code[20]; PoolTypeCode: Code[20]; VehicleNo: Code[20]; Quantity: Decimal; MonetaryAmount: Decimal; SourceNo: Code[20]; Description: Text[100]): Integer
    var
        PoolType: Record "KINTO Pool Type";
        PoolEntry: Record "KINTO Pool Ledger Entry";
        Balance: Decimal;
        InsufficientErr: Label 'Insufficient pool balance for %1 on contract %2. Available: %3, requested: %4.';
    begin
        PoolType.Get(PoolTypeCode);
        PoolType.TestField(Blocked, false);

        Balance := GetBalance(ContractNo, PoolTypeCode);
        if PoolType.Monetary then begin
            if Balance < MonetaryAmount then
                Error(InsufficientErr, PoolTypeCode, ContractNo, Balance, MonetaryAmount);
        end else
            if Balance < Quantity then
                Error(InsufficientErr, PoolTypeCode, ContractNo, Balance, Quantity);

        PoolEntry.Init();
        PoolEntry."Contract No." := ContractNo;
        PoolEntry."Pool Type" := PoolTypeCode;
        if not PoolType."Shared Across Vehicles" then
            PoolEntry."Vehicle No." := VehicleNo;
        PoolEntry."Entry Type" := PoolEntry."Entry Type"::Consumption;
        PoolEntry.Quantity := -Quantity;
        PoolEntry."Monetary Amount" := -MonetaryAmount;
        PoolEntry."Entry Date" := WorkDate();
        PoolEntry."Source Type" := PoolEntry."Source Type"::Ticket;
        PoolEntry."Source No." := SourceNo;
        PoolEntry.Description := CopyStr(Description, 1, MaxStrLen(PoolEntry.Description));
        PoolEntry.Insert(true);
        exit(PoolEntry."Entry No.");
    end;

    procedure RestoreConsumption(ConsumptionEntryNo: Integer; SourceNo: Code[20]; Reason: Text[100])
    var
        PoolEntry: Record "KINTO Pool Ledger Entry";
        RestoreEntry: Record "KINTO Pool Ledger Entry";
        AlreadyErr: Label 'Pool entry %1 is not a consumption or is already restored.';
    begin
        PoolEntry.Get(ConsumptionEntryNo);
        if PoolEntry."Entry Type" <> PoolEntry."Entry Type"::Consumption then
            Error(AlreadyErr, ConsumptionEntryNo);
        if PoolEntry."Reversal Of Entry No." <> 0 then
            Error(AlreadyErr, ConsumptionEntryNo);

        RestoreEntry.Init();
        RestoreEntry."Contract No." := PoolEntry."Contract No.";
        RestoreEntry."Pool Type" := PoolEntry."Pool Type";
        RestoreEntry."Vehicle No." := PoolEntry."Vehicle No.";
        RestoreEntry."Entry Type" := RestoreEntry."Entry Type"::Restoration;
        RestoreEntry.Quantity := -PoolEntry.Quantity; // positivo de volta
        RestoreEntry."Monetary Amount" := -PoolEntry."Monetary Amount";
        RestoreEntry."Entry Date" := WorkDate();
        RestoreEntry."Source Type" := RestoreEntry."Source Type"::Ticket;
        RestoreEntry."Source No." := SourceNo;
        RestoreEntry.Description := CopyStr(Reason, 1, MaxStrLen(RestoreEntry.Description));
        RestoreEntry."Reversal Of Entry No." := ConsumptionEntryNo;
        RestoreEntry.Insert(true);

        PoolEntry."Reversal Of Entry No." := RestoreEntry."Entry No.";
        PoolEntry.Modify(true);
    end;

    procedure Grant(ContractNo: Code[20]; PoolTypeCode: Code[20]; Quantity: Decimal; MonetaryAmount: Decimal; Description: Text[100]): Integer
    var
        PoolEntry: Record "KINTO Pool Ledger Entry";
    begin
        PoolEntry.Init();
        PoolEntry."Contract No." := ContractNo;
        PoolEntry."Pool Type" := PoolTypeCode;
        PoolEntry."Entry Type" := PoolEntry."Entry Type"::Grant;
        PoolEntry.Quantity := Quantity;
        PoolEntry."Monetary Amount" := MonetaryAmount;
        PoolEntry."Entry Date" := WorkDate();
        PoolEntry."Source Type" := PoolEntry."Source Type"::Contract;
        PoolEntry.Description := CopyStr(Description, 1, MaxStrLen(PoolEntry.Description));
        PoolEntry.Insert(true);
        exit(PoolEntry."Entry No.");
    end;

    procedure GetBalance(ContractNo: Code[20]; PoolTypeCode: Code[20]): Decimal
    var
        PoolEntry: Record "KINTO Pool Ledger Entry";
        PoolType: Record "KINTO Pool Type";
        Total: Decimal;
    begin
        if PoolType.Get(PoolTypeCode) and PoolType.Monetary then begin
            PoolEntry.SetRange("Contract No.", ContractNo);
            PoolEntry.SetRange("Pool Type", PoolTypeCode);
            if PoolEntry.FindSet() then
                repeat
                    Total += PoolEntry."Monetary Amount";
                until PoolEntry.Next() = 0;
        end else begin
            PoolEntry.SetRange("Contract No.", ContractNo);
            PoolEntry.SetRange("Pool Type", PoolTypeCode);
            if PoolEntry.FindSet() then
                repeat
                    Total += PoolEntry.Quantity;
                until PoolEntry.Next() = 0;
        end;
        exit(Total);
    end;
}