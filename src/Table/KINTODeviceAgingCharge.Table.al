table 50458 "KINTO Device Aging Charge"
{
    Caption = 'KINTO Device Aging Charge';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Device Aging Charge List";
    DrillDownPageId = "KINTO Device Aging Charge List";

    // D7 bloco 2: cobrança do aging de dispositivo ao vendor/dealer
    // (> threshold do Country Setup → Purchase Invoice)

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Device No."; Code[20])
        {
            Caption = 'Device No.';
            TableRelation = "KINTO Telematic Device";
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(4; "Aging Days"; Integer) { Caption = 'Aging Days'; }
        field(5; "Daily Charge"; Decimal) { Caption = 'Daily Charge'; }
        field(6; "Charge Amount"; Decimal) { Caption = 'Charge Amount'; }
        field(7; "Purchase Invoice No."; Code[20]) { Caption = 'Purchase Invoice No.'; Editable = false; }
        field(8; "Invoiced"; Boolean) { Caption = 'Invoiced'; Editable = false; }
        field(9; "Charge Date"; Date) { Caption = 'Charge Date'; }
        field(10; "Country Code"; Code[10]) { Caption = 'Country Code'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Vendor No.", Invoiced) { }
    }

    procedure NextEntryNo(): Integer
    var
        C: Record "KINTO Device Aging Charge";
    begin
        if C.FindLast() then
            exit(C."Entry No." + 1);
        exit(1);
    end;
}
