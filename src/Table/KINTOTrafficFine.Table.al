table 50300 "KINTO Traffic Fine"
{
    Caption = 'KINTO Traffic Fine';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Traffic Fine List";
    DrillDownPageId = "KINTO Traffic Fine Card";

    fields
    {
        field(1; "Fine No."; Code[20]) { Caption = 'Fine No.'; }
        field(2; "License Plate"; Text[20])
        {
            Caption = 'License Plate';
            TableRelation = "KINTO Inventory Vehicle"."License Plate";
        }
        field(3; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(4; "AIIP Code"; Code[30]) { Caption = 'AIIP Code (infraction)'; }
        field(5; "Issuing Authority Code"; Code[20])
        {
            Caption = 'Issuing Authority';
            TableRelation = "KINTO Issuing Authority";
        }
        field(6; "Issuing Authority Name"; Text[100])
        {
            Caption = 'Issuing Authority Name';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Issuing Authority".Name where(Code = field("Issuing Authority Code")));
            Editable = false;
        }
        field(7; "Jurisdiction"; Text[50]) { Caption = 'Jurisdiction'; }
        field(8; "Infraction Code"; Code[20]) { Caption = 'Infraction Code'; }
        field(9; "Infraction Description"; Text[250]) { Caption = 'Infraction Description'; }
        field(10; "Infraction DateTime"; DateTime)
        {
            Caption = 'Infraction Date/Time';
            // RN-016 do D2: data da infração ≠ data de captura — a vinculação usa ESTA data
        }
        field(11; "Capture DateTime"; DateTime) { Caption = 'Capture/Notification Date/Time'; }
        field(12; Status; Enum "KINTO Fine Status") { Caption = 'Status'; }
        field(13; "Customer Amount"; Decimal)
        {
            Caption = 'Customer Amount';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            // RN-016 do D2: 3 valores — faturado ao cliente / pago ao fornecedor / cheio
        }
        field(14; "Vendor Amount"; Decimal) { Caption = 'Vendor Amount'; DecimalPlaces = 2 : 2; MinValue = 0; }
        field(15; "Full Amount"; Decimal) { Caption = 'Full Amount'; DecimalPlaces = 2 : 2; MinValue = 0; }
        field(16; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency; }
        field(17; "Evidence Attached"; Boolean) { Caption = 'Evidence Attached'; Editable = false; }
        field(18; "Payment Link"; Text[250]) { Caption = 'Payment Link'; }
        field(19; "Payment Due Date"; Date) { Caption = 'Payment Due Date'; }
        field(20; "Paid Date"; Date) { Caption = 'Paid Date'; }
        field(21; "Payment Amount"; Decimal) { Caption = 'Payment Amount'; DecimalPlaces = 2 : 2; }
        field(22; "Vendor Invoice No."; Code[20]) { Caption = 'Vendor Invoice No.'; }
        field(23; "Vendor Paid"; Boolean) { Caption = 'Vendor Paid'; Editable = false; }
        field(24; "Vendor Paid Date"; Date) { Caption = 'Vendor Paid Date'; Editable = false; }
        field(25; "SNE Adjustment %"; Decimal)
        {
            Caption = 'SNE Adjustment %';
            DecimalPlaces = 0 : 5;
            Editable = false; // populado do órgão autuador na vinculação
        }
        field(26; "Link Status"; Enum "KINTO Fine Link Status") { Caption = 'Link Status'; Editable = false; }
        field(27; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
            Editable = false;
        }
        field(28; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            Editable = false;
        }
        field(29; "Linked DateTime"; DateTime) { Caption = 'Linked DateTime'; Editable = false; }
        field(30; "Billing Month"; Date) { Caption = 'Billing Month'; Editable = false; }
        field(31; "Billing Line Entry No."; Integer) { Caption = 'Billing Line Entry No.'; Editable = false; }
        field(32; "Provider Code"; Code[20])
        {
            Caption = 'Provider';
            TableRelation = "KINTO Fine Provider";
        }
        field(33; "Provider Batch No."; Code[20]) { Caption = 'Provider Batch No.'; }
        field(34; "Provider Record ID"; Text[50]) { Caption = 'Provider Record ID'; }
        field(35; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(36; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(37; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(38; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(39; "Cancellation Reason"; Text[250]) { Caption = 'Cancellation Reason'; }
        field(40; "Refund Amount"; Decimal) { Caption = 'Refund Amount'; DecimalPlaces = 2 : 2; }
        field(41; "Refund Status"; Option)
        {
            Caption = 'Refund Status';
            OptionMembers = " ",Pending,Processed;
        }
        field(42; "Seizure Flag"; Boolean) { Caption = 'Vehicle Seizure'; }
        field(43; "Registration Restriction"; Boolean) { Caption = 'Registration Restriction'; }
        field(44; "Notes"; Text[250]) { Caption = 'Notes'; }
    }

    keys
    {
        key(PK; "Fine No.") { Clustered = true; }
        key(Idx1; "License Plate", "Infraction DateTime") { }
        key(Idx2; Status) { }
        key(Idx3; "Contract No.") { }
        key(Idx4; "Link Status") { }
        key(Idx5; "AIIP Code") { }
        key(Idx6; "Provider Code", "Provider Batch No.") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Fine No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Fine Series', 'KINTO-FINE');
            "Fine No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    // ============================================================
    // CICLO LEGAL BR (D2: Autuação → NIC → Penalidade)
    // ============================================================
    procedure IndicateDriver(DriverName: Text[100]; DriverCPF: Text[20]; DriverLicenseNo: Text[20])
    var
        FineDriver: Record "KINTO Fine Driver";
        NotPenaltyErr: Label 'Fine %1 is not in a state that allows driver indication.';
    begin
        if not (Status in [Status::Registered, Status::"In Analysis"]) then
            Error(NotPenaltyErr, "Fine No.");
        TestField("Contract No."); // só indica condutor com vínculo
        FineDriver.InsertDriver("Fine No.", DriverName, DriverCPF, DriverLicenseNo, true);
        Status := Status::"Driver Indicated";
        Modify(true);
    end;

    procedure SendNIC()
    var
        FineDriver: Record "KINTO Fine Driver";
        NotIndicatedErr: Label 'Fine %1 has no driver indicated — NIC requires driver indication.';
        AlreadyErr: Label 'NIC for fine %1 was already sent.';
    begin
        if Status <> Status::"Driver Indicated" then
            Error(AlreadyErr, "Fine No.");
        FineDriver.SetRange("Fine No.", "Fine No.");
        FineDriver.SetRange(IsDriver, true);
        if FineDriver.IsEmpty() then
            Error(NotIndicatedErr, "Fine No.");
        FineDriver.ModifyAll(NICSent, true);
        FineDriver.ModifyAll("NIC Sent Date", WorkDate());
        Status := Status::"NIC Sent";
        Modify(true);
    end;

    procedure MarkPenaltyIssued()
    var
        NotNicErr: Label 'Fine %1 has not completed the NIC stage.';
    begin
        if Status <> Status::"NIC Sent" then
            Error(NotNicErr, "Fine No.");
        Status := Status::"Penalty Issued";
        Modify(true);
    end;

    procedure Appeal()
    var
        NotPenaltyErr: Label 'Fine %1 is not in penalty stage.';
    begin
        if Status <> Status::"Penalty Issued" then
            Error(NotPenaltyErr, "Fine No.");
        Status := Status::Appealed;
        Modify(true);
    end;

    procedure CancelFine(Reason: Text[250])
    var
        AlreadyErr: Label 'Fine %1 is already cancelled/billed.';
    begin
        if Status in [Status::Cancelled, Status::Billed] then
            Error(AlreadyErr, "Fine No.");
        Status := Status::Cancelled;
        "Cancellation Reason" := CopyStr(Reason, 1, MaxStrLen("Cancellation Reason"));
        if "Billing Line Entry No." <> 0 then
            CancelCustomerBilling();
        Modify(true);
    end;

    procedure MarkPaid(PaymentDate: Date; Amount: Decimal)
    begin
        Status := Status::Paid;
        "Paid Date" := PaymentDate;
        "Payment Amount" := Amount;
        Modify(true);
    end;

    procedure CancelCustomerBilling()
    var
        BillingLine: Record "KINTO Billing Line";
        BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
    begin
        if "Billing Line Entry No." = 0 then
            exit;
        if BillingLine.Get("Billing Line Entry No.") then
            if BillingLine.Status = BillingLine.Status::Invoiced then
                BillingMgt.CreateCreditFromBillingLine("Billing Line Entry No.",
                    CopyStr(StrSubstNo('Fine %1 cancelled', "Fine No."), 1, 250))
            else begin
                BillingLine.Status := BillingLine.Status::Cancelled;
                BillingLine."Cancellation Reason" := CopyStr(StrSubstNo('Fine %1 cancelled', "Fine No."), 1, 250);
                BillingLine.Modify(true);
            end;
        "Billing Line Entry No." := 0;
    end;
}

// ============================================================
// DRIVER INDICATION / NIC (D2 BR)
// ============================================================
table 50301 "KINTO Fine Driver"
{
    Caption = 'KINTO Fine Driver';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Traffic Fine List";
    DrillDownPageId = "KINTO Traffic Fine List";

    fields
    {
        field(1; "Fine No."; Code[20])
        {
            Caption = 'Fine No.';
            TableRelation = "KINTO Traffic Fine";
        }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; IsDriver; Boolean) { Caption = 'Is Driver (vs owner)'; }
        field(4; "Driver Name"; Text[100]) { Caption = 'Driver Name'; }
        field(5; "Driver CPF"; Text[20]) { Caption = 'Driver CPF'; }
        field(6; "Driver License No."; Text[20]) { Caption = 'Driver License No.'; }
        field(7; NICSent; Boolean) { Caption = 'NIC Sent'; Editable = false; }
        field(8; "NIC Sent Date"; Date) { Caption = 'NIC Sent Date'; Editable = false; }
        field(9; "Notification 1 Date"; Date) { Caption = 'Notification 1 Date'; Editable = false; }
        field(10; "Notification 2 Date"; Date) { Caption = 'Notification 2 Date'; Editable = false; }
        field(11; "Notification 3 Date"; Date) { Caption = 'Notification 3 Date'; Editable = false; }
        field(12; "Notification Count"; Integer) { Caption = 'Notification Count'; Editable = false; }
    }

    keys
    {
        key(PK; "Fine No.", "Line No.") { Clustered = true; }
    }

    procedure InsertDriver(FineNo: Code[20]; DriverName: Text[100]; DriverCPF: Text[20]; DriverLicenseNo: Text[20]; IsDriverFlag: Boolean)
    var
        FineDriver: Record "KINTO Fine Driver";
        LineNo: Integer;
    begin
        FineDriver.SetRange("Fine No.", FineNo);
        if FineDriver.FindLast() then
            LineNo := FineDriver."Line No." + 10000
        else
            LineNo := 10000;
        Init();
        "Fine No." := FineNo;
        "Line No." := LineNo;
        IsDriver := IsDriverFlag;
        "Driver Name" := DriverName;
        "Driver CPF" := DriverCPF;
        "Driver License No." := DriverLicenseNo;
        Insert(true);
    end;

    procedure SendNotification()
    var
        MaxNotificationsErr: Label 'Maximum notifications already sent for fine %1.';
    begin
        if "Notification Count" >= 3 then
            Error(MaxNotificationsErr, "Fine No.");
        "Notification Count" += 1;
        case "Notification Count" of
            1:
                "Notification 1 Date" := WorkDate();
            2:
                "Notification 2 Date" := WorkDate();
            3:
                "Notification 3 Date" := WorkDate();
        end;
        Modify(true);
    end;
}