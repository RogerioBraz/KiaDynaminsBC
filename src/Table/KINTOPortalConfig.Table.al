table 50473 "KINTO Portal Config"
{
    Caption = 'KINTO Portal Config';
    DataClassification = CustomerContent;

    // Config do middleware do portal (endpoint, auth, retry).

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; }
        field(2; "Endpoint URL"; Text[250]) { Caption = 'Endpoint URL'; }
        field(3; "API Key"; Text[250]) { Caption = 'API Key'; }
        field(4; "Availability Batch Size"; Integer) { Caption = 'Availability Batch Size'; InitValue = 50; }
        field(5; "Max Retry"; Integer) { Caption = 'Max Retry'; InitValue = 3; }
        field(6; Enabled; Boolean) { Caption = 'Enabled'; }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetConfig(): Boolean
    begin
        // FIX (27/10): Get() sem argumento procurava PK='' (nunca existe — a PK
        // real é 'SETUP'), falhava sempre e tentava Insert → erro
        // "Já existe o registro na tabela KINTO Portal Config" na 2ª chamada.
        // Agora busca pela PK real e só cria quando NÃO existe.
        if Get('SETUP') then
            exit(true);
        Init();
        "Primary Key" := 'SETUP';
        Enabled := false;
        "Availability Batch Size" := 50;
        "Max Retry" := 3;
        Insert(true);
        exit(false); // criada agora com defaults (desabilitada)
    end;

    procedure InsertIfMissing()
    begin
        GetConfig(); // cria com defaults se faltar
    end;
}
