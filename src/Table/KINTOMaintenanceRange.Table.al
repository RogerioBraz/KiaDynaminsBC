
table 50130 "KINTO Maintenance Range"
{
    Caption = 'KINTO Maintenance Range';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Plan ID"; Code[20]) { Caption = 'Plan ID'; TableRelation = "KINTO Maintenance Plan Header"; NotBlank = true; }
        field(2; "Range No."; Integer) { Caption = 'Range No.'; NotBlank = true; }
        field(3; "Mileage Threshold"; Decimal) { Caption = 'Mileage Threshold (km)'; }
        field(4; "Age Threshold (Months)"; Integer) { Caption = 'Age Threshold (Months)'; }
        field(5; "Refresh Basis"; Boolean) { Caption = 'Refresh Basis on Trigger'; }
        field(6; "Range Description"; Text[100]) { Caption = 'Range Description'; }
        field(7; Active; Boolean) { Caption = 'Active'; InitValue = true; }
        field(8; "Created Date"; Date) { Caption = 'Created Date'; }
    }

    keys
    {
        key(PK; "Plan ID", "Range No.") { Clustered = true; }
        key(Idx1; "Mileage Threshold") { }
        key(Idx2; "Age Threshold (Months)") { }
    }

    trigger OnInsert()
    begin
        "Created Date" := Today;
    end;
}