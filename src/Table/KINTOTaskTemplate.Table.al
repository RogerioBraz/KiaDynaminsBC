table 50466 "KINTO Task Template"
{
    Caption = 'KINTO Task Template';
    DataClassification = CustomerContent;

    // Cadeias de tarefas por template (D5: recuperação de inadimplentes
    // só high risk — cadeia de cobrança configurável).

    fields
    {
        field(1; "Template Code"; Code[20]) { Caption = 'Template Code'; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Risk Level Filter"; Enum "KINTO Recovery Risk") { Caption = 'Applies to Risk Level'; }
        field(4; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(5; Active; Boolean) { Caption = 'Active'; InitValue = true; }
    }

    keys
    {
        key(PK; "Template Code") { Clustered = true; }
    }
}
