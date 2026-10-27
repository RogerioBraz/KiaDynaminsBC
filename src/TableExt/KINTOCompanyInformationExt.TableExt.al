tableextension 50110 "KINTO Company Information Ext" extends "Company Information"
{
    fields
    {
        field(60100; "KINTO Country Code"; Code[10])
        {
            Caption = 'KINTO Country';
            DataClassification = CustomerContent;
            TableRelation = "KINTO Country Setup"."Country Code";
            // Vinculo empresa -> KINTO Country Setup. Multi-company: cada empresa
            // aponta para o seu pais, e todos os processos usam ESTE setup.
            // Um pais tem UM setup (PK do Country Setup); varias empresas podem
            // compartilhar o mesmo pais (mesmas regras).
            trigger OnValidate()
            var
                CountrySetup: Record "KINTO Country Setup";
                CountryNotFoundErr: Label 'KINTO Country Setup %1 does not exist. Create the country setup before linking it to the company.';
            begin
                if Rec."KINTO Country Code" = '' then
                    exit;
                if not CountrySetup.Get(Rec."KINTO Country Code") then
                    Error(CountryNotFoundErr, Rec."KINTO Country Code");
            end;
        }
    }
}
