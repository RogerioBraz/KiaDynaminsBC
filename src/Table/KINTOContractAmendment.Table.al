table 50208 "KINTO Contract Amendment"
{
    Caption = 'KINTO Contract Amendment';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Contract Amendment List";
    DrillDownPageId = "KINTO Contract Amendment List";

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(2; "Amendment No."; Integer) { Caption = 'Amendment No.'; }
        field(3; "Amendment Type"; Option)
        {
            Caption = 'Amendment Type';
            OptionMembers = Extension,Renegotiation,Renewal,Correction;
        }
        field(4; "Effective Date"; Date) { Caption = 'Effective Date'; }
        field(5; "New End Date"; Date) { Caption = 'New End Date'; }
        field(6; Description; Text[250]) { Caption = 'Description'; }
        field(7; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(8; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(9; "Retention Fee"; Boolean) { Caption = 'Retention Fee Indicated'; }
    }

    keys
    {
        key(PK; "Contract No.", "Amendment No.") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
    end;
}