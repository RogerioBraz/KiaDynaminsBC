table 60005 "KINTO Contract Evaluation"
{
    Caption = 'KINTO Contract Evaluation';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Contract Evaluation List";
    DrillDownPageId = "KINTO Contract Evaluation List";

    // D4 — avaliacao do cliente ao final do contrato (renovacao, risco, NPS).

    fields
    {
        field(1; "Evaluation No."; Code[20]) { Caption = 'Evaluation No.'; }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract"."Contract No.";
        }
        field(3; "Customer No."; Code[20]) { Caption = 'Customer No.'; TableRelation = Customer."No."; }
        field(4; "Evaluation Date"; Date) { Caption = 'Evaluation Date'; }
        field(5; "Payment Behavior Score"; Integer)
        {
            Caption = 'Payment Behavior (1-5)';
            MinValue = 1;
            MaxValue = 5;
        }
        field(6; "Vehicle Care Score"; Integer)
        {
            Caption = 'Vehicle Care (1-5)';
            MinValue = 1;
            MaxValue = 5;
        }
        field(7; "Violations Count"; Integer) { Caption = 'Violations / Fines Count'; MinValue = 0; }
        field(8; "Damages Amount"; Decimal) { Caption = 'Damages Amount'; DecimalPlaces = 2 : 2; }
        field(9; "Overall Score"; Decimal) { Caption = 'Overall Score'; DecimalPlaces = 0 : 2; Editable = false; }
        field(10; "Risk Rating"; Enum "KINTO Customer Risk Rating") { Caption = 'Risk Rating'; Editable = false; }
        field(11; "Renewal Recommendation"; Enum "KINTO Renewal Recommendation") { Caption = 'Renewal Recommendation'; }
        field(12; Notes; Text[500]) { Caption = 'Notes'; }
        field(13; Status; Enum "KINTO Evaluation Status") { Caption = 'Status'; }
        field(14; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(15; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(16; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
    }

    keys
    {
        key(PK; "Evaluation No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
        key(Idx2; "Customer No.", "Evaluation Date") { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Evaluation No." = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-EVAL';
            if "No. Series" <> '' then
                "Evaluation No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
        CalculateScore();
    end;

    trigger OnModify()
    begin
        CalculateScore();
    end;

    procedure CalculateScore()
    var
        Score: Decimal;
    begin
        // Media simples de comportamento + cuidado com o veiculo, penalizada por multas
        if ("Payment Behavior Score" > 0) and ("Vehicle Care Score" > 0) then
            Score := ("Payment Behavior Score" + "Vehicle Care Score") / 2
        else
            Score := "Payment Behavior Score" + "Vehicle Care Score";
        if "Violations Count" > 2 then
            Score := Score - 1;
        if Score < 1 then
            Score := 1;
        Rec."Overall Score" := Score;

        if Score >= 4.5 then
            Rec."Risk Rating" := Rec."Risk Rating"::Low
        else
            if Score >= 3.0 then
                Rec."Risk Rating" := Rec."Risk Rating"::Medium
            else
                Rec."Risk Rating" := Rec."Risk Rating"::High;
    end;

    procedure CreateFromContract(ContractNo: Code[20]): Code[20]
    var
        Contract: Record "KINTO Vehicle Contract";
        Fine: Record "KINTO Traffic Fine";
        Damage: Record "KINTO Damage Line";
        ReturnRec: Record "KINTO Vehicle Return";
        Amount: Decimal;
    begin
        if not Contract.Get(ContractNo) then
            exit('');
        Init();
        "Contract No." := ContractNo;
        "Customer No." := Contract."Customer No.";
        "Evaluation Date" := WorkDate();
        Status := Status::Draft;

        // Multas do cliente no contrato
        Fine.SetRange("Contract No.", ContractNo);
        "Violations Count" := Fine.Count();

        // Danos cobrados do cliente
        ReturnRec.SetRange("Contract No.", ContractNo);
        if ReturnRec.FindFirst() then begin
            Damage.SetRange("Return No.", ReturnRec."Return No.");
            Damage.SetRange("Paid By", Damage."Paid By"::Customer);
            Damage.CalcSums(Amount);
            "Damages Amount" := Damage.Amount;
        end;

        // Scores default (a preencher pelo gestor)
        "Payment Behavior Score" := 3;
        "Vehicle Care Score" := 3;
        Insert(true);
        exit("Evaluation No.");
    end;
}
