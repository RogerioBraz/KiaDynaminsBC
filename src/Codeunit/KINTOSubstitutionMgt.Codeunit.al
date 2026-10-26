codeunit 50174 "KINTO Substitution Mgt."
{
    // D5: substituição definitiva na linha do contrato. O substituto
    // herda as condições do substituído; saldos/cost center pertencem à
    // LINHA (não ao chassi). Dispositivo telemático transfere junto.

    var
        SameVehicleErr: Label 'Substitute vehicle must differ from the replaced one.';
        VehicleNotAvailableErr: Label 'Vehicle %1 is not Available (status: %2).';
        NotDeliveredErr: Label 'Substitution %1 is not Delivered yet.';
        ContractNotActiveErr: Label 'Contract %1 is not Active.';

    procedure CreateSubstitution(ContractNo: Code[20]; OldVehicleNo: Code[20]; NewVehicleNo: Code[20]; Reason: Text[250]; Provisional: Boolean): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        OldVehicle: Record "KINTO Inventory Vehicle";
        NewVehicle: Record "KINTO Inventory Vehicle";
        Sub: Record "KINTO Contract Substitution";
    begin
        Contract.Get(ContractNo);
        if Contract.Status <> Contract.Status::Active then
            Error(ContractNotActiveErr, ContractNo);
        if NewVehicleNo = OldVehicleNo then
            Error(SameVehicleErr);
        OldVehicle.Get(OldVehicleNo);
        NewVehicle.Get(NewVehicleNo);
        if NewVehicle.Status <> NewVehicle.Status::Available then
            Error(VehicleNotAvailableErr, NewVehicleNo, NewVehicle.Status);

        Sub.Init();
        Sub."Substitution No." := '';
        Sub."No. Series" := 'KINTO-SUB';
        Sub."Contract No." := ContractNo;
        Sub."Old Vehicle No." := OldVehicleNo;
        Sub."New Vehicle No." := NewVehicleNo;
        Sub.Reason := Reason;
        Sub."Is Provisional" := Provisional;
        Sub."Request Date" := WorkDate();
        Sub."Country Code" := Contract."Country Code";
        Sub.Insert(true);
        exit(Sub."Substitution No.");
    end;

    procedure DeliverSubstitution(var Sub: Record "KINTO Contract Substitution")
    var
        Contract: Record "KINTO Vehicle Contract";
        OldVehicle: Record "KINTO Inventory Vehicle";
        NewVehicle: Record "KINTO Inventory Vehicle";
        FleetMgt: Codeunit "KINTO Fleet Management";
        Device: Record "KINTO Telematic Device";
    begin
        if Sub.Status <> Sub.Status::Requested then
            exit;
        Contract.Get(Sub."Contract No.");

        // Novo veículo entra em contrato (ledger)
        FleetMgt.ChangeVehicleStatus(Sub."New Vehicle No.",
            "KINTO Vehicle Status"::"In Contract", '',
            StrSubstNo('Substitution %1 — delivered', Sub."Substitution No."));
        NewVehicle.Get(Sub."New Vehicle No.");
        NewVehicle."Last Contract No." := Sub."Contract No.";
        NewVehicle.Modify(true);

        // Velho veículo sai (Returned — vai p/ remarketing depois)
        OldVehicle.Get(Sub."Old Vehicle No.");
        FleetMgt.ChangeVehicleStatus(Sub."Old Vehicle No.",
            "KINTO Vehicle Status"::Returned, '',
            StrSubstNo('Substitution %1 — vehicle replaced', Sub."Substitution No."));

        // Transfere dispositivo telemático (se houver)
        Device.SetRange("Installed Vehicle No.", Sub."Old Vehicle No.");
        Device.SetRange(Status, Device.Status::Installed);
        if Device.FindFirst() then begin
            FleetMgt.RemoveDevice(Device."Device No.");
            FleetMgt.InstallDevice(Device."Device No.", Sub."New Vehicle No.", Sub."Contract No.");
            Sub."Device Transferred" := true;
        end;

        Sub.Status := Sub.Status::Delivered;
        Sub."Delivery Date" := WorkDate();
        Sub."Odometer at Delivery" := NewVehicle."Current Odometer";
        Sub.Modify(true);
    end;

    procedure CompleteSubstitution(var Sub: Record "KINTO Contract Substitution")
    var
        Contract: Record "KINTO Vehicle Contract";
    begin
        if Sub.Status <> Sub.Status::Delivered then
            Error(NotDeliveredErr, Sub."Substitution No.");
        Contract.Get(Sub."Contract No.");
        if Contract."Vehicle No." = Sub."Old Vehicle No." then begin
            Contract."Vehicle No." := Sub."New Vehicle No.";
            Contract.Modify(true);
        end;
        Sub.Status := Sub.Status::Completed;
        Sub."Completion Date" := WorkDate();
        Sub.Modify(true);
    end;
}
