table 60312 "KINTO Portfolio Transfer"
{
    Caption = 'KINTO Portfolio Transfer';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Portfolio Transfer List";
    DrillDownPageId = "KINTO Portfolio Transfer List";

    // ============================================================
    // DX1 — Transferencia de carteira entre vendedores (RN-009).
    //
    // Por que existe: quando um vendedor sai, a carteira dele precisa passar
    // para outro com registro de quem autorizou. Sem isso, os clientes ficam
    // sem responsavel e ninguem sabe quem aprovou a troca.
    //
    // Fluxo: requisicao (Pending) -> aprovacao do Backoffice (Approved) ->
    // os clientes/prospects passam a apontar para o vendedor de destino.
    // ============================================================

    fields
    {
        field(1; "Transfer No."; Code[20]) { Caption = 'Transfer No.'; NotBlank = true; }
        field(2; "From Salesperson"; Code[20])
        {
            Caption = 'From Salesperson';
            TableRelation = "Salesperson/Purchaser"."Code";
            NotBlank = true;
        }
        field(3; "To Salesperson"; Code[20])
        {
            Caption = 'To Salesperson';
            TableRelation = "Salesperson/Purchaser"."Code";
            NotBlank = true;
        }
        field(4; "Request Date"; Date) { Caption = 'Request Date'; }
        field(5; Status; Enum "KINTO Portfolio Request Status") { Caption = 'Status'; InitValue = Pending; }
        field(6; "Requested By"; Code[50]) { Caption = 'Requested By'; Editable = false; }
        field(7; "Approved By"; Code[50]) { Caption = 'Approved By'; Editable = false; }
        field(8; "Approved Date"; Date) { Caption = 'Approved Date'; Editable = false; }
        field(9; "Customers Moved"; Integer) { Caption = 'Customers Moved'; Editable = false; }
        field(10; "Prospects Moved"; Integer) { Caption = 'Prospects Moved'; Editable = false; }
        field(11; Reason; Text[250]) { Caption = 'Reason'; }
        field(12; Notes; Text[500]) { Caption = 'Notes'; }
    }

    keys
    {
        key(PK; "Transfer No.") { Clustered = true; }
        key(Idx1; "From Salesperson", "Request Date") { }
        key(Idx3; Status) { }
    }

    trigger OnInsert()
    begin
        if "From Salesperson" = "To Salesperson" then
            Error('Origin and destination salesperson must be different.');
        if "Request Date" = 0D then
            "Request Date" := Today();
        "Requested By" := UserId;
    end;

    // Aprovacao: move a carteira de fato.
    procedure Approve()
    var
        C: Record Customer;
        P: Record "KINTO Prospect";
        CntC: Integer;
        CntP: Integer;
    begin
        if Status <> Status::Pending then
            Error('Transfer %1 is not pending approval.', "Transfer No.");

        C.Reset();
        C.SetRange("Salesperson Code", "From Salesperson");
        if C.FindSet(true) then
            repeat
                C."Salesperson Code" := "To Salesperson";
                C.Modify(true);
                CntC += 1;
            until C.Next() = 0;

        P.Reset();
        P.SetRange("Salesperson Code", "From Salesperson");
        P.SetFilter(Status, '<>%1', P.Status::Converted);
        if P.FindSet(true) then
            repeat
                P."Salesperson Code" := "To Salesperson";
                P.Modify(true);
                CntP += 1;
            until P.Next() = 0;

        "Customers Moved" := CntC;
        "Prospects Moved" := CntP;
        Status := Status::Approved;
        "Approved By" := UserId;
        "Approved Date" := Today();
        Modify(true);
    end;

    procedure Reject(Why: Text[250])
    begin
        if Status <> Status::Pending then
            Error('Transfer %1 is not pending approval.', "Transfer No.");
        Status := Status::Rejected;
        Notes := CopyStr("Notes" + ' | Rejected: ' + Why, 1, 500);
        Modify(true);
    end;
}
