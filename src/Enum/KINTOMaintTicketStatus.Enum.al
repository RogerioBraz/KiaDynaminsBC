enum 50175 "KINTO Maint Ticket Status"
{
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; "In Analysis") { Caption = 'In Analysis'; }
    value(2; "Pending Approval") { Caption = 'Pending Approval'; }
    value(3; Approved) { Caption = 'Approved'; }
    value(4; "In Execution") { Caption = 'In Execution'; }
    value(5; "Pending Invoice") { Caption = 'Pending Invoice'; }
    value(6; Closed) { Caption = 'Closed'; }
    value(7; Rejected) { Caption = 'Rejected'; }
    value(8; Cancelled) { Caption = 'Cancelled'; }
}