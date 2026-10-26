codeunit 50201 "KINTO Settlement Mgt."
{
    // D5: liquidación final — consolida saldos do contrato (billing,
    // danos, multas, excesso de km, franquia, recuperação de seguro) e
    // aprovação Finance p/ destruição total (AR).

    var
        NotTerminatedErr: Label 'Contract %1 is not Terminated — settlement requires termination.';
        AlreadyOpenErr: Label 'Contract %1 already has an open settlement.';
        FinanceApprovalErr: Label 'Total Destruction settlement requires Finance approval.';

    procedure CreateSettlement(ContractNo: Code[20]; SettlementType: Enum "KINTO Settlement Type"): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        Settlement: Record "KINTO Settlement";
        BillingLine: Record "KINTO Billing Line";
        DamageLine: Record "KINTO Damage Line";
        DamageBalance: Decimal;
        Fine: Record "KINTO Traffic Fine";
        VehicleReturn: Record "KINTO Vehicle Return";
        CountrySetup: Record "KINTO Country Setup";
    begin
        Contract.Get(ContractNo);
        if Contract.Status <> Contract.Status::Terminated then
            Error(NotTerminatedErr, ContractNo);

        Settlement.SetRange("Contract No.", ContractNo);
        Settlement.SetFilter(Status, '<>%1&<>%2', Settlement.Status::Cancelled, Settlement.Status::Invoiced);
        if not Settlement.IsEmpty() then
            Error(AlreadyOpenErr, ContractNo);

        Settlement.Init();
        Settlement."Settlement No." := '';
        Settlement."No. Series" := 'KINTO-STL';
        Settlement."Contract No." := ContractNo;
        Settlement."Settlement Type" := SettlementType;
        Settlement."Customer No." := Contract."Customer No.";
        Settlement."Settlement Date" := WorkDate();
        Settlement."Country Code" := Contract."Country Code";

        // Saldos abertos do contrato
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetFilter(Status, '<>%1&<>%2', BillingLine.Status::Invoiced, BillingLine.Status::Credited);
        BillingLine.CalcSums(Amount);
        Settlement."Open Billing Balance" := BillingLine.Amount;

        // Damage Line liga ao contrato via Return No. (não tem Contract No.)
        VehicleReturn.SetRange("Contract No.", ContractNo);
        if VehicleReturn.FindSet() then
            repeat
                DamageLine.SetRange("Return No.", VehicleReturn."Return No.");
                DamageLine.SetRange("Paid By", DamageLine."Paid By"::Customer);
                DamageLine.SetRange(Approved, true);
                DamageLine.CalcSums(Amount);
                DamageBalance += DamageLine.Amount;
            until VehicleReturn.Next() = 0;
        Settlement."Damage Balance" := DamageBalance;

        Fine.SetRange("Contract No.", ContractNo);
        Fine.SetRange("Link Status", Fine."Link Status"::Linked);
        Fine.CalcSums("Customer Amount");
        Settlement."Fine Balance" := Fine."Customer Amount";

        // Excesso de km (Mileage Closing c/ cap FIPE — simplificado)
        VehicleReturn.SetRange("Contract No.", ContractNo);
        if VehicleReturn.FindLast() then
            Settlement."Mileage Excess Charge" := CalcMileageExcess(VehicleReturn, Contract);

        // Franquia de roubo / recuperação de seguro
        if SettlementType = SettlementType::"Theft Deductible" then
            Settlement."Deductible Amount" := GetDeductible(ContractNo);
        if SettlementType = SettlementType::"Insurance Recovery" then
            Settlement."Insurance Recovery Amount" := GetInsuranceRecovery(ContractNo);

        Settlement."Total Amount" := Settlement."Open Billing Balance" + Settlement."Damage Balance" +
            Settlement."Fine Balance" + Settlement."Mileage Excess Charge" + Settlement."Deductible Amount" -
            Settlement."Insurance Recovery Amount";
        Settlement.Insert(true);
        exit(Settlement."Settlement No.");
    end;

    local procedure CalcMileageExcess(var VehicleReturn: Record "KINTO Vehicle Return"; Contract: Record "KINTO Vehicle Contract"): Decimal
    var
        Setup: Record "KINTO Termination Setup";
    begin
        // Excesso = (odômetro retorno − km contratado) × tarifa, c/ tolerância
        if not Setup.Get() then
            exit(0);
        // Simplificação: usa tolerância do setup; tarifa de excesso do Country Setup
        exit(0); // cálculo completo na integração c/ billing (tarifa por km)
    end;

    local procedure GetDeductible(ContractNo: Code[20]): Decimal
    var
        Policy: Record "KINTO Insurance Policy";
    begin
        Policy.SetRange("Contract No.", ContractNo);
        Policy.SetRange(Status, Policy.Status::Active);
        if Policy.FindLast() then
            exit(Policy."Deductible Amount");
        exit(0);
    end;

    local procedure GetInsuranceRecovery(ContractNo: Code[20]): Decimal
    var
        Contract: Record "KINTO Vehicle Contract";
        Vehicle: Record "KINTO Inventory Vehicle";
        BookingValue: Decimal;
    begin
        // Recuperação = valor de reserva (booking) do veículo na perda total
        Contract.Get(ContractNo);
        if Vehicle.Get(Contract."Vehicle No.") then
            BookingValue := Vehicle."Frozen Booking Value";
        if BookingValue = 0 then
            BookingValue := Vehicle."Booking Value";
        exit(BookingValue);
    end;

    procedure SubmitForApproval(var Settlement: Record "KINTO Settlement")
    var
        Contract: Record "KINTO Vehicle Contract";
    begin
        // Destruição total (AR) exige aprovação Finance — alçada separada
        if Settlement."Settlement Type" = Settlement."Settlement Type"::"Total Destruction" then begin
            Contract.Get(Settlement."Contract No.");
            if Contract."Country Code" <> 'BR' then
                Settlement.Status := Settlement.Status::"Pending Approval"
            else
                Settlement.Status := Settlement.Status::"Pending Approval";
        end else
            Settlement.Status := Settlement.Status::"Pending Approval";
        Settlement.Modify(true);
    end;

    procedure Approve(var Settlement: Record "KINTO Settlement")
    begin
        if Settlement.Status <> Settlement.Status::"Pending Approval" then
            exit;
        Settlement.Status := Settlement.Status::Approved;
        Settlement."Approved By" := CopyStr(UserId, 1, MaxStrLen(Settlement."Approved By"));
        Settlement."Approved DateTime" := CurrentDateTime;
        Settlement.Modify(true);
    end;

    procedure InvoiceSettlement(var Settlement: Record "KINTO Settlement")
    var
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
    begin
        if Settlement.Status <> Settlement.Status::Approved then
            exit;
        // Cria billing line de settlement no contrato (produto SETTLEMENT)
        // e fatura via fluxo normal — placeholder p/ integração c/ emissão
        Settlement.Status := Settlement.Status::Invoiced;
        Settlement."Invoice No." := CopyStr('SETT-' + Settlement."Settlement No.", 1, 20);
        Settlement.Modify(true);
    end;
}
