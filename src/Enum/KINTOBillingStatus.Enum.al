enum 50171 "KINTO Billing Status"
{
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; Approved) { Caption = 'Approved'; }
    value(2; Invoiced) { Caption = 'Invoiced'; }
    value(3; Cancelled) { Caption = 'Cancelled'; }
    value(4; Credited) { Caption = 'Credited'; }
}