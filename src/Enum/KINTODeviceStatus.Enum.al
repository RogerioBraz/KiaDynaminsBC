enum 50442 "KINTO Device Status"
{
    Caption = 'KINTO Device Status';
    Extensible = true;

    value(0; "In Stock") { Caption = 'In Stock'; }
    value(1; Installed) { Caption = 'Installed'; }
    value(2; "In Maintenance") { Caption = 'In Maintenance'; }
    value(3; Retired) { Caption = 'Retired'; }
    value(4; Lost) { Caption = 'Lost'; }
}
