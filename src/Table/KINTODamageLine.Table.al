table 50401 "KINTO Damage Line"
{
    Caption = 'KINTO Damage Line';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Vehicle Return List";
    DrillDownPageId = "KINTO Vehicle Return List";

    fields
    {
        field(1; "Return No."; Code[20])
        {
            Caption = 'Return No.';
            TableRelation = "KINTO Vehicle Return";
        }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; Description; Text[100]) { Caption = 'Description'; }
        field(4; "Damage Class"; Enum "KINTO Damage Class") { Caption = 'Damage Class'; }
        field(5; "Paid By"; Enum "KINTO Damage Payer") { Caption = 'Paid By'; }
        field(6; Amount; Decimal) { Caption = 'Amount'; DecimalPlaces = 2 : 2; }
        field(7; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency; }
        field(8; Approved; Boolean) { Caption = 'Approved'; }
        field(9; "Approved By"; Code[50]) { Caption = 'Approved By'; Editable = false; }
        field(10; "Approved DateTime"; DateTime) { Caption = 'Approved DateTime'; Editable = false; }
        field(11; "Photo Attached"; Boolean) { Caption = 'Photo/Evidence Attached'; }
        field(12; Notes; Text[250]) { Caption = 'Notes'; }
    }

    keys
    {
        key(PK; "Return No.", "Line No.") { Clustered = true; }
        key(Idx1; "Paid By") { }
    }

    trigger OnInsert()
    var
        Return: Record "KINTO Vehicle Return";
    begin
        if "Currency Code" = '' then
            if Return.Get("Return No.") then
                "Currency Code" := Return."Currency Code";
    end;

    procedure Approve()
    var
        NotClassErr: Label 'Damage line %1 has no classification/payer — classify before approval.';
    begin
        TestField("Damage Class");
        TestField("Paid By");
        TestField(Amount);
        Approved := true;
        "Approved By" := UserId;
        "Approved DateTime" := CurrentDateTime;
        Modify(true);
    end;
}