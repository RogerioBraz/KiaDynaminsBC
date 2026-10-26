enum 50470 "KINTO Portal Event Type"
{
    Caption = 'KINTO Portal Event Type';
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Availability Sent") { Caption = 'Availability Sent (touchpoint 1)'; }
    value(2; "Sale Posted") { Caption = 'Sale Posted (touchpoint 2)'; }
    value(3; "Asset Written Off") { Caption = 'Asset Written Off (touchpoint 3)'; }
    value(4; Error) { Caption = 'Error'; }
}
