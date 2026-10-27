table 50465 "KINTO Settlement"
{
    Caption = 'KINTO Settlement';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Settlement List";
    DrillDownPageId = "KINTO Settlement List";

    // Liquidación final (D5): saldo de encerramento do contrato —
    // destruição total (AR c/ aprovação Finance), franquia de roubo,
    // recuperação de seguro, ou saldo normal.

    fields
    {
        field(1; "Settlement No."; Code[20]) { Caption = 'Settlement No.'; }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(4; "Settlement Type"; Enum "KINTO Settlement Type") { Caption = 'Settlement Type'; }
        field(5; Status; Enum "KINTO Settlement Status") { Caption = 'Status'; }
        field(6; "Settlement Date"; Date) { Caption = 'Settlement Date'; }
        field(7; "Customer No."; Code[20]) { Caption = 'Customer No.'; }
        field(8; Description; Text[250]) { Caption = 'Description'; }
        field(9; "Open Billing Balance"; Decimal) { Caption = 'Open Billing Balance'; Editable = false; }
        field(10; "Damage Balance"; Decimal) { Caption = 'Damage Balance'; Editable = false; }
        field(11; "Fine Balance"; Decimal) { Caption = 'Fine Balance'; Editable = false; }
        field(12; "Mileage Excess Charge"; Decimal) { Caption = 'Mileage Excess Charge'; Editable = false; }
        field(13; "Deductible Amount"; Decimal) { Caption = 'Deductible (franquia)'; Editable = false; }
        field(14; "Insurance Recovery Amount"; Decimal) { Caption = 'Insurance Recovery'; Editable = false; }
        field(15; "Total Amount"; Decimal) { Caption = 'Total Amount'; Editable = false; }
        field(16; "Approved By"; Code[50]) { Caption = 'Approved By'; }
        field(17; "Approved DateTime"; DateTime) { Caption = 'Approved DateTime'; }
        field(18; "Invoice No."; Code[20]) { Caption = 'Invoice No.'; Editable = false; }
        field(19; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(20; "Mileage Cap Applied"; Boolean) { Caption = 'Mileage Cap (FIPE) Applied'; Editable = false; }
    }

    keys
    {
        key(PK; "Settlement No.") { Clustered = true; }
        key(Idx1; "Contract No.") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "Settlement No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Settlement Series', 'KINTO-STL');
            "Settlement No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;
}
