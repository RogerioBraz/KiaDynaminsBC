table 50201 "KINTO Contract Condition"
{
    Caption = 'KINTO Contract Condition';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Contract Condition List";
    DrillDownPageId = "KINTO Contract Condition List";

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(2; "Condition ID"; Code[20]) { Caption = 'Condition ID'; }
        field(3; "Revision No."; Integer)
        {
            Caption = 'Revision No.';
            InitValue = 0;
        }
        field(4; "Financial Product Code"; Code[20])
        {
            Caption = 'Financial Product Code';
            TableRelation = "KINTO Financial Product";
        }
        field(5; "Product Type"; Enum "KINTO Financial Product Type") { Caption = 'Product Type'; }
        field(6; Description; Text[100]) { Caption = 'Description'; }
        field(7; "Monthly Amount"; Decimal)
        {
            Caption = 'Monthly Amount';
            DecimalPlaces = 2 : 2;
        }
        field(8; "Daily Amount"; Decimal)
        {
            Caption = 'Daily Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(9; "Valid From"; Date) { Caption = 'Valid From'; }
        field(10; "Valid To"; Date) { Caption = 'Valid To'; }
        field(11; Active; Boolean) { Caption = 'Active'; }
        field(12; "Price Index Code"; Code[10])
        {
            Caption = 'Price Index Code';
            TableRelation = "KINTO Price Index";
        }
        field(13; "Index Frequency"; Enum "KINTO Inflation Frequency") { Caption = 'Index Frequency'; }
        field(14; "Index Cap %"; Decimal) { Caption = 'Index Cap %'; DecimalPlaces = 0 : 5; }
        field(15; "Source Quote No."; Code[20])
        {
            Caption = 'Source Quote No.';
            TableRelation = "KINTO Quote Header";
            Editable = false;
        }
        field(16; "Source Quote Line No."; Integer) { Caption = 'Source Quote Line No.'; Editable = false; }
        field(17; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(18; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(19; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
    }

    keys
    {
        key(PK; "Contract No.", "Condition ID") { Clustered = true; }
        key(Idx1; "Contract No.", Active) { }
        key(Idx2; "Financial Product Code") { }
        key(Idx3; "Source Quote No.", "Source Quote Line No.") { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
        Contract: Record "KINTO Vehicle Contract";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;

        if "Condition ID" = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-COND';
            "Condition ID" := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;

        // Preço diário = mensal / 30 (RN-014 do D6); mês cheio = 30 dias
        if ("Monthly Amount" <> 0) and ("Daily Amount" = 0) then
            "Daily Amount" := Round("Monthly Amount" / 30, 0.01);

        // Herda indexação do contrato se não informada
        if ("Price Index Code" = '') and Contract.Get("Contract No.") then begin
            "Price Index Code" := Contract."Price Index Code";
            "Index Frequency" := Contract."Index Frequency";
            "Index Cap %" := Contract."Index Cap %";
        end;
    end;

    trigger OnModify()
    begin
        if ("Monthly Amount" <> xRec."Monthly Amount") and ("Daily Amount" = xRec."Daily Amount") then
            "Daily Amount" := Round("Monthly Amount" / 30, 0.01);
    end;

    procedure CreateRevision(NewMonthlyAmount: Decimal; EffectiveDate: Date)
    var
        NewCondition: Record "KINTO Contract Condition";
        SameIdExistsErr: Label 'Condition %1 already has revision %2.';
    begin
        // RN-013 do D6: nova condição comercial = nova linha com novo Condition ID,
        // preservando a data de alta original. A linha anterior é inativada com Valid To.
        NewCondition.Reset();
        NewCondition.SetRange("Contract No.", "Contract No.");
        NewCondition.SetRange("Revision No.", "Revision No." + 1);
        if not NewCondition.IsEmpty() then
            Error(SameIdExistsErr, "Condition ID", "Revision No." + 1);

        NewCondition.Init();
        NewCondition.TransferFields(Rec, true);
        NewCondition."Condition ID" := '';
        NewCondition."Revision No." := "Revision No." + 1;
        NewCondition."Monthly Amount" := NewMonthlyAmount;
        NewCondition."Daily Amount" := 0; // recalcula no OnInsert
        NewCondition."Valid From" := EffectiveDate;
        NewCondition."Valid To" := 0D;
        NewCondition.Active := false; // ativa na vigência
        NewCondition."No. Series" := 'KINTO-COND';
        NewCondition.Insert(true);

        // Inativa a condição anterior
        Active := false;
        "Valid To" := CalcDate('<-1D>', EffectiveDate);
        Modify(true);
    end;
}