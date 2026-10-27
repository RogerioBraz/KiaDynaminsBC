enum 60011 "KINTO SLA Violation Type"
{
    Caption = 'KINTO SLA Violation Type';
    Extensible = true;

    value(0; "Response Breach") { Caption = 'Response Time Breach'; }
    value(1; "Resolution Breach") { Caption = 'Resolution Time Breach'; }
    value(2; "Replacement Breach") { Caption = 'Replacement Vehicle Breach'; }
    value(3; "Downtime Exceeded") { Caption = 'Max Downtime Exceeded'; }
    value(4; "Availability Below Target") { Caption = 'Availability Below Target'; }
}
