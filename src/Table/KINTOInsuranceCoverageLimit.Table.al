table 50133 "KINTO Insurance Coverage Limit"
{
    Caption = 'KINTO Insurance Coverage Limit';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Insurance Package ID"; Integer)
        {
            Caption = 'Insurance Package ID';
            TableRelation = "KINTO Insurance Quote Group"."Group ID";
            NotBlank = true;
        }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Coverage Category"; Enum "KINTO Coverage Category") { Caption = 'Coverage Category'; NotBlank = true; }
        field(4; "Coverage Limit"; Decimal) { Caption = 'Coverage Limit'; AutoFormatType = 1; }
        field(5; "Cost"; Decimal) { Caption = 'Cost'; AutoFormatType = 1; }
        field(6; "Markup %"; Decimal) { Caption = 'Markup %'; DecimalPlaces = 0 : 5; }
        field(7; "Coverage %"; Decimal) { Caption = 'Coverage % (of Vehicle Value)'; DecimalPlaces = 0 : 5; }
        field(8; "Total Cost"; Decimal) { Caption = 'Total Cost'; Editable = false; }
        field(9; Active; Boolean) { Caption = 'Active'; InitValue = true; }
        field(10; "Premium Range"; Decimal) { Caption = 'Premium Range'; AutoFormatType = 1; }
    }

    keys
    {
        key(PK; "Insurance Package ID", "Line No.") { Clustered = true; }
        key(Idx1; "Insurance Package ID", "Coverage Category") { }
    }

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
        "Total Cost" := Round(Cost * (1 + "Markup %" / 100), 0.01);
    end;

    procedure CalculatePremium(VehicleValue: Decimal): Decimal
    begin
        if "Coverage %" > 0 then
            exit(Round(VehicleValue * "Coverage %" / 100 * (1 + "Markup %" / 100), 0.01));
        if Cost > 0 then
            exit("Total Cost");
        exit(0);
    end;
}