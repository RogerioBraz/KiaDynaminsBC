table 50207 "KINTO Pool Type"
{
    Caption = 'KINTO Pool Type';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Pool Types";
    DrillDownPageId = "KINTO Pool Types";

    fields
    {
        field(1; "Code"; Code[20]) { Caption = 'Code'; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Unit of Measure"; Option)
        {
            Caption = 'Unit of Measure';
            OptionMembers = Days,Units,km,Monetary;
        }
        field(4; "Shared Across Vehicles"; Boolean)
        {
            Caption = 'Shared Across Vehicles';
            // RN-036 do D1: pool compartilhável entre veículos do contrato
        }
        field(5; "Monetary"; Boolean) { Caption = 'Monetary'; }
        field(6; Blocked; Boolean) { Caption = 'Blocked'; }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}