enum 50466 "KINTO Settlement Type"
{
    Caption = 'KINTO Settlement Type';
    Extensible = true;

    value(0; "Final Balance") { Caption = 'Final Balance (normal)'; }
    value(1; "Total Destruction") { Caption = 'Total Destruction (AR - Finance approval)'; }
    value(2; "Theft Deductible") { Caption = 'Theft Deductible (franquia)'; }
    value(3; "Insurance Recovery") { Caption = 'Insurance Recovery'; }
}
