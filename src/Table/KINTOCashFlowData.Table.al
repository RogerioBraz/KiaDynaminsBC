table 50113 "KINTO Cash Flow Data"
{
    Caption = 'KINTO Cash Flow Data';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Quote No."; Code[20]) { Caption = 'Quote No.'; }
        field(2; "Quote Line No."; Integer) { Caption = 'Quote Line No.'; }
        field(3; "Month No."; Integer) { Caption = 'Month No.'; }
        field(4; "Month Date"; Date) { Caption = 'Month Date'; }
        field(5; "Component ID"; Code[30]) { Caption = 'Component ID'; }
        field(6; "Component Description"; Text[100]) { Caption = 'Description'; }
        field(7; "Component Type"; Enum "KINTO CF Component Type") { Caption = 'Component Type'; }
        field(8; "Amount"; Decimal) { Caption = 'Amount'; }
        field(9; "Signed Amount"; Decimal) { Caption = 'Signed Amount'; }
        field(10; "Accumulated Mileage"; Decimal) { Caption = 'Accumulated Mileage'; }
        field(11; "Indexation Applied"; Boolean) { Caption = 'Indexation Applied'; }
        field(12; "Inflation Factor"; Decimal) { Caption = 'Inflation Factor'; DecimalPlaces = 0 : 10; }
    }

    keys
    {
        key(PK; "Quote No.", "Quote Line No.", "Month No.", "Component ID") { Clustered = true; }
        key(Idx1; "Quote No.", "Quote Line No.", "Month No.")
        {
            SumIndexFields = "Signed Amount";
        }
    }
}