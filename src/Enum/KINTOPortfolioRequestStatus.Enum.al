enum 60305 "KINTO Portfolio Request Status"
{
    Caption = 'KINTO Portfolio Transfer Status';
    Extensible = true;

    value(0; "Pending") { Caption = 'Pending Approval'; }
    value(1; "Approved") { Caption = 'Approved'; }
    value(2; "Rejected") { Caption = 'Rejected'; }
    value(3; "Cancelled") { Caption = 'Cancelled'; }
}
