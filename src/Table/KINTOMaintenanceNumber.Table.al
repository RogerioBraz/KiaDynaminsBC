table 50131 "KINTO Maintenance Number"
{
    Caption = 'KINTO Maintenance Number';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Plan ID"; Code[20]) { Caption = 'Plan ID'; TableRelation = "KINTO Maintenance Plan Header"; NotBlank = true; }
        field(2; "Range No."; Integer) { Caption = 'Range No.'; TableRelation = "KINTO Maintenance Range"."Range No." where("Plan ID" = field("Plan ID")); }
        field(3; "Line No."; Integer) { Caption = 'Line No.'; }
        field(4; "Item/Service Name"; Text[100]) { Caption = 'Item/Service Name'; NotBlank = true; }
        field(5; Quantity; Decimal) { Caption = 'Quantity'; }
        field(6; "Cost"; Decimal) { Caption = 'Cost'; AutoFormatType = 1; }
        field(7; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(8; "Part Number"; Text[30]) { Caption = 'Part Number'; }
        field(9; "Total Cost"; Decimal) { Caption = 'Total Cost (Cost + Markup)'; Editable = false; }
    }

    keys { key(PK; "Plan ID", "Range No.", "Line No.") { Clustered = true; } }

    trigger OnInsert()
    begin
        CalcTotalCost();
    end;

    trigger OnModify()
    begin
        CalcTotalCost();
    end;

    local procedure CalcTotalCost()
    begin
        "Total Cost" := Round(Cost * Quantity * (1 + "Markup %" / 100), 0.01);
    end;
}