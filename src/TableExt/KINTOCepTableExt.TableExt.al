tableextension 50307 "KINTO Post Code Ext" extends "Post Code"
{
    // ============================================================
    // EXTENSAO DA TABELA POST CODE (225) PARA CEP BRASILEIRO
    //
    // A "Post Code" nativa tem 6 campos (Code, City, Search City,
    // Country/Region Code, County, Time Zone) com PK = Code + City.
    // Um CEP brasileiro nao cabe nisso: faltam logradouro, bairro, UF,
    // IBGE e complemento.
    //
    // NAO se duplica o que ja existe:
    //   Code                -> o CEP (8 digitos)
    //   City                -> municipio
    //   County              -> bairro
    //   Country/Region Code -> 'BR'
    //   Time Zone           -> fica nativo
    // Somente o que falta e adicionado abaixo.
    //
    // Origem: base publica OpenCEP/Correios — 1.209.314 CEPs, 27 UFs.
    // Carga: codeunit 60025. Consulta pontual: codeunit 60023/60025.
    // ============================================================

    fields
    {
        field(60320; "KINTO Street"; Text[150])
        {
            Caption = 'Logradouro';
            DataClassification = CustomerContent;
        }
        field(60321; "KINTO Complement"; Text[80])
        {
            Caption = 'Complemento';
            DataClassification = CustomerContent;
        }
        field(60322; "KINTO Neighborhood"; Text[80])
        {
            Caption = 'Bairro';
            DataClassification = CustomerContent;
        }
        field(60323; "KINTO State"; Code[2])
        {
            Caption = 'UF';
            DataClassification = CustomerContent;
        }
        field(60324; "KINTO IBGE City"; Code[10])
        {
            Caption = 'Código IBGE';
            DataClassification = CustomerContent;
        }
        field(60325; "KINTO CEP Source"; Option)
        {
            Caption = 'Origem';
            DataClassification = SystemMetadata;
            OptionMembers = " ","Base","API";
            OptionCaption = ' ,Base,API';
        }
        field(60326; "KINTO CEP Updated"; DateTime)
        {
            Caption = 'Atualizado em';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(KINTOUFCity; "KINTO State", City) { }
        key(KINTOStreet; "KINTO State", City, "KINTO Street") { }
    }
}
