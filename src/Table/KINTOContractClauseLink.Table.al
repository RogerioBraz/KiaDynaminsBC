table 60003 "KINTO Contract Clause Link"
{
    Caption = 'KINTO Contract Clause Link';
    DataClassification = CustomerContent;

    // D4 — clausulas aplicadas a um contrato (snapshot no momento do vinculo).

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract"."Contract No.";
            NotBlank = true;
        }
        field(2; "Clause Code"; Code[20])
        {
            Caption = 'Clause Code';
            TableRelation = "KINTO Contract Clause"."Clause Code";
            NotBlank = true;
        }
        field(3; "Clause Text"; Text[2048]) { Caption = 'Clause Text (snapshot)'; }
        field(4; Accepted; Boolean) { Caption = 'Accepted by Customer'; }
        field(5; "Accepted Date"; Date) { Caption = 'Accepted Date'; }
        field(6; "Accepted By"; Text[100]) { Caption = 'Accepted By'; }
        field(7; "Added DateTime"; DateTime) { Caption = 'Added DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Contract No.", "Clause Code") { Clustered = true; }
        key(Idx1; "Clause Code") { }
    }

    trigger OnInsert()
    var
        ContractClause: Record "KINTO Contract Clause";
    begin
        "Added DateTime" := CurrentDateTime;
        if "Clause Text" = '' then
            if ContractClause.Get("Clause Code") then
                "Clause Text" := CopyStr(ContractClause."Clause Text", 1, 2048);
    end;
}
