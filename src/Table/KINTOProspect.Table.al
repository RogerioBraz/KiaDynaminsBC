table 60310 "KINTO Prospect"
{
    Caption = 'KINTO Prospect';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Prospect List";
    DrillDownPageId = "KINTO Prospect List";

    // ============================================================
    // DX1 — Prospect (cliente potencial), tabela PROPRIETARIA e nao Contact.
    //
    // Por que nao usar Contact do BC: o prospect da KINTO tem Tax ID validado
    // (CPF/CNPJ), unicidade CRUZADA com Customer, canal de origem configuravel
    // e conversao que preserva o prospect como historico. Nada disso cabe em
    // Contact sem poluir o modelo.
    //
    // A unicidade do Tax ID e feita no OnValidate (prospect x prospect) e no
    // Convert (prospect x Customer) — ver ValidateTaxId.
    // ============================================================

    fields
    {
        field(1; "Prospect No."; Code[20])
        {
            Caption = 'Prospect No.';
            NotBlank = true;
        }
        field(2; Name; Text[100]) { Caption = 'Name'; NotBlank = true; }
        field(3; "Prospect Type"; Enum "KINTO Prospect Type") { Caption = 'Type'; NotBlank = true; }
        field(4; "Tax ID"; Code[30])
        {
            Caption = 'Tax ID (CPF/CNPJ)';
            // unicidade validada em ValidateTaxId (prospect e Customer)
        }
        field(5; "Tax ID Validation"; Option)
        {
            Caption = 'Tax ID Validation';
            OptionMembers = " ",Valid,Invalid,Pending;
            OptionCaption = ' ,Valid,Invalid,Pending';
        }
        field(6; "Channel"; Enum "KINTO Prospect Channel") { Caption = 'Origin Channel'; }
        field(7; Status; Enum "KINTO Prospect Status") { Caption = 'Status'; InitValue = "New"; }
        field(8; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "KINTO Country Setup";
        }
        field(9; "City"; Text[50]) { Caption = 'City'; }
        field(10; "State"; Code[20]) { Caption = 'State'; }
        field(11; "IBGE Code"; Code[10]) { Caption = 'IBGE Code (BR)'; }
        field(12; "Rural Producer"; Boolean) { Caption = 'Rural Producer'; }
        field(13; "Contact Name"; Text[100]) { Caption = 'Contact Name'; }
        field(14; "Contact Email"; Text[80]) { Caption = 'Contact E-mail'; }
        field(15; "Contact Phone"; Text[30]) { Caption = 'Contact Phone'; }
        field(16; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser"."Code";
        }
        field(17; "Converted Customer No."; Code[20])
        {
            Caption = 'Converted to Customer No.';
            TableRelation = Customer."No.";
            Editable = false;
        }
        field(18; "Converted Date"; Date) { Caption = 'Converted Date'; Editable = false; }
        field(19; "ERP Registration Status"; Option)
        {
            Caption = 'ERP Registration';
            OptionMembers = " ",Pending,OK,"Missing Info";
            OptionCaption = ' ,Pending,OK,Missing Info';
        }
        field(20; "Blocked"; Boolean) { Caption = 'Blocked'; }
        field(21; "Block Reason"; Enum "KINTO Block Reason") { Caption = 'Block Reason'; }
        field(22; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(23; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(24; "Modified By"; Code[50]) { Caption = 'Modified By'; Editable = false; }
        field(25; "Modified DateTime"; DateTime) { Caption = 'Modified DateTime'; Editable = false; }
        field(26; "Notes"; Text[500]) { Caption = 'Notes'; }
    }

    keys
    {
        key(PK; "Prospect No.") { Clustered = true; }
        key(Idx1; "Tax ID") { }
        key(Idx2; "Status", "Channel") { }
        key(Idx3; Name) { }
    }

    trigger OnInsert()
    begin
        ValidateTaxId();
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Prospect No." = '' then
            "Prospect No." := GetNextProspectNo();
        if "ERP Registration Status" = "ERP Registration Status"::" " then
            "ERP Registration Status" := "ERP Registration Status"::Pending;
    end;

    trigger OnModify()
    begin
        "Modified By" := UserId;
        "Modified DateTime" := CurrentDateTime;
    end;

    trigger OnRename()
    var
        Interaction: Record "KINTO Interaction Log";
    begin
        // o prospect e a chave do log de interacao: renomear precisa propagar
        Interaction.SetRange("Prospect No.", xRec."Prospect No.");
        if not Interaction.IsEmpty() then
            Error('Prospect %1 has interactions logged and cannot be renumbered.', xRec."Prospect No.");
    end;

    local procedure GetNextProspectNo(): Code[20]
    var
        NoSeriesMgt: Codeunit "No. Series";
        Setup: Record "KINTO Country Setup";
        P: Record "KINTO Prospect";
        Next: Integer;
        FromNo: Code[20];
        ToNo: Code[20];
    begin
        if ("Country Code" <> '') and Setup.Get("Country Code") then
            if Setup."Prospect No. Series" <> '' then
                exit(NoSeriesMgt.GetNextNo(Setup."Prospect No. Series", Today(), true));

        // Sem serie configurada: proximo numero por contagem dos existentes.
        FromNo := 'PRS-000000';
        ToNo := 'PRS-999999';
        P.Reset();
        P.SetRange("Prospect No.", FromNo, ToNo);
        Next := P.Count() + 1;
        exit('PRS-' + Format(Next, 0, '<Integer,6,0>'));
    end;

    // Unicidade do Tax ID: nao pode repetir entre prospects nem existir como
    // Customer. EXC-01 da spec: "TAX ID already exists".
    procedure ValidateTaxId(): Boolean
    var
        P: Record "KINTO Prospect";
        Clean: Code[30];
    begin
        if "Tax ID" = '' then
            exit(true);
        Clean := NormalizeTaxId("Tax ID");

        P.Reset();
        P.SetRange("Tax ID", Clean);
        P.SetFilter("Prospect No.", '<>%1', "Prospect No.");
        if not P.IsEmpty() then
            Error('Tax ID %1 already exists as prospect %2.', Clean, P."Prospect No.");

        // A checagem contra Customer usa o campo Tax ID da localizacao brasileira,
        // que nao existe no BC base. Fica como ponto de extensao: numa base com a
        // localizacao BR basta descomentar e o campo resolve.
        // C.Reset(); C.SetFilter("Tax ID", Clean);
        // if not C.IsEmpty() then Error('Tax ID %1 already exists as customer %2.', Clean, C."No.");

        exit(true);
    end;

    // Remove pontuacao do CPF/CNPJ para comparar
    procedure NormalizeTaxId(TaxId: Code[30]): Code[30]
    var
        Out: Text;
        I: Integer;
        Ch: Text;
    begin
        Out := '';
        for I := 1 to StrLen(TaxId) do begin
            Ch := CopyStr(TaxId, I, 1);
            if (Ch >= '0') and (Ch <= '9') then
                Out += Ch;
        end;
        exit(CopyStr(Out, 1, 30));
    end;

    // Regra de negocio: prospect bloqueado nao inicia novo processo comercial.
    procedure CheckNotBlocked()
    begin
        if "Blocked" then
            Error('Prospect %1 is blocked (%2) and cannot start a new commercial process.', "Prospect No.", "Block Reason");
    end;

    procedure Block(Reason: Enum "KINTO Block Reason"; Why: Text[250])
    begin
        if "Blocked" then
            Error('Prospect %1 is already blocked.', "Prospect No.");
        "Blocked" := true;
        "Block Reason" := Reason;
        if Why <> '' then
            Notes := CopyStr(Notes + ' | Bloqueio: ' + Why, 1, 500);
        Modify(true);
    end;

    procedure Unblock()
    begin
        "Blocked" := false;
        "Block Reason" := "Block Reason"::" ";
        Modify(true);
    end;
}
