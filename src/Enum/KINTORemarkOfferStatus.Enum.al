enum 50447 "KINTO Remark. Offer Status"
{
    Caption = 'KINTO Remarketing Offer Status';
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; Sent) { Caption = 'Sent'; }
    value(2; Rejected) { Caption = 'Rejected / Expired'; }
    value(3; Accepted) { Caption = 'Accepted'; }
    value(4; Skipped) { Caption = 'Skipped'; }
}
