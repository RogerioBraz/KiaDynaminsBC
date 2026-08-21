table 50123 "KINTO Item Version History"
{
    Caption = 'KINTO Item Version History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; Caption = 'Entry No.'; }
        field(2; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item; NotBlank = true; }
        field(3; "Version No."; Integer) { Caption = 'Version No.'; }
        field(4; "Cost"; Decimal) { Caption = 'Cost'; AutoFormatType = 1; }
        field(5; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(6; "Active Start Date"; Date) { Caption = 'Active Start Date'; }
        field(7; "Active End Date"; Date) { Caption = 'Active End Date'; }
        field(8; "Created By"; Code[50]) { Caption = 'Created By'; }
        field(9; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; }
        field(10; "Pricing Value"; Decimal) { Caption = 'Pricing Value (Cost × (1+Markup))'; Editable = false; }
    }

    keys { key(PK; "Entry No.") { Clustered = true; } key(Idx1; "Item No.", "Active Start Date") { } }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        "Pricing Value" := Round(Cost * (1 + "Markup %" / 100), 0.01);
    end;

    procedure GetCurrentPricingValue(ItemNo: Code[20]; ReferenceDate: Date): Decimal
    var
        VersionHist: Record "KINTO Item Version History";
    begin
        VersionHist.SetRange("Item No.", ItemNo);
        VersionHist.SetFilter("Active Start Date", '<=%1', ReferenceDate);
        VersionHist.SetFilter("Active End Date", '>=%1|''''', ReferenceDate);
        if VersionHist.FindLast() then
            exit(VersionHist."Pricing Value");
        exit(0);
    end;
}