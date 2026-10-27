table 50464 "KINTO Contract Substitution"
{
    Caption = 'KINTO Contract Substitution';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Substitution List";
    DrillDownPageId = "KINTO Substitution List";

    // D5: substituição definitiva NA LINHA do contrato — saldos e cost
    // center pertencem à linha, não ao chassi. O veículo substituto herda
    // as condições do substituído (RN: "sustituto herda condições").

    fields
    {
        field(1; "Substitution No."; Code[20]) { Caption = 'Substitution No.'; }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(4; "Old Vehicle No."; Code[20])
        {
            Caption = 'Replaced Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(5; "New Vehicle No."; Code[20])
        {
            Caption = 'Substitute Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(6; Status; Enum "KINTO Substitution Status") { Caption = 'Status'; }
        field(7; "Request Date"; Date) { Caption = 'Request Date'; }
        field(8; "Delivery Date"; Date) { Caption = 'Delivery Date'; }
        field(9; "Completion Date"; Date) { Caption = 'Completion Date'; }
        field(10; Reason; Text[250]) { Caption = 'Reason'; }
        field(11; "Is Provisional"; Boolean) { Caption = 'Provisional (PEN-15: regras BR pendentes)'; }
        field(12; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(13; "Odometer at Delivery"; Decimal) { Caption = 'Odometer at Delivery'; }
        field(14; "Device Transferred"; Boolean) { Caption = 'Telematic Device Transferred'; Editable = false; }
    }

    keys
    {
        key(PK; "Substitution No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
        key(Idx2; "New Vehicle No.") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "Substitution No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Substitution Series', 'KINTO-SUB');
            "Substitution No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;
}
