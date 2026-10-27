tableextension 60001 "KINTO Maint Ticket Line Ext" extends "KINTO Maint Ticket Line"
{
    fields
    {
        field(60000; "Line Type"; Enum "KINTO Maint Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
            InitValue = "Part";
        }
        field(60001; "Service Type"; Enum "KINTO Maint Service Type")
        {
            Caption = 'Service Type';
            DataClassification = CustomerContent;
        }
        field(60002; "Hours"; Decimal)
        {
            Caption = 'Hours';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(60003; "HH Rate"; Decimal)
        {
            Caption = 'HH Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
    }

    trigger OnValidate()
    begin
        // Mao de obra: valor = horas x taxa HH (aplica minimo de horas do fornecedor)
        if Rec."Line Type" = Rec."Line Type"::Labor then begin
            if (Rec."Hours" <> 0) and (Rec."HH Rate" <> 0) then begin
                Rec.Quantity := Rec."Hours";
                Rec."Unit Cost" := Rec."HH Rate";
            end;
        end;
    end;
}
