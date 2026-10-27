enum 60010 "KINTO Subtask Status"
{
    Caption = 'KINTO Subtask Status';
    Extensible = true;

    value(0; "Pending") { Caption = 'Pending'; }
    value(1; "In Progress") { Caption = 'In Progress'; }
    value(2; "Completed") { Caption = 'Completed'; }
    value(3; "Blocked") { Caption = 'Blocked'; }
    value(4; "Cancelled") { Caption = 'Cancelled'; }
}
