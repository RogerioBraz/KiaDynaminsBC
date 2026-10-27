enum 60009 "KINTO Downtime Reason"
{
    Caption = 'KINTO Downtime Reason';
    Extensible = true;

    value(0; "Maintenance") { Caption = 'Maintenance'; }
    value(1; "Accident") { Caption = 'Accident / Claim'; }
    value(2; "Recall") { Caption = 'Manufacturer Recall'; }
    value(3; "Documentation") { Caption = 'Documentation Hold'; }
    value(4; "Other") { Caption = 'Other'; }
}
