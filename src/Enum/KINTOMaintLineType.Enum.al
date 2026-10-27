enum 60001 "KINTO Maint Line Type"
{
    Caption = 'KINTO Maintenance Line Type';
    Extensible = true;

    value(0; "Part") { Caption = 'Part'; }
    value(1; "Labor") { Caption = 'Labor (HH)'; }
    value(2; "Service") { Caption = 'External Service'; }
}
