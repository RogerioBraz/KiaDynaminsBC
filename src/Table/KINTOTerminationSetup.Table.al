table 50403 "KINTO Termination Setup"
{
    Caption = 'KINTO Termination Setup';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Termination Setup";
    DrillDownPageId = "KINTO Termination Setup";

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; }
        field(2; "Default Dealer Vendor No."; Code[20])
        {
            Caption = 'Default Dealer Vendor No.';
            TableRelation = Vendor;
        }
        field(3; "Damage Charge Account"; Code[20])
        {
            Caption = 'Damage Charge G/L Account';
            TableRelation = "G/L Account";
        }
        field(4; "Recovery Low Risk Days"; Integer) { Caption = 'Recovery Low Risk (days)'; InitValue = 15; }
        field(5; "Recovery Medium Risk Days"; Integer) { Caption = 'Recovery Medium Risk (days)'; InitValue = 45; }
        field(6; "Recovery Block Days"; Integer) { Caption = 'Recovery Block Aging (days)'; InitValue = 90; }
        field(7; "Return Odometer Tolerance"; Decimal) { Caption = 'Return Odometer Tolerance (km)'; DecimalPlaces = 0 : 1; InitValue = 0; }
        field(8; "Damage Approval Threshold"; Decimal) { Caption = 'Damage Approval Threshold (amount)'; DecimalPlaces = 2 : 2; }
        field(9; "Cautelar Required"; Boolean) { Caption = 'Cautelar Report Required'; InitValue = true; }
        field(10; "Return Nos."; Code[20])
        {
            Caption = 'Return No. Series';
            TableRelation = "No. Series";
        }
        field(11; "Recovery Nos."; Code[20])
        {
            Caption = 'Recovery No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}