table 50121 "KINTO Insurance Quote"
{
    Caption = 'KINTO Insurance Quote';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Insurance Quote List";
    DrillDownPageId = "KINTO Insurance Quote Card";

    fields
    {
        field(1; "Insurance Quote No."; Code[20])
        {
            Caption = 'N° Seguro';
            NotBlank = true;
        }
        field(2; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(3; "Insurer ID"; Integer)
        {
            Caption = 'Cód. Seguradora';
            TableRelation = "KINTO Insurer";
            NotBlank = true;
        }
        field(4; "Insurer Name"; Text[100])
        {
            Caption = 'Seguradora';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Insurer"."Trade Name" where("Insurer ID" = field("Insurer ID")));
            Editable = false;
        }
        field(5; "Quote Group ID"; Integer)
        {
            Caption = 'Grupo';
            TableRelation = "KINTO Insurance Quote Group";
            NotBlank = true;
        }
        field(6; "Group Name"; Text[100])
        {
            Caption = 'Nome do Grupo';
            FieldClass = FlowField;
            CalcFormula = lookup("KINTO Insurance Quote Group".Name where("Group ID" = field("Quote Group ID")));
            Editable = false;
        }
        field(7; "Quote Validity Date"; Date)
        {
            Caption = 'Validade da Cotação';
            NotBlank = true;
        }
        // Vehicle data
        field(10; "Item No."; Code[20])
        {
            Caption = 'Modelo';
            TableRelation = Item;
        }
        field(11; "Vehicle Name"; Text[100]) { Caption = 'Nome'; }
        field(12; "Description"; Text[250]) { Caption = 'Descrição'; }
        field(13; "Manufacturer Code"; Code[20]) { Caption = 'Código da Montadora'; }
        field(14; "Manufacturer Name"; Text[50]) { Caption = 'Montadora'; }
        field(15; "Manufacturer Part Code"; Code[20]) { Caption = 'Código Fabricante'; }
        field(16; "Vehicle Model No."; Code[20])
        {
            Caption = 'Modelo do Veículo';
            TableRelation = "KINTO Vehicle Model";
        }
        field(17; "FIPE Code"; Code[20]) { Caption = 'Identificação FIPE'; }
        field(18; "Armoring"; Boolean)
        {
            Caption = 'Blindagem';

            trigger OnValidate()
            var
                InsQuoteGroup: Record "KINTO Insurance Quote Group";
            begin
                if Rec.Armoring then begin
                    if Rec."Quote Group ID" <> 0 then begin
                        InsQuoteGroup.Get(Rec."Quote Group ID");
                        if not InsQuoteGroup.Armoring then
                            Error(ArmoringNotSupportedErr, InsQuoteGroup.Name);
                    end;
                end;
            end;
        }
        // Financial values
        field(20; "Hull Value"; Decimal) { Caption = 'Valor do Casco'; AutoFormatType = 1; }
        field(21; "Deductible Value"; Decimal) { Caption = 'Valor Franquia'; AutoFormatType = 1; }
        field(22; "FIPE %"; Decimal) { Caption = '% FIPE'; DecimalPlaces = 0 : 5; }
        field(23; "Insurance %"; Decimal) { Caption = 'Percentual do Seguro'; DecimalPlaces = 0 : 5; }
        field(24; "Insurance Value"; Decimal) { Caption = 'Valor do Seguro'; AutoFormatType = 1; }
        field(25; "Premium Range"; Decimal) { Caption = 'Faixa Prêmio Selecionada'; AutoFormatType = 1; }
        // Status
        field(30; "Active"; Option)
        {
            Caption = 'Ativo';
            OptionMembers = "Inativo","Ativo";
            InitValue = "Ativo";
        }
        field(31; "KINTO Quote No."; Code[20])
        {
            Caption = 'KINTO Número da Cotação';
            TableRelation = "KINTO Quote Header";
        }
        field(32; "KINTO Quote Line No."; Integer)
        {
            Caption = 'KINTO Número da Linha da Cotação';
            TableRelation = "KINTO Quote Item"."Line No." where("Quote No." = field("KINTO Quote No."));
        }
        // Audit
        field(40; "Created By"; Code[50]) { Caption = 'Criado Por'; }
        field(41; "Created DateTime"; DateTime) { Caption = 'Data/Hora de Criação'; }
        field(42; "Modified By"; Code[50]) { Caption = 'Modificado Por'; }
        field(43; "Modified DateTime"; DateTime) { Caption = 'Data/Hora de Modificação'; }
    }

    keys
    {
        key(PK; "Insurance Quote No.") { Clustered = true; }
        key(Idx1; "Insurer ID", "Quote Validity Date") { }
        key(Idx2; "Item No.") { }
        key(Idx3; "KINTO Quote No.") { }
    }

    var
        ArmoringNotSupportedErr: Label 'The insurance quote cannot use group %1 because the vehicle is armored and the group does not support armored vehicles. Select a compatible group or clear the armoring option.';

    trigger OnInsert()
    var
        NoSeriesMgt: Codeunit "No. Series";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;

        if "Insurance Quote No." = '' then
            "Insurance Quote No." :=
                NoSeriesMgt.GetNextNo("No. Series", WorkDate(), true);
    end;

    trigger OnModify()
    begin
        "Modified By" := UserId;
        "Modified DateTime" := CurrentDateTime;
    end;

    procedure CalculateInsuranceValue(): Decimal
    begin
        if "Hull Value" > 0 then
            exit(Round("Hull Value" * "Insurance %" / 100, 0.01));
        exit(0);
    end;
}