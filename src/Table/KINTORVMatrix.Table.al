table 50104 "KINTO RV Matrix"
{
    Caption = 'KINTO Residual Value Matrix';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO RV Matrix List";
    DrillDownPageId = "KINTO RV Matrix List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }

        field(2; "Item No."; Code[20])
        {
            Caption = 'Vehicle Model/Version/Year';
            TableRelation = Item;
        }

        field(3; "Usage Type"; Enum "KINTO Usage Type")
        {
            Caption = 'Usage Type';
        }

        field(4; "Has Implement"; Boolean)
        {
            Caption = 'Has any Implement';
        }

        field(5; "Effective Start Date"; Date)
        {
            Caption = 'Effective Start Date';
        }

        field(6; "Max Mileage"; Decimal)
        {
            Caption = 'Maximum Mileage';
        }

        field(7; "Max Age"; Integer)
        {
            Caption = 'Maximum Age';
        }

        field(8; "Tabulated Age"; Integer)
        {
            Caption = 'Tabulated Age';
        }

        field(9; "Residual Value %"; Decimal)
        {
            Caption = 'Residual Value %';
            DecimalPlaces = 0 : 5;
        }

        field(10; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Active,Inactive,Blocked;
        }

        field(11; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }

        field(12; "Modified Date"; Date)
        {
            Caption = 'Modified Date';
            Editable = false;
        }

        field(13; "MSRP Record"; Boolean)
        {
            Caption = 'MSRP Record';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(Idx1; "Item No.", "Usage Type", "Has Implement",
                  "Effective Start Date", "Max Mileage", "Max Age")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created Date" := Today;
        "Modified Date" := Today;
    end;

    trigger OnModify()
    begin
        "Modified Date" := Today;
    end;
}