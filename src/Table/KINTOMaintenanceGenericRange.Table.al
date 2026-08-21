table 50132 "KINTO Mainten Generic Range"
{
    Caption = 'KINTO Maintenance Generic Range';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Plan ID"; Code[20]) { Caption = 'Plan ID'; TableRelation = "KINTO Maintenance Plan Header"; NotBlank = true; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Item/Service Name"; Text[100]) { Caption = 'Item/Service Name'; NotBlank = true; }
        field(4; Quantity; Decimal) { Caption = 'Quantity (0 = uses Monetary Balance)'; }
        field(5; "Cost"; Decimal) { Caption = 'Cost'; AutoFormatType = 1; }
        field(6; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(7; "Part Number"; Text[30]) { Caption = 'Part Number'; }
        field(8; "Total Cost"; Decimal) { Caption = 'Total Cost'; Editable = false; }
        field(9; Active; Boolean) { Caption = 'Active'; InitValue = true; }
    }

    keys { key(PK; "Plan ID", "Line No.") { Clustered = true; } }

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