table 50122 "KINTO Insurance Coverage"
{
    Caption = 'KINTO Insurance Coverage';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Insurance Quote No."; Code[20])
        {
            Caption = 'N° Seguro';
            TableRelation = "KINTO Insurance Quote";
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Premium Range"; Decimal)
        {
            Caption = 'Faixa Prêmio';
            AutoFormatType = 1;
            NotBlank = true;
        }
        field(4; "Property Damage"; Decimal) { Caption = 'Danos Materiais'; AutoFormatType = 1; }
        field(5; "Moral Damages"; Decimal) { Caption = 'Danos Morais'; AutoFormatType = 1; }
        field(6; "Bodily Injury"; Decimal) { Caption = 'Danos Corporais'; AutoFormatType = 1; }
        field(7; "APP Death"; Decimal) { Caption = 'Danos APP Morte'; AutoFormatType = 1; }
        field(8; "APP Disability"; Decimal) { Caption = 'Danos APP Invalidez'; AutoFormatType = 1; }
        field(9; "Registration Date"; Date) { Caption = 'Data do Cadastro'; }
        field(10; "Active"; Boolean)
        {
            Caption = 'Ativo';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Insurance Quote No.", "Line No.") { Clustered = true; }
        key(Idx1; "Premium Range") { }
    }

    trigger OnInsert()
    begin
        "Registration Date" := Today;
    end;
}