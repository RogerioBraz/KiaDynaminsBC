enum 60012 "KINTO PreClosure Status"
{
    Caption = 'KINTO Pre-Closure Status';
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; Notified) { Caption = 'Customer Notified'; }
    value(2; "Checklist Done") { Caption = 'Checklist Complete'; }
    value(3; "Ready for Return") { Caption = 'Ready for Return'; }
    value(4; Converted) { Caption = 'Converted to Return'; }
    value(5; Cancelled) { Caption = 'Cancelled'; }
}
