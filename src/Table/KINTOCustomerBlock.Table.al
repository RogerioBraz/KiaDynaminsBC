table 60313 "KINTO Customer Block"
{
    Caption = 'KINTO Customer Block';
    DataClassification = CustomerContent;

    // ============================================================
    // DX1 — Bloqueio de cliente com motivo e historico (REQ-023).
    //
    // O campo Blocked do Customer diz SE esta bloqueado; esta tabela diz POR QUE,
    // DESDE QUANDO e QUEM liberou. A spec exige trilha: bloqueio sem motivo
    // registrado vira discussao comercial sem prova.
    // ============================================================

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            NotBlank = true;
        }
        field(3; "Block Date"; Date) { Caption = 'Block Date'; }
        field(4; "Block Reason"; Enum "KINTO Block Reason") { Caption = 'Block Reason'; NotBlank = true; }
        field(5; "Reason Text"; Text[250]) { Caption = 'Reason'; }
        field(6; "Blocked By"; Code[50]) { Caption = 'Blocked By'; Editable = false; }
        field(7; "Released Date"; Date) { Caption = 'Released Date'; }
        field(8; "Released By"; Code[50]) { Caption = 'Released By'; Editable = false; }
        field(9; "Release Reason"; Text[250]) { Caption = 'Release Reason'; }
        field(10; Active; Boolean) { Caption = 'Active Block'; InitValue = true; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Customer No.", Active) { }
    }

    trigger OnInsert()
    begin
        if "Block Date" = 0D then
            "Block Date" := Today();
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
        "Blocked By" := UserId;
    end;

    local procedure GetNextEntryNo(): Integer
    var
        B: Record "KINTO Customer Block";
    begin
        B.Reset();
        B.SetLoadFields("Entry No.");
        B.SetCurrentKey("Entry No.");
        if B.FindLast() then
            exit(B."Entry No." + 1);
        exit(1);
    end;

    // Bloqueia o cliente e registra o motivo (o Customer.Blocked e o campo que
    // o resto do sistema consulta; esta linha guarda o historico).
    procedure BlockCustomer(CustomerNo: Code[20]; Reason: Enum "KINTO Block Reason"; Why: Text[250])
    var
        C: Record Customer;
        B: Record "KINTO Customer Block";
    begin
        if not C.Get(CustomerNo) then
            Error('Customer %1 not found.', CustomerNo);
        if C.Blocked <> C.Blocked::" " then
            Error('Customer %1 is already blocked.', CustomerNo);

        C.Blocked := C.Blocked::All;
        C.Modify(true);

        B.Init();
        B."Customer No." := CustomerNo;
        B."Block Date" := Today();
        B."Block Reason" := Reason;
        B."Reason Text" := Why;
        B.Active := true;
        B.Insert(true);
    end;

    procedure ReleaseCustomer(CustomerNo: Code[20]; Why: Text[250])
    var
        C: Record Customer;
        B: Record "KINTO Customer Block";
    begin
        if not C.Get(CustomerNo) then
            Error('Customer %1 not found.', CustomerNo);
        C.Blocked := C.Blocked::" ";
        C.Modify(true);

        B.Reset();
        B.SetRange("Customer No.", CustomerNo);
        B.SetRange(Active, true);
        if B.FindSet(true) then
            repeat
                B.Active := false;
                B."Released Date" := Today();
                B."Released By" := UserId;
                B."Release Reason" := Why;
                B.Modify(true);
            until B.Next() = 0;
    end;
}
