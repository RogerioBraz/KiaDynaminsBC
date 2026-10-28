enum 60304 "KINTO Block Reason"
{
    Caption = 'KINTO Block Reason';
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Credit") { Caption = 'Credit Restriction'; }
    value(2; "Overdue") { Caption = 'Overdue Payment'; }
    value(3; "Contract Breach") { Caption = 'Contract Breach'; }
    value(4; "Fraud") { Caption = 'Fraud Suspect'; }
    value(5; "Legal") { Caption = 'Legal Restriction'; }
    value(6; "Commercial") { Caption = 'Commercial Decision'; }
}
