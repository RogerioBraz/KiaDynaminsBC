table 50120 "KINTO Insurance Quote Group"
{
    Caption = 'KINTO Insurance Quote Group';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Ins. Quote Group List";
    DrillDownPageId = "KINTO Ins. Quote Group List";

    fields
    {
        field(1; "Group ID"; Integer)
        {
            Caption = 'Group ID';
            AutoIncrement = true;
        }
        field(2; "Group Code"; Code[20])
        {
            Caption = 'Código';
            NotBlank = true;
        }
        field(3; "Insurer ID"; Integer)
        {
            Caption = 'Insurer ID';
            TableRelation = "KINTO Insurer";
            NotBlank = true;
        }
        field(4; "Insurer Name"; Text[100])
        {
            Caption = 'Seguradora';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Insurer"."Trade Name" where("Insurer ID" = field("Insurer ID")));
            Editable = false;
        }
        field(5; "Name"; Text[100])
        {
            Caption = 'Nome';
            NotBlank = true;
        }
        field(6; "Description"; Text[250])
        {
            Caption = 'Descrição';
        }
        field(7; "Registration Date"; DateTime)
        {
            Caption = 'Data de Cadastro';
        }
        field(8; "Validity Date"; Date)
        {
            Caption = 'Data de Validade';
            NotBlank = true;
        }
        field(9; "Armoring"; Boolean)
        {
            Caption = 'Blindagem';
        }
        field(10; "Active"; Boolean)
        {
            Caption = 'Ativo';
            InitValue = true;
        }
        field(11; "Deductible %"; Decimal)
        {
            Caption = 'Franquia %';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Risk Level"; Option)
        {
            Caption = 'Nível de Risco';
            OptionMembers = "Baixo","Médio","Alto","Agravado";
        }

        field(13; "Restricted Customer Level"; Option)
        {
            Caption = 'Nível de Cliente Restrito';
            OptionMembers = "None","NV1","NV2","NV3";
        }
        field(14; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "KINTO Country Setup";
        }
        field(15; "Created By"; Code[50]) { Caption = 'Created By'; }
        field(16; "Created Date"; Date) { Caption = 'Created Date'; }
        field(17; "Modified Date"; Date) { Caption = 'Modified Date'; }
        field(50100; "Deductible Type"; Enum "KINTO Deductible Type") { Caption = 'Deductible Type'; }
        field(50101; "Deductible Value"; Decimal) { Caption = 'Deductible Value'; DecimalPlaces = 0 : 5; }
        field(50102; "Insurance Loading %"; Decimal) { Caption = 'Insurance Loading (Surcharge) %'; DecimalPlaces = 0 : 5; }
        field(50103; "Vehicle Value Basis"; Option) { Caption = 'Vehicle Value Basis'; OptionMembers = "MSRP Only","MSRP + Implements - Dealer Discount","FIPE/Market Value"; }

    }

    keys
    {
        key(PK; "Group ID") { Clustered = true; }
        key(Idx1; "Insurer ID", "Group Code") { }
        key(Idx2; "Active", "Validity Date") { }
    }

    trigger OnInsert()
    begin
        "Registration Date" := CurrentDateTime;
        "Created Date" := Today;
        "Modified Date" := Today;
        "Created By" := UserId;
    end;

    trigger OnModify()
    begin
        "Modified Date" := Today;
    end;
}