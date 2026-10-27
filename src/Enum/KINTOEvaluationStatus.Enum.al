enum 60007 "KINTO Evaluation Status"
{
    Caption = 'KINTO Evaluation Status';
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; "In Review") { Caption = 'In Review'; }
    value(2; Completed) { Caption = 'Completed'; }
    value(3; Cancelled) { Caption = 'Cancelled'; }
}
