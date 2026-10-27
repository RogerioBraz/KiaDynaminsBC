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
        }
    }
}
