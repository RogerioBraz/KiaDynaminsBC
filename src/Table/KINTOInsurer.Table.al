table 50119 "KINTO Insurer"
{
    Caption = 'KINTO Insurer';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Insurer List";
    DrillDownPageId = "KINTO Insurer List";

    fields
    {
        field(1; "Insurer ID"; Integer)
        {
            Caption = 'Insurer ID';
            AutoIncrement = true;
        }
        field(2; "Insurer Code"; Code[20])
        {
            Caption = 'Insurer Code';
            NotBlank = true;
        }
        field(3; "Legal Name"; Text[100])
        {
            Caption = 'Razão Social';
            NotBlank = true;
        }
        field(4; "Trade Name"; Text[100])
        {
            Caption = 'Nome Fantasia';
            NotBlank = true;
        }
        field(5; "CNPJ"; Text[18])
        {
            Caption = 'CNPJ';
            NotBlank = true;
        }
        field(6; "Active"; Boolean)
        {
            Caption = 'Ativo';
            InitValue = true;
        }
        field(7; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "KINTO Country Setup";
        }
        field(8; "Contact Name"; Text[100]) { Caption = 'Contact Name'; }
        field(9; "Contact Phone"; Text[30]) { Caption = 'Contact Phone'; }
        field(10; "Contact Email"; Text[100]) { Caption = 'Contact Email'; }
        field(11; "Created Date"; Date) { Caption = 'Created Date'; }
        field(12; "Modified Date"; Date) { Caption = 'Modified Date'; }
        field(13; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
    }

    keys
    {
        key(PK; "Insurer ID") { Clustered = true; }
        key(Idx1; "Insurer Code") { }
        key(Idx2; "Active") { }
    }

    trigger OnInsert()
    begin
        "Created Date" := Today;
        "Modified Date" := Today;
        if "Insurer Code" = '' then
            "Insurer Code" := Format("Insurer ID");
    end;

    trigger OnModify()
    begin
        "Modified Date" := Today;
    end;
}