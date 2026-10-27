table 50210 "KINTO Maintenance Ticket"
{
    Caption = 'KINTO Maintenance Ticket';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Maintenance Ticket List";
    DrillDownPageId = "KINTO Maintenance Ticket Card";

    fields
    {
        field(1; "Ticket No."; Code[20]) { Caption = 'Ticket No.'; }
        field(2; "Ticket Type"; Enum "KINTO Maint Ticket Type") { Caption = 'Ticket Type'; }
        field(3; Status; Enum "KINTO Maint Ticket Status") { Caption = 'Status'; }
        field(4; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(5; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(6; "License Plate"; Text[20])
        {
            Caption = 'License Plate';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Inventory Vehicle"."License Plate" where("Vehicle No." = field("Vehicle No.")));
            Editable = false;
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(8; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No. (Dealer)';
            TableRelation = Vendor;
        }
        field(9; "Service Date"; Date) { Caption = 'Service Date'; }
        field(10; "Odometer at Service"; Decimal) { Caption = 'Odometer (km)'; DecimalPlaces = 0 : 1; }
        field(11; "Engine Hours"; Decimal) { Caption = 'Engine Hours'; DecimalPlaces = 0 : 1; }
        field(12; Description; Text[250]) { Caption = 'Description'; }
        field(13; "Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            FieldClass = FlowField;
            CalcFormula = sum("KINTO Maint Ticket Line".Amount where("Ticket No." = field("Ticket No.")));
            Editable = false;
        }
        field(14; "Total Billable"; Decimal)
        {
            Caption = 'Total Billable to Customer';
            FieldClass = FlowField;
            CalcFormula = sum("KINTO Maint Ticket Line".Amount where("Ticket No." = field("Ticket No."), "Bill to Customer" = const(true)));
            Editable = false;
        }
        field(15; "Pool Consumed"; Boolean) { Caption = 'Pool Consumed'; Editable = false; }
        field(16; "Pool Entry No."; Integer) { Caption = 'Pool Entry No.'; Editable = false; }
        field(17; "Pre-Approved"; Boolean) { Caption = 'Pre-Approved'; Editable = false; }
        field(18; "Approval Request ID"; Code[20]) { Caption = 'Approval Request ID'; Editable = false; }
        field(19; "Billing Month"; Date) { Caption = 'Billing Month'; Editable = false; }
        field(20; "Billing Line Entry No."; Integer) { Caption = 'Billing Line Entry No.'; Editable = false; }
        field(21; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.';
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Invoice));
        }
        field(22; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(23; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(24; "Closed DateTime"; DateTime) { Caption = 'Closed DateTime'; Editable = false; }
        field(25; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(26; "Warranty Status"; Option)
        {
            Caption = 'Warranty Status';
            OptionMembers = Unknown,InWarranty,OutOfWarranty;
        }
        field(27; "Sequence OK"; Boolean) { Caption = 'Revision Sequence OK'; Editable = false; }
    }

    keys
    {
        key(PK; "Ticket No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
        key(Idx2; "Vehicle No.", "Service Date") { }
        key(Idx3; Status) { }
        key(Idx4; "Vendor No.") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if Status = Status::Open then
            Status := Status::Open;

        if "Ticket No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Ticket Series', 'KINTO-TICK');
            "Ticket No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    // ============================================================
    // CICLO DO TICKET (D1 PP-01/PP-02/PP-03)
    // ============================================================
    procedure StartAnalysis()
    var
        NotOpenErr: Label 'Ticket %1 is not open.';
    begin
        if Status <> Status::Open then
            Error(NotOpenErr, "Ticket No.");
        TestField("Vehicle No.");
        Status := Status::"In Analysis";
        Modify(true);
    end;

    procedure SubmitForApproval()
    var
        NotInAnalysisErr: Label 'Ticket %1 is not in analysis.';
    begin
        if Status <> Status::"In Analysis" then
            Error(NotInAnalysisErr, "Ticket No.");
        CalcLineTotals();
        // Pré-aprovação automática (RN-034 do D1): valor <= HH rate × horas esperadas
        // é tratado na validação; aqui o fluxo correto exige aprovação se não pré-aprovado.
        Status := Status::"Pending Approval";
        Modify(true);
    end;

    procedure Approve()
    var
        NotPendingErr: Label 'Ticket %1 is not pending approval.';
    begin
        if Status <> Status::"Pending Approval" then
            Error(NotPendingErr, "Ticket No.");
        Status := Status::Approved;
        Modify(true);
    end;

    procedure Reject(Reason: Text[250])
    var
        NotPendingErr: Label 'Ticket %1 is not pending approval.';
    begin
        if Status <> Status::"Pending Approval" then
            Error(NotPendingErr, "Ticket No.");
        Status := Status::Rejected;
        Description := CopyStr(Description + ' | REJECTED: ' + Reason, 1, MaxStrLen(Description));
        RestorePoolIfConsumed();
        Modify(true);
    end;

    procedure StartExecution()
    var
        NotApprovedErr: Label 'Ticket %1 is not approved.';
    begin
        if Status <> Status::Approved then
            Error(NotApprovedErr, "Ticket No.");
        Status := Status::"In Execution";
        Modify(true);
    end;

    procedure CloseTicket()
    var
        NotExecutingErr: Label 'Ticket %1 is not in execution.';
    begin
        if Status <> Status::"In Execution" then
            Error(NotExecutingErr, "Ticket No.");
        CalcLineTotals();
        Status := Status::"Pending Invoice";
        "Closed DateTime" := CurrentDateTime;
        Modify(true);
    end;

    procedure CancelTicket()
    var
        ClosedErr: Label 'Ticket %1 is closed/invoiced and cannot be cancelled.';
    begin
        if Status in [Status::Closed, Status::"Pending Invoice"] then
            Error(ClosedErr, "Ticket No.");
        // EXC-16 do D1: saldo contratual consumido em ticket cancelado deve ser restaurado
        RestorePoolIfConsumed();
        Status := Status::Cancelled;
        Modify(true);
    end;

    local procedure CalcLineTotals()
    begin
        // Totais são FlowFields; aqui apenas garante consistência das linhas
        TestField("Vehicle No.");
    end;

    local procedure RestorePoolIfConsumed()
    var
        PoolMgt: Codeunit "KINTO Pool Management";
    begin
        if "Pool Consumed" and ("Pool Entry No." <> 0) then begin
            PoolMgt.RestoreConsumption("Pool Entry No.", "Ticket No.", 'Ticket cancelled/rejected');
            "Pool Consumed" := false;
        end;
    end;

    // ============================================================
    // POOL (RN-036 do D1 + EXC-16)
    // ============================================================
    procedure ConsumePool(PoolTypeCode: Code[20]; Quantity: Decimal)
    var
        PoolMgt: Codeunit "KINTO Pool Management";
        EntryNo: Integer;
        AlreadyErr: Label 'Ticket %1 already consumed pool.';
    begin
        if "Pool Consumed" then
            Error(AlreadyErr, "Ticket No.");
        TestField("Contract No.");
        EntryNo := PoolMgt.Consume("Contract No.", PoolTypeCode, "Vehicle No.", Quantity,
            1, "Ticket No.", StrSubstNo('Ticket %1', "Ticket No."));
        "Pool Consumed" := true;
        "Pool Entry No." := EntryNo;
        Modify(true);
    end;

    // ============================================================
    // VALIDAÇÃO NATIVA (D1 PP-05 — substitui bot Blue Prism)
    // ============================================================
    procedure ValidateTicket(): Boolean
    var
        TicketLine: Record "KINTO Maint Ticket Line";
        PrevTicket: Record "KINTO Maintenance Ticket";
        ErrList: Text;
        SequenceBroken: Boolean;
    begin
        ErrList := '';
        SequenceBroken := false;

        // 1. Sequência de revisões por placa (RN-013): não permite salto nem re-upload
        PrevTicket.SetRange("Vehicle No.", "Vehicle No.");
        PrevTicket.SetFilter(Status, '<>%1&<>%2', PrevTicket.Status::Cancelled, PrevTicket.Status::Rejected);
        PrevTicket.SetFilter("Ticket No.", '<>%1', "Ticket No.");
        if PrevTicket.FindLast() then
            if ("Odometer at Service" > 0) and (PrevTicket."Odometer at Service" > 0) then
                if "Odometer at Service" <= PrevTicket."Odometer at Service" then
                    SequenceBroken := true;
        "Sequence OK" := not SequenceBroken;
        if SequenceBroken then
            ErrList += 'Odometer not ahead of last ticket; ';

        // 2. Linhas com valor
        TicketLine.SetRange("Ticket No.", "Ticket No.");
        if TicketLine.IsEmpty() then
            ErrList += 'No service lines; ';

        Modify(true);
        exit(ErrList = '');
    end;
}