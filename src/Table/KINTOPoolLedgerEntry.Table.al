table 50206 "KINTO Pool Ledger Entry"
{
    Caption = 'KINTO Pool Ledger Entry';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Pool Ledger Entries";
    DrillDownPageId = "KINTO Pool Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(3; "Pool Type"; Code[20])
        {
            Caption = 'Pool Type';
            TableRelation = "KINTO Pool Type";
        }
        field(4; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(5; "Entry Type"; Enum "KINTO Pool Entry Type") { Caption = 'Entry Type'; }
        field(6; Quantity; Decimal) { Caption = 'Quantity'; DecimalPlaces = 0 : 2; }
        field(7; "Monetary Amount"; Decimal) { Caption = 'Monetary Amount'; DecimalPlaces = 2 : 2; }
        field(8; "Entry Date"; Date) { Caption = 'Entry Date'; }
        field(9; "Source Type"; Option)
        {
            Caption = 'Source Type';
            OptionMembers = Manual,Maintenance,Ticket,Contract;
        }
        field(10; "Source No."; Code[20]) { Caption = 'Source No.'; }
        field(11; Description; Text[100]) { Caption = 'Description'; }
        field(12; "Reversal Of Entry No."; Integer) { Caption = 'Reversal Of Entry No.'; Editable = false; }
        field(13; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(14; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Contract No.", "Pool Type") { }
        key(Idx2; "Vehicle No.") { }
        key(Idx3; "Source Type", "Source No.") { }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Entry Date" = 0D then
            "Entry Date" := WorkDate();
    end;
}