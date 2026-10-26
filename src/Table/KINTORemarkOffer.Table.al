table 50448 "KINTO Remarketing Offer"
{
    Caption = 'KINTO Remarketing Offer';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Remarketing Offer List";
    DrillDownPageId = "KINTO Remarketing Offer List";

    fields
    {
        field(1; "Offer No."; Code[20]) { Caption = 'Offer No.'; }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(4; "Contract No."; Code[20]) { Caption = 'Source Contract No.'; }
        field(5; "Step No."; Integer) { Caption = 'Cascade Step'; }
        field(6; "Channel Type"; Enum "KINTO Remark. Channel Type") { Caption = 'Channel Type'; }
        field(7; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; }
        field(8; Status; Enum "KINTO Remark. Offer Status") { Caption = 'Status'; }
        field(9; "Offer Price"; Decimal) { Caption = 'Offer Price'; }
        field(10; "Sent Date"; Date) { Caption = 'Sent Date'; }
        field(11; "Expiry Date"; Date) { Caption = 'Expiry Date'; }
        field(12; "Response Date"; Date) { Caption = 'Response Date'; }
        field(13; "Country Code"; Code[10]) { Caption = 'Country Code'; }
    }

    keys
    {
        key(PK; "Offer No.") { Clustered = true; }
        key(Idx1; "Vehicle No.", "Step No.") { }
        key(Idx2; Status) { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "Offer No." = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-RMK';
            "Offer No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;
}
