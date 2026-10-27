enum 60008 "KINTO Vehicle Doc Type"
{
    Caption = 'KINTO Vehicle Document Type';
    Extensible = true;

    value(0; "CRLV") { Caption = 'CRLV (Vehicle Registration)'; }
    value(1; "Cautelar") { Caption = 'Laudo Cautelar (Inspection Report)'; }
    value(2; "Insurance") { Caption = 'Insurance Certificate'; }
    value(3; "Invoice") { Caption = 'Purchase Invoice'; }
    value(4; "Licensing") { Caption = 'Licensing / IPVA'; }
    value(5; "Contract") { Caption = 'Contract Document'; }
    value(6; "Other") { Caption = 'Other'; }
}
