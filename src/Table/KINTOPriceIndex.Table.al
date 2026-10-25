table 50203 "KINTO Price Index"
{
    Caption = 'KINTO Price Index';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Price Index List";
    DrillDownPageId = "KINTO Price Index List";

    fields
    {
        field(1; "Index Code"; Code[10]) { Caption = 'Index Code'; }
        field(2; Description; Text[50]) { Caption = 'Description'; }
        field(3; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "KINTO Country Setup";
        }
        field(4; Blocked; Boolean) { Caption = 'Blocked'; }
    }

    keys
    {
        key(PK; "Index Code") { Clustered = true; }
    }
}