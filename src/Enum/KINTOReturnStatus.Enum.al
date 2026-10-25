enum 50182 "KINTO Return Status"
{
    Extensible = true;

    value(0; Scheduled) { Caption = 'Scheduled'; }
    value(1; "In Progress") { Caption = 'In Progress'; }
    value(2; Completed) { Caption = 'Completed'; }
    value(3; "With Pending Items") { Caption = 'Completed with Pending Items'; }
    value(4; Cancelled) { Caption = 'Cancelled'; }
}