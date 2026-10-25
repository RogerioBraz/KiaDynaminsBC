table 50209 "KINTO Contract Change Log"
{
    Caption = 'KINTO Contract Change Log';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Contract Change Log";
    DrillDownPageId = "KINTO Contract Change Log";

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(3; "Change Type"; Enum "KINTO Contract Change Type") { Caption = 'Change Type'; }
        field(4; "Change DateTime"; DateTime) { Caption = 'Change DateTime'; Editable = false; }
        field(5; "Changed By"; Code[50]) { Caption = 'Changed By'; Editable = false; }
        field(6; Description; Text[250]) { Caption = 'Description'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
    }

    trigger OnInsert()
    begin
        "Change DateTime" := CurrentDateTime;
        "Changed By" := UserId;
    end;
}