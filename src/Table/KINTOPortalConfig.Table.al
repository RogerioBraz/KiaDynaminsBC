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
        if not Get() then begin
            Init();
            "Primary Key" := 'SETUP';
            Enabled := false;
            "Availability Batch Size" := 50;
            "Max Retry" := 3;
            Insert(true);
            exit(false); // criada agora com defaults (desabilitada)
        end;
        exit(true);
    end;

    procedure InsertIfMissing()
    begin
        if not Get() then
            GetConfig(); // cria com defaults
    end;
}
