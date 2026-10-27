enum 60002 "KINTO Telematic Trigger"
{
    Caption = 'KINTO Telematic Maintenance Trigger';
    Extensible = true;

    value(0; "None") { Caption = ' '; }
    value(1; "Fault Code") { Caption = 'Fault Code (DTC)'; }
    value(2; "Odometer Reached") { Caption = 'Odometer Threshold Reached'; }
    value(3; "Service Interval") { Caption = 'Service Interval Elapsed'; }
    value(4; "Low Fluids") { Caption = 'Low Fluids Warning'; }
    value(5; "Brake Wear") { Caption = 'Brake Wear Alert'; }
}
