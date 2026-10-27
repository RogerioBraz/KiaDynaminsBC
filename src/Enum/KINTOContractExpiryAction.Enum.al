enum 60004 "KINTO Contract Expiry Action"
{
    Caption = 'KINTO Contract Expiry Action';
    Extensible = true;

    value(0; "Notice Sent") { Caption = 'Notice Sent (pre-expiry)'; }
    value(1; "Expired") { Caption = 'Contract Expired'; }
    value(2; "Auto Extended") { Caption = 'Auto Extended'; }
    value(3; "Escalated") { Caption = 'Escalated to Collection'; }
    value(4; "Evaluation Due") { Caption = 'Customer Evaluation Due'; }
}
