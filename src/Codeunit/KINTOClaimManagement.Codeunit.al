codeunit 50212 "KINTO Claim Management"
{
    // D3c: ciclo do sinistro — classificação em 5 trilhas, envio ao
    // segurador, decisão, pagamento, total >= 70% -> total destruction
    // (baixa do ativo fixo) + settlement com franquia/indenização.

    var
        NoPolicyErr: Label 'Vehicle %1 has no active insurance policy.';
        NotApprovedErr: Label 'Claim %1 is not Approved.';
        AlreadyPaidErr: Label 'Claim %1 already Paid.';
        NotTotalErr: Label 'Claim %1 is not Total Destruction.';

    procedure CreateClaim(ContractNo: Code[20]; ClaimClass: Enum "KINTO Claim Class Type"; ClaimDate: Date; Description: Text[250]): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        Policy: Record "KINTO Insurance Policy";
        Claim: Record "KINTO Claim";
        ClaimMgt: Codeunit "KINTO Claim Management";
    begin
        Contract.Get(ContractNo);
        Policy.SetRange("Contract No.", ContractNo);
        Policy.SetRange(Status, Policy.Status::Active);
        if Policy.IsEmpty() then
            Error(NoPolicyErr, Contract."Vehicle No.");
        Policy.FindFirst();

        Claim.Init();
        Claim."Claim No." := '';
        Claim."No. Series" := 'KINTO-CLM';
        Claim."Contract No." := ContractNo;
        Claim."Vehicle No." := Contract."Vehicle No.";
        Claim."Policy No." := Policy."Policy No.";
        Claim."Claim Class" := ClaimClass;
        Claim."Claim Date" := ClaimDate;
        Claim.Description := Description;
        Claim."Country Code" := Contract."Country Code";
        Claim.Status := Claim.Status::Open;
        Claim."Deductible Amount" := Policy."Deductible Amount";
        Claim.Insert(true);
        exit(Claim."Claim No.");
    end;

    procedure ClassifyClaim(var Claim: Record "KINTO Claim"; MarketValue: Decimal; DamageAmount: Decimal)
    begin
        Claim."Market Value" := MarketValue;
        Claim."Damage Amount" := DamageAmount;
        Claim.Classify();
        LogEvent(Claim."Claim No.", StrSubstNo('Classified: %1 (loss ratio %2%)', Claim."Claim Class", Claim."Loss Ratio %"));
    end;

    procedure SendToInsurer(var Claim: Record "KINTO Claim"; InsurerClaimNo: Text[50])
    begin
        if Claim.Status <> Claim.Status::Open then
            exit;
        Claim."Insurer Claim No." := InsurerClaimNo;
        Claim.Status := Claim.Status::"With Insurer";
        Claim.Modify(true);
        LogEvent(Claim."Claim No.", StrSubstNo('Sent to insurer (ref. %1)', InsurerClaimNo));
    end;

    procedure RecordInsurerDecision(var Claim: Record "KINTO Claim"; Approved: Boolean; Indemnity: Decimal)
    begin
        if Claim.Status <> Claim.Status::"With Insurer" then
            exit;
        if Approved then begin
            Claim.Status := Claim.Status::Approved;
            Claim."Indemnity Amount" := Indemnity;
        end else
            Claim.Status := Claim.Status::Denied;
        Claim.Modify(true);
        LogEvent(Claim."Claim No.", StrSubstNo('Insurer decision: %1 (indemnity %2)', Approved, Indemnity));
    end;

    procedure RegisterPayment(var Claim: Record "KINTO Claim")
    begin
        if Claim.Status <> Claim.Status::Approved then
            Error(NotApprovedErr, Claim."Claim No.");
        if Claim.Status = Claim.Status::Paid then
            Error(AlreadyPaidErr, Claim."Claim No.");
        Claim.Status := Claim.Status::Paid;
        Claim.Modify(true);
        LogEvent(Claim."Claim No.", 'Indemnity paid by insurer');

        // Total destruction >= 70% -> baixa do ativo fixo + settlement
        if Claim."Total Destruction" then
            ProcessTotalDestruction(Claim);
    end;

    local procedure ProcessTotalDestruction(var Claim: Record "KINTO Claim")
    var
        Contract: Record "KINTO Vehicle Contract";
        Vehicle: Record "KINTO Inventory Vehicle";
        FixedAsset: Record "Fixed Asset";
        SetMgt: Codeunit "KINTO Settlement Mgt.";
        SettlementNo: Code[20];
    begin
        // D3c: destruicao total >= 70% -> baixa do ativo fixo
        Contract.Get(Claim."Contract No.");
        Vehicle.Get(Claim."Vehicle No.");
        if Vehicle."Fixed Asset No." <> '' then begin
            if FixedAsset.Get(Vehicle."Fixed Asset No.") then begin
                FixedAsset.Blocked := true;
                FixedAsset.Modify(true);
            end;
            Claim."FA Written Off" := true;
        end;

        // Termina o contrato PRIMEIRO (veículo vai p/ Returned), depois
        // sobrescreve p/ Inactive (salvage — não volta p/ remarketing)
        if not (Contract.Status in [Contract.Status::Terminated, Contract.Status::Cancelled]) then
            Contract.Terminate(Contract."Termination Type"::"Total Loss", WorkDate());
        Vehicle.Get(Claim."Vehicle No.");
        Vehicle.Status := Vehicle.Status::Inactive;
        Vehicle.Modify(true);

        // Settlement tipo Insurance Recovery (indenização do segurador)
        SettlementNo := SetMgt.CreateSettlement(Claim."Contract No.", "KINTO Settlement Type"::"Insurance Recovery");
        Claim."Settlement No." := SettlementNo;
        Claim.Modify(true);
        LogEvent(Claim."Claim No.", StrSubstNo('Total destruction processed: FA written off, settlement %1', SettlementNo));
    end;

    procedure LogEvent(ClaimNo: Code[20]; Description: Text[250])
    var
        ClaimEvent: Record "KINTO Claim Event";
    begin
        ClaimEvent.Init();
        ClaimEvent."Claim No." := ClaimNo;
        ClaimEvent."Event Date" := CurrentDateTime;
        ClaimEvent.Description := Description;
        ClaimEvent."User ID" := CopyStr(UserId, 1, 50);
        ClaimEvent.Insert(false);
    end;
}
