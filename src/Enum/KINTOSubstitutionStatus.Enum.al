enum 50464 "KINTO Substitution Status"
{
    Caption = 'KINTO Substitution Status';
    Extensible = true;

    value(0; Requested) { Caption = 'Requested'; }
    value(1; "Vehicle Allocated") { Caption = 'Vehicle Allocated'; }
    value(2; Delivered) { Caption = 'Delivered'; }
    value(3; Completed) { Caption = 'Completed (definitive)'; }
    value(4; Cancelled) { Caption = 'Cancelled'; }
}
