enum 50173 "KINTO Contract Change Type"
{
    Extensible = true;

    value(0; Created) { Caption = 'Created'; }
    value(1; Activated) { Caption = 'Activated'; }
    value(2; Extended) { Caption = 'Extended'; }
    value(3; Renegotiated) { Caption = 'Renegotiated'; }
    value(4; Terminated) { Caption = 'Terminated'; }
    value(5; ConditionChanged) { Caption = 'Condition Changed'; }
    value(6; BillingGenerated) { Caption = 'Billing Generated'; }
}