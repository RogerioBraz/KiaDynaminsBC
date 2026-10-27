table 50402 "KINTO Recovery Case"
{
    Caption = 'KINTO Recovery Case';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Recovery Case List";
    DrillDownPageId = "KINTO Recovery Case Card";

    fields
    {
        field(1; "Case No."; Code[20]) { Caption = 'Case No.'; }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(3; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(4; "License Plate"; Text[20])
        {
            Caption = 'License Plate';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Inventory Vehicle"."License Plate" where("Vehicle No." = field("Vehicle No.")));
            Editable = false;
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(6; "Case Date"; Date) { Caption = 'Case Date'; }
        field(7; "Risk Level"; Enum "KINTO Recovery Risk") { Caption = 'Risk Level'; }
        field(8; "Aging Days"; Integer)
        {
            Caption = 'Aging (days)';
            // calculado: dias desde a abertura do caso
        }
        field(9; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Open,InNegotiation,Recovered,Lost,Court;
            Editable = false;
        }
        field(10; Blocked; Boolean) { Caption = 'Blocked (needs permission)'; Editable = false; }
        field(11; "Blocked Reason"; Text[100]) { Caption = 'Blocked Reason'; Editable = false; }
        field(12; "Recovered Date"; Date) { Caption = 'Recovered Date'; Editable = false; }
        field(13; "Current Odometer"; Decimal) { Caption = 'Odometer on Recovery (km)'; DecimalPlaces = 0 : 1; Editable = false; }
        field(14; "Vehicle Condition"; Text[100]) { Caption = 'Vehicle Condition on Recovery'; Editable = false; }
        field(15; "Last Contact Date"; Date) { Caption = 'Last Contact Date'; }
        field(16; "Next Task Date"; Date) { Caption = 'Next Task Date'; Editable = false; }
        field(17; Notes; Text[250]) { Caption = 'Notes'; }
        field(18; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(19; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(20; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
    }

    keys
    {
        key(PK; "Case No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
        key(Idx2; Status) { }
        key(Idx3; "Risk Level", "Aging Days") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Case No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Recovery Series', 'KINTO-REC');
            "Case No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    // ============================================================
    // D5: RECOVERY — classificação de risco + aging + bloqueio
    // ============================================================
    procedure ClassifyRisk()
    var
        Setup: Record "KINTO Termination Setup";
        DaysOpen: Integer;
    begin
        Setup.Get();
        TestField("Case Date");
        DaysOpen := WorkDate() - "Case Date";
        "Aging Days" := DaysOpen;

        if DaysOpen <= Setup."Recovery Low Risk Days" then
            "Risk Level" := "Risk Level"::Low
        else
            if DaysOpen <= Setup."Recovery Medium Risk Days" then
                "Risk Level" := "Risk Level"::Medium
            else
                "Risk Level" := "Risk Level"::High;

        // Alto risco + aging alto = bloqueado (liberação por permissão)
        if ("Risk Level" = "Risk Level"::High) and (DaysOpen > Setup."Recovery Block Days") then begin
            Blocked := true;
            "Blocked Reason" := CopyStr(StrSubstNo('High risk, %1 days aging', DaysOpen), 1, 100);
        end;

        Modify(true);
    end;

    procedure MarkRecovered(RecoveryDate: Date; Odometer: Decimal; Condition: Text[100])
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        OpenErr: Label 'Recovery case %1 is not open/in negotiation.';
    begin
        if not (Status in [Status::Open, Status::InNegotiation]) then
            Error(OpenErr, "Case No.");
        Status := Status::Recovered;
        "Recovered Date" := RecoveryDate;
        "Current Odometer" := Odometer;
        "Vehicle Condition" := CopyStr(Condition, 1, 100);
        Modify(true);

        if Vehicle.Get("Vehicle No.") then begin
            Vehicle.Status := Vehicle.Status::Returned;
            Vehicle."Current Odometer" := Odometer;
            Vehicle.Modify(true);
        end;
    end;

    procedure Unblock()
    var
        // A liberação de caso bloqueado exige permissão — controlada na page
        NotBlockedErr: Label 'Recovery case %1 is not blocked.';
    begin
        if not Blocked then
            Error(NotBlockedErr, "Case No.");
        Blocked := false;
        "Blocked Reason" := '';
        Modify(true);
    end;
}