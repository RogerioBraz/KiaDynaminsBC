table 50449 "KINTO Remarketing Sale"
{
    Caption = 'KINTO Remarketing Sale';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Remarketing Sale List";
    DrillDownPageId = "KINTO Remarketing Sale List";

    fields
    {
        field(1; "Sale No."; Code[20]) { Caption = 'Sale No.'; }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(4; "Contract No."; Code[20]) { Caption = 'Source Contract No.'; }
        field(5; "Offer No."; Code[20]) { Caption = 'Accepted Offer No.'; }
        field(6; "Buyer Type"; Enum "KINTO Remark. Channel Type") { Caption = 'Buyer Type'; }
        field(7; "Buyer No."; Code[20]) { Caption = 'Buyer No. (Customer/Vendor)'; }
        field(8; "Buyer Name"; Text[100]) { Caption = 'Buyer Name'; }
        field(9; Status; Enum "KINTO Remark. Sale Status") { Caption = 'Status'; }
        field(10; "Sale Price"; Decimal) { Caption = 'Sale Price'; }
        field(11; "Preparation Cost"; Decimal) { Caption = 'Preparation Cost'; }
        field(12; "Doc/Fees Cost"; Decimal) { Caption = 'Documentation & Fees Cost'; }
        field(13; "Other Cost"; Decimal) { Caption = 'Other Cost'; }
        field(14; "Total Cost"; Decimal) { Caption = 'Total Cost'; Editable = false; }
        field(15; "Gross Margin"; Decimal) { Caption = 'Gross Margin'; Editable = false; }
        field(16; "Margin %"; Decimal) { Caption = 'Margin %'; Editable = false; }
        field(17; "Commission Amount"; Decimal) { Caption = 'Commission'; Editable = false; }
        field(18; "Sale Date"; Date) { Caption = 'Sale Date'; }
        field(19; "Payment Due Date"; Date) { Caption = 'Payment Due Date'; }
        field(20; "Payment Date"; Date) { Caption = 'Payment Date'; }
        field(21; "Invoice No."; Code[20]) { Caption = 'Invoice No.'; }
        field(22; "Approved By"; Code[50]) { Caption = 'Approved By (4-eyes)'; }
        field(23; "Approved DateTime"; DateTime) { Caption = 'Approved DateTime'; }
        field(24; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(25; "Asset Written Off"; Boolean) { Caption = 'Asset Written Off'; Editable = false; }
    }

    keys
    {
        key(PK; "Sale No.") { Clustered = true; }
        key(Idx1; "Vehicle No.") { }
        key(Idx2; Status) { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "Sale No." = '' then begin
            if "No. Series" = '' then
                "No. Series" := 'KINTO-RMS';
            "Sale No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
    end;

    trigger OnModify()
    begin
        "Total Cost" := "Preparation Cost" + "Doc/Fees Cost" + "Other Cost";
        "Gross Margin" := "Sale Price" - "Total Cost";
        if "Sale Price" <> 0 then
            "Margin %" := "Gross Margin" / "Sale Price" * 100;
    end;

    procedure IsDriverSale(): Boolean
    begin
        exit("Buyer Type" = "Buyer Type"::Customer);
    end;
}
