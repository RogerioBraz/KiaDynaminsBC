enum 50113 "KINTO Risk Level"
{
    Extensible = true;
    value(0; "Baixo") { Caption = 'Baixo'; }
    value(1; "Médio") { Caption = 'Médio'; }
    value(2; "Alto") { Caption = 'Alto'; }
    value(3; "Agravado") { Caption = 'Agravado'; }
}

enum 50114 "KINTO Restricted Customer Level"
{
    Extensible = true;
    value(0; "None") { Caption = 'None'; }
    value(1; "NV1") { Caption = 'NV1'; }
    value(2; "NV2") { Caption = 'NV2'; }
    value(3; "NV3") { Caption = 'NV3'; }
}

enum 50115 "KINTO Insurance Status"
{
    Extensible = true;
    value(0; "Inativo") { Caption = 'Inativo'; }
    value(1; "Ativo") { Caption = 'Ativo'; }
}