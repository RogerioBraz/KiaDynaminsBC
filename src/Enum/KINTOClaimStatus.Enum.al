enum 50468 "KINTO Claim Status"
{
    Caption = 'KINTO Claim Status';
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; "With Insurer") { Caption = 'With Insurer'; }
    value(2; Approved) { Caption = 'Approved'; }
    value(3; Paid) { Caption = 'Paid'; }
    value(4; Denied) { Caption = 'Denied'; }
    value(5; Closed) { Caption = 'Closed'; }
}
