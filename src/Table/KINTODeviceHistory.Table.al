table 50443 "KINTO Device History"
{
    Caption = 'KINTO Device History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Device No."; Code[20])
        {
            Caption = 'Device No.';
            TableRelation = "KINTO Telematic Device";
        }
        field(3; "Event"; Enum "KINTO Device Event") { Caption = 'Event'; }
        field(4; "Event Date"; Date) { Caption = 'Event Date'; }
        field(5; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(6; "Contract No."; Code[20]) { Caption = 'Contract No.'; }
        field(7; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; }
        field(8; "Duration Days"; Integer) { Caption = 'Duration (days)'; }
        field(9; Description; Text[100]) { Caption = 'Description'; }
        field(10; "User ID"; Code[50]) { Caption = 'User ID'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Device No.", "Event Date") { }
    }

    procedure NextEntryNo(): Integer
    var
        H: Record "KINTO Device History";
    begin
        if H.FindLast() then
            exit(H."Entry No." + 1);
        exit(1);
    end;
}
