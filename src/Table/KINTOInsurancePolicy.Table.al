table 50444 "KINTO Insurance Policy"
{
    Caption = 'KINTO Insurance Policy';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Insurance Policy List";
    DrillDownPageId = "KINTO Insurance Policy List";

    fields
    {
        field(1; "Policy No."; Code[20]) { Caption = 'Policy No.'; }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(4; "Insurer Code"; Code[20])
        {
            Caption = 'Insurer Code';
            TableRelation = "KINTO Insurer"."Insurer Code";
        }
        field(5; "Policy Number (Ext.)"; Text[50]) { Caption = 'External Policy Number'; }
        field(6; Description; Text[100]) { Caption = 'Description'; }
        field(7; Status; Enum "KINTO Policy Status") { Caption = 'Status'; }
        field(8; "Start Date"; Date) { Caption = 'Start Date'; }
        field(9; "End Date"; Date) { Caption = 'End Date'; }
        field(10; "Annual Premium"; Decimal) { Caption = 'Annual Premium'; }
        field(11; "Monthly Cost"; Decimal) { Caption = 'Monthly Cost'; }
        field(12; "Coverage Type"; Text[50]) { Caption = 'Coverage Type'; }
        field(13; "Deductible Amount"; Decimal) { Caption = 'Deductible'; }
        field(14; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(15; "Country Code"; Code[10]) { Caption = 'Country Code'; }
    }

    keys
    {
        key(PK; "Policy No.") { Clustered = true; }
        key(Idx1; "Vehicle No.", Status) { }
        key(Idx2; "End Date") { }
    }

    trigger OnInsert()
    var
        CountrySetup: Record "KINTO Country Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "Policy No." = '' then begin
            if "No. Series" = '' then
                if "No. Series" = '' then
                "No. Series" := CountrySetup.GetDefaultSeries('Policy Series', 'KINTO-POL');
            "Policy No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    procedure IsActive(): Boolean
    begin
        exit((Status = Status::Active) and
            (("End Date" = 0D) or ("End Date" >= WorkDate())));
    end;
}
