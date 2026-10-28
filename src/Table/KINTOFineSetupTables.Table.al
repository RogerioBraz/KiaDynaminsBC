table 50302 "KINTO Issuing Authority"
{
    Caption = 'KINTO Issuing Authority';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Issuing Authority List";
    DrillDownPageId = "KINTO Issuing Authority List";

    fields
    {
        field(1; "Code"; Code[20]) { Caption = 'Code'; }
        field(2; Name; Text[100]) { Caption = 'Name'; }
        field(3; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(4; Jurisdiction; Text[50]) { Caption = 'Jurisdiction'; }
        field(5; "SNE Adjustment %"; Decimal)
        {
            Caption = 'SNE Adjustment %';
            DecimalPlaces = 0 : 5;
            // D2: Ajuste SNE 60/80% configurável POR ÓRGÃO (não hard-code)
        }
        field(6; "Grace Period Days"; Integer)
        {
            Caption = 'Post-Contract Grace Period (days)';
            InitValue = 60;
            // D2: janela pós-contrato configurável (60d BR default)
        }
        field(7; "Accepts Appeal"; Boolean) { Caption = 'Accepts Appeal'; InitValue = true; }
        field(8; Blocked; Boolean) { Caption = 'Blocked'; }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
        key(Idx1; "Country Code") { }
    }
}

table 50303 "KINTO Fine Fee Setup"
{
    Caption = 'KINTO Fine Fee Setup';
    DataClassification = CustomerContent;
    // CORRIGIDO 1.2.0.6: apontava para "KINTO Issuing Authority List", pagina de
    // OUTRA tabela (a de orgaos autuadores). Abrir o lookup desta tabela trazia
    // um RecordID de outra tabela e quebrava — mesmo defeito da pagina 60012.
    LookupPageId = "KINTO Fine Fee Setup List";
    DrillDownPageId = "KINTO Fine Fee Setup Card";

    fields
    {
        field(1; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(2; "Fee Type"; Enum "KINTO Fine Fee Type") { Caption = 'Fee Type'; }
        field(3; "Financial Product Code"; Code[20])
        {
            Caption = 'Financial Product Code';
            TableRelation = "KINTO Financial Product";
        }
        field(4; Amount; Decimal) { Caption = 'Amount'; DecimalPlaces = 2 : 2; }
        field(5; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency; }
    }

    keys
    {
        key(PK; "Country Code", "Fee Type") { Clustered = true; }
    }
}

table 50304 "KINTO Fine Provider"
{
    Caption = 'KINTO Fine Provider';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Fine Provider List";
    DrillDownPageId = "KINTO Fine Provider List";

    fields
    {
        field(1; "Code"; Code[20]) { Caption = 'Code'; }
        field(2; Name; Text[100]) { Caption = 'Name'; }
        field(3; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(4; "Integration Type"; Option)
        {
            Caption = 'Integration Type';
            OptionMembers = API,EmailExcel,Manual;
            // D2: fornecedor pluggable — API BR (Mônaco) / Excel AR (Geodefender via Data Lake)
        }
        field(5; "Endpoint URL"; Text[250]) { Caption = 'Endpoint URL'; }
        field(6; "Default Fee Product"; Code[20])
        {
            Caption = 'Default Fee Product';
            TableRelation = "KINTO Financial Product";
        }
        field(7; Blocked; Boolean) { Caption = 'Blocked'; }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}

table 50305 "KINTO Fine Integration Error"
{
    Caption = 'KINTO Fine Integration Error';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Fine Integration Errors";
    DrillDownPageId = "KINTO Fine Integration Errors";

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Provider Code"; Code[20]) { Caption = 'Provider'; TableRelation = "KINTO Fine Provider"; }
        field(3; "Batch No."; Code[20]) { Caption = 'Batch No.'; }
        field(4; "Row Reference"; Text[50]) { Caption = 'Row Reference'; }
        field(5; "Error Message"; Text[250]) { Caption = 'Error Message'; }
        field(6; "Error DateTime"; DateTime) { Caption = 'Error DateTime'; Editable = false; }
        field(7; Resolved; Boolean) { Caption = 'Resolved'; }
        field(8; "Resolved By"; Code[50]) { Caption = 'Resolved By'; Editable = false; }
        field(9; "Raw Payload"; Blob) { Caption = 'Raw Payload'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; Resolved) { }
    }
}