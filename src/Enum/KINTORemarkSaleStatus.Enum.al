enum 50448 "KINTO Remark. Sale Status"
{
    Caption = 'KINTO Remarketing Sale Status';
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; "Price Approved") { Caption = 'Price Approved (4-eyes)'; }
    value(2; Sold) { Caption = 'Sold'; }
    value(3; Invoiced) { Caption = 'Invoiced'; }
    value(4; Paid) { Caption = 'Paid'; }
    value(5; Completed) { Caption = 'Completed (asset written off)'; }
    value(6; Cancelled) { Caption = 'Cancelled'; }
}
