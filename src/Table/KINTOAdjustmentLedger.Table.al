table 50471 "KINTO Adjustment Ledger"
{
    Caption = 'KINTO Adjustment Ledger';
    DataClassification = CustomerContent;

    // D6: auditoria de cada reajuste aplicado (contrato x mês x índice).

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Contract No."; Code[20]) { Caption = 'Contract No.'; TableRelation = "KINTO Vehicle Contract"; }
        field(3; "Adjustment Month"; Date) { Caption = 'Adjustment Month'; }
        field(4; "Index Code"; Code[10]) { Caption = 'Index Code'; }
        field(5; "Index Variation %"; Decimal) { Caption = 'Index Variation %'; DecimalPlaces = 0 : 4; }
        field(6; "Cap Applied %"; Decimal) { Caption = 'Cap Applied %'; DecimalPlaces = 0 : 2; }
        field(7; "Conditions Adjusted"; Integer) { Caption = 'Conditions Adjusted'; }
        field(8; "Prior Letter"; Boolean) { Caption = 'Prior Letter (exception)'; }
        field(9; "Created By"; Code[50]) { Caption = 'Created By'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Contract No.", "Adjustment Month") { }
    }
}
