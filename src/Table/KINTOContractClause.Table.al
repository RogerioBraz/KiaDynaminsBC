table 60002 "KINTO Contract Clause"
{
    Caption = 'KINTO Contract Clause';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Contract Clause List";
    DrillDownPageId = "KINTO Contract Clause List";

    // D4 — biblioteca de clausulas contratuais reutilizaveis.

    fields
    {
        field(1; "Clause Code"; Code[20]) { Caption = 'Clause Code'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Clause Category"; Enum "KINTO Clause Category") { Caption = 'Category'; }
        field(4; "Clause Text"; Text[2048]) { Caption = 'Clause Text'; }
        field(5; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "KINTO Country Setup"."Country Code";
        }
        field(6; "Is Mandatory"; Boolean) { Caption = 'Mandatory'; }
        field(7; Active; Boolean) { Caption = 'Active'; InitValue = true; }
        field(8; "Sort Order"; Integer) { Caption = 'Sort Order'; }
        field(9; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(10; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Clause Code") { Clustered = true; }
        key(Idx1; "Country Code", Active) { }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
    end;
}
