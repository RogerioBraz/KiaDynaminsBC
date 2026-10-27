table 60006 "KINTO Vehicle Document"
{
    Caption = 'KINTO Vehicle Document';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Vehicle Document List";
    DrillDownPageId = "KINTO Vehicle Document List";

    // D3 — documento do veiculo com versionamento (CRLV, laudo cautelar, seguro, etc).

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle"."Vehicle No.";
        }
        field(3; "Document Type"; Enum "KINTO Vehicle Doc Type") { Caption = 'Document Type'; }
        field(4; "Document No."; Code[50]) { Caption = 'Document No.'; }
        field(5; "Version No."; Integer) { Caption = 'Version No.'; Editable = false; }
        field(6; "Issue Date"; Date) { Caption = 'Issue Date'; }
        field(7; "Expiry Date"; Date) { Caption = 'Expiry Date'; }
        field(8; "Issuing Body"; Text[100]) { Caption = 'Issuing Body'; }
        field(9; "File Name"; Text[250]) { Caption = 'Attachment File Name'; }
        field(10; "Is Current"; Boolean) { Caption = 'Current Version'; Editable = false; }
        field(11; "Superseded By"; Integer) { Caption = 'Superseded By (Entry No.)'; Editable = false; }
        field(12; "Superseded Date"; Date) { Caption = 'Superseded Date'; Editable = false; }
        field(13; Notes; Text[500]) { Caption = 'Notes'; }
        field(14; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(15; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Vehicle No.", "Document Type", "Version No.") { }
        key(Idx2; "Is Current", "Expiry Date") { }
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if "Version No." = 0 then
            "Version No." := GetNextVersion();
        if "Is Current" = false then begin
            "Is Current" := true;
            SupersedeOldVersions();
        end;
    end;

    local procedure GetNextVersion(): Integer
    var
        Doc: Record "KINTO Vehicle Document";
    begin
        Doc.SetRange("Vehicle No.", "Vehicle No.");
        Doc.SetRange("Document Type", "Document Type");
        if Doc.FindLast() then
            exit(Doc."Version No." + 1);
        exit(1);
    end;

    procedure SupersedeOldVersions()
    var
        Doc: Record "KINTO Vehicle Document";
    begin
        Doc.SetRange("Vehicle No.", "Vehicle No.");
        Doc.SetRange("Document Type", "Document Type");
        Doc.SetRange("Is Current", true);
        Doc.SetFilter("Entry No.", '<>%1', "Entry No.");
        if Doc.FindSet() then
            repeat
                Doc."Is Current" := false;
                Doc."Superseded By" := "Entry No.";
                Doc."Superseded Date" := WorkDate();
                Doc.Modify(false);
            until Doc.Next() = 0;
    end;

    procedure GetCurrentDocument(VehicleNo: Code[20]; DocType: Enum "KINTO Vehicle Doc Type"): Integer
    begin
        SetRange("Vehicle No.", VehicleNo);
        SetRange("Document Type", DocType);
        SetRange("Is Current", true);
        if FindFirst() then
            exit("Entry No.");
        exit(0);
    end;

    procedure GetNextEntryNo(): Integer
    var
        Rec2: Record "KINTO Vehicle Document";
    begin
        Rec2.Reset();
        Rec2.SetCurrentKey("Entry No.");
        if Rec2.FindLast() then
            exit(Rec2."Entry No." + 1);
        exit(1);
    end;
}
