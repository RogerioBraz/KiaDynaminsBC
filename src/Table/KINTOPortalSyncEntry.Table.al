table 50472 "KINTO Portal Sync Entry"
{
    Caption = 'KINTO Portal Sync Entry';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Portal Sync Entries";
    DrillDownPageId = "KINTO Portal Sync Entries";

    // D8 BR: portal de seminovos FORA do NFMS com exatamente 3 touchpoints.
    // Cada touchpoint gera um registro aqui (payload JSON p/ o middleware
    // do portal consumir).

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Event Type"; Enum "KINTO Portal Event Type") { Caption = 'Event Type'; }
        field(3; "Vehicle No."; Code[20]) { Caption = 'Vehicle No.'; TableRelation = "KINTO Inventory Vehicle"; }
        field(4; "License Plate"; Text[20]) { Caption = 'License Plate'; }
        field(5; "Sale No."; Code[20]) { Caption = 'Sale No.'; TableRelation = "KINTO Remarketing Sale"; }
        field(6; "Sync Status"; Enum "KINTO Portal Sync Status") { Caption = 'Sync Status'; }
        field(7; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; }
        field(8; "Sent DateTime"; DateTime) { Caption = 'Sent DateTime'; }
        field(9; "Payload"; Blob) { Caption = 'Payload (JSON)'; }
        field(10; "Error Message"; Text[250]) { Caption = 'Error Message'; }
        field(11; "Retry Count"; Integer) { Caption = 'Retry Count'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Event Type", "Sync Status") { }
        key(Idx2; "Vehicle No.") { }
    }

    procedure SetPayload(PayloadText: Text)
    var
        OutStr: OutStream;
    begin
        Clear(Payload);
        Payload.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(PayloadText);
    end;

    procedure GetPayload() PayloadText: Text
    var
        InStr: InStream;
    begin
        CalcFields(Payload);
        if not Payload.HasValue() then
            exit('');
        Payload.CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(PayloadText);
    end;
}
