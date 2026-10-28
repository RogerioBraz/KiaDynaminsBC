table 60311 "KINTO Interaction Log"
{
    Caption = 'KINTO Interaction Log';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Interaction Log List";
    DrillDownPageId = "KINTO Interaction Log List";

    // ============================================================
    // DX1 — Interacao com prospect ou cliente.
    //
    // Guarda o historico comercial: quem falou, quando, por qual canal, qual o
    // assunto e qual o proximo passo. Existe porque a spec exige registrar a
    // interacao (hoje ela vive em planilha paralela, que e o que o NFMS elimina).
    //
    // O vinculo e por Prospect OU Customer — nunca os dois ao mesmo tempo
    // (validado em ValidateSource). Assim o historico sobrevive a conversao.
    // ============================================================

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Prospect No."; Code[20])
        {
            Caption = 'Prospect No.';
            TableRelation = "KINTO Prospect";
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(4; "Interaction Date"; Date) { Caption = 'Interaction Date'; NotBlank = true; }
        field(5; "Interaction Type"; Enum "KINTO Interaction Type") { Caption = 'Type'; NotBlank = true; }
        field(6; "Subject"; Text[150]) { Caption = 'Subject'; }
        field(7; "Details"; Text[1000]) { Caption = 'Details'; }
        field(8; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser"."Code";
        }
        field(9; "Contact Name"; Text[100]) { Caption = 'Contact Name'; }
        field(10; "Next Step"; Text[250]) { Caption = 'Next Step'; }
        field(11; "Next Step Date"; Date) { Caption = 'Next Step Date'; }
        field(12; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(13; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Prospect No.", "Interaction Date") { }
        key(Idx2; "Customer No.", "Interaction Date") { }
        key(Idx3; "Next Step Date") { }
    }

    trigger OnInsert()
    begin
        ValidateSource();
        if "Interaction Date" = 0D then
            "Interaction Date" := Today();
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
    end;

    // Exatamente um dos dois vinculos: prospect OU cliente.
    local procedure ValidateSource()
    begin
        if ("Prospect No." = '') and ("Customer No." = '') then
            Error('Inform the prospect or the customer of the interaction.');
        if ("Prospect No." <> '') and ("Customer No." <> '') then
            Error('The interaction must reference either a prospect or a customer, not both.');
    end;

    local procedure GetNextEntryNo(): Integer
    var
        L: Record "KINTO Interaction Log";
    begin
        L.Reset();
        L.SetLoadFields("Entry No.");
        L.SetCurrentKey("Entry No.");
        if L.FindLast() then
            exit(L."Entry No." + 1);
        exit(1);
    end;

    // Na conversao do prospect, o historico passa a apontar para o cliente.
    // Chamado pelo ConvertToCustomer para nao perder a trilha.
    procedure MoveToCustomer(ProspectNo: Code[20]; CustomerNo: Code[20]): Integer
    var
        Moved: Integer;
    begin
        SetRange("Prospect No.", ProspectNo);
        if FindSet(true) then
            repeat
                "Customer No." := CustomerNo;
                Modify(true);
                Moved += 1;
            until Next() = 0;
        exit(Moved);
    end;
}
