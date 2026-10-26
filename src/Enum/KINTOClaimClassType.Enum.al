enum 50467 "KINTO Claim Class Type"
{
    Caption = 'KINTO Claim Class Type';
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Total Destruction") { Caption = 'Total Destruction (>= 70% market value)'; }
    value(2; Theft) { Caption = 'Theft'; }
    value(3; PartialDamage) { Caption = 'Partial Damage'; }
    value(4; "Third Party") { Caption = 'Third Party'; }
    value(5; "Glass Only") { Caption = 'Glass Only'; }
}
