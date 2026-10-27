table 60011 "KINTO Pre-Closure"
{
    Caption = 'KINTO Pre-Closure';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Pre-Closure List";
    DrillDownPageId = "KINTO Pre-Closure List";

    // D5 — etapa de pre-fechamento: aviso e checklist ANTES da devolucao
    // (evita cobrancas surpresa e organiza o patio).

    fields
    {
        field(1; "Pre-Closure No."; Code[20]) { Caption = 'Pre-Closure No.'; }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract"."Contract No.";
        }
        field(3; "Planned Return Date"; Date) { Caption = 'Planned Return Date'; }
        field(4; "Notice Sent Date"; Date) { Caption = 'Notice Sent Date'; }
        field(5; Status; Enum "KINTO PreClosure Status") { Caption = 'Status'; }
        field(6; "Odometer Forecast"; Decimal) { Caption = 'Odometer Forecast (km)'; DecimalPlaces = 0 : 1; }
        field(7; "Mileage Excess Forecast"; Decimal) { Caption = 'Mileage Excess Forecast (km)'; DecimalPlaces = 0 : 1; Editable = false; }
        field(8; "Estimated Excess Charge"; Decimal) { Caption = 'Estimated Excess Charge'; DecimalPlaces = 2 : 2; Editable = false; }
        field(9; "Open Fines Count"; Integer) { Caption = 'Open Fines'; Editable = false; }
        field(10; "Open Billing Amount"; Decimal) { Caption = 'Open Billing Amount'; DecimalPlaces = 2 : 2; Editable = false; }
        field(11; "Checklist Complete"; Boolean) { Caption = 'Checklist Complete'; }
        field(12; "Return No."; Code[20])
        {
            Caption = 'Return No.';
            TableRelation = "KINTO Vehicle Return"."Return No.";
            Editable = false;
        }
        field(13; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(14; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(15; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(16; Notes; Text[500]) { Caption = 'Notes'; }
    }

    keys
    {
        key(PK; "Pre-Closure No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
        key(Idx2; Status, "Planned Return Date") { }
    }

    procedure CalcForecasts()
    var
        Contract: Record "KINTO Vehicle Contract";
        Vehicle: Record "KINTO Inventory Vehicle";
        MileageClosing: Codeunit "KINTO Mileage Closing Mgt.";
        Fine: Record "KINTO Traffic Fine";
        BillingLine: Record "KINTO Billing Line";
        ExcessKm: Decimal;
        MonthsToReturn: Integer;
    begin
        if not Contract.Get("Contract No.") then
            exit;
        if not Vehicle.Get(Contract."Vehicle No.") then
            exit;

        // Km previsto na devolucao: ritmo medio mensal x meses restantes
        MonthsToReturn := (Rec."Planned Return Date" - WorkDate()) div 30;
        if MonthsToReturn > 0 then
            Rec."Odometer Forecast" := Vehicle."Current Odometer" + (Contract."Monthly Mileage (km)" * MonthsToReturn)
        else
            Rec."Odometer Forecast" := Vehicle."Current Odometer";

        // Excesso previsto e cobranca estimada (usa o motor do mileage closing)
        ExcessKm := MileageClosing.CalcExcessKm(Contract, Rec."Odometer Forecast");
        Rec."Mileage Excess Forecast" := ExcessKm;
        Rec."Estimated Excess Charge" := MileageClosing.CalcCharge(Contract, ExcessKm);

        // Multas abertas
        Fine.SetRange("Contract No.", Contract."Contract No.");
        Fine.SetFilter(Status, '<>%1&<>%2', Fine.Status::Paid, Fine.Status::Cancelled);
        Rec."Open Fines Count" := Fine.Count();

        // Billing aberto
        BillingLine.SetRange("Contract No.", Contract."Contract No.");
        BillingLine.SetRange(Status, BillingLine.Status::Open);
        BillingLine.CalcSums(Amount);
        Rec."Open Billing Amount" := BillingLine.Amount;
    end;

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Pre-Closure No." = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-PCL';
            if "No. Series" <> '' then
                "Pre-Closure No." := "No. Series".GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    var
        Amount: Decimal;
}
