enum 50178 "KINTO Fine Link Status"
{
    Extensible = true;

    value(0; Unlinked) { Caption = 'Unlinked'; }
    value(1; Linked) { Caption = 'Linked'; }
    value(2; "Linked - Grace Period") { Caption = 'Linked (post-contract grace period)'; }
    value(3; "Not Linkable") { Caption = 'Not Linkable (no contract on date)'; }
}