enum 50444 "KINTO Policy Status"
{
    Caption = 'KINTO Policy Status';
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; Active) { Caption = 'Active'; }
    value(2; Expired) { Caption = 'Expired'; }
    value(3; Cancelled) { Caption = 'Cancelled'; }
}
