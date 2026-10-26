enum 50443 "KINTO Device Event"
{
    Caption = 'KINTO Device Event';
    Extensible = true;

    value(0; Installed) { Caption = 'Installed'; }
    value(1; Removed) { Caption = 'Removed'; }
    value(2; "Sent to Vendor") { Caption = 'Sent to Vendor'; }
    value(3; "Received from Vendor") { Caption = 'Received from Vendor'; }
    value(4; "Plan Changed") { Caption = 'Plan Changed'; }
    value(5; Retired) { Caption = 'Retired'; }
}
