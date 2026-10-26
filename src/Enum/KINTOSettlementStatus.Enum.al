enum 50465 "KINTO Settlement Status"
{
    Caption = 'KINTO Settlement Status';
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; "Pending Approval") { Caption = 'Pending Approval'; }
    value(2; Approved) { Caption = 'Approved'; }
    value(3; Invoiced) { Caption = 'Invoiced'; }
    value(4; Cancelled) { Caption = 'Cancelled'; }
}
