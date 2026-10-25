table 50204 "KINTO Price Index Entry"
{
    Caption = 'KINTO Price Index Entry';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Price Index Entry List";
    DrillDownPageId = "KINTO Price Index Entry List";

    fields
    {
        field(1; "Index Code"; Code[10])
        {
            Caption = 'Index Code';
            TableRelation = "KINTO Price Index";
        }
        field(2; "Valid From"; Date) { Caption = 'Valid From'; }
        field(3; "Index Value"; Decimal) { Caption = 'Index Value'; DecimalPlaces = 2 : 4; }
        field(4; "Variation %"; Decimal)
        {
            Caption = 'Variation % vs Previous';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Index Code", "Valid From") { Clustered = true; }
    }

    trigger OnInsert()
    var
        PrevEntry: Record "KINTO Price Index Entry";
    begin
        // Calcula a variação % vs o valor anterior (base do reajuste do D6)
        PrevEntry.SetRange("Index Code", "Index Code");
        PrevEntry.SetFilter("Valid From", '<%1', "Valid From");
        if PrevEntry.FindLast() then
            if PrevEntry."Index Value" <> 0 then
                "Variation %" := Round(("Index Value" - PrevEntry."Index Value") / PrevEntry."Index Value" * 100, 0.00001);
    end;
}