enum 50471 "KINTO Portal Sync Status"
{
    Caption = 'KINTO Portal Sync Status';
    Extensible = true;

    value(0; Pending) { Caption = 'Pending'; }
    value(1; Sent) { Caption = 'Sent'; }
    value(2; Error) { Caption = 'Error'; }
}
