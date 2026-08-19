table 50105 "KINTO CF Component"
{
    Caption = 'KINTO Cash Flow Component';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO CF Component List";

    fields
    {
        field(1; "Component ID"; Code[30]) { Caption = 'Component ID'; }
        field(2; "Description"; Text[100]) { Caption = 'Description'; }
        field(3; "Component Type"; Enum "KINTO CF Component Type") { Caption = 'Component Type'; }
        field(4; "Calculation Method"; Enum "KINTO CF Calc Method") { Caption = 'Calculation Method'; }
        field(5; "Value Definition"; Decimal) { Caption = 'Value Definition'; DecimalPlaces = 0 : 5; }
        field(6; "Base Reference"; Code[30]) { Caption = 'Base Reference'; }
        field(7; "Sign"; Enum "KINTO CF Sign") { Caption = 'Sign'; }
        field(8; "Frequency"; Enum "KINTO CF Frequency") { Caption = 'Frequency'; }
        field(9; "Calculate in Month Zero"; Boolean) { Caption = 'Calculate in Month Zero'; }
        field(10; "Indexation Applied"; Boolean) { Caption = 'Indexation Applied'; }
        field(11; "Indexation Frequency"; Enum "KINTO Inflation Frequency") { Caption = 'Index Application Frequency'; }
        field(12; "Extended Calculation"; Boolean) { Caption = 'Extended Component Calculation'; }
        field(13; "Visible in Reports"; Boolean) { Caption = 'Reporting Visibility'; }
        field(14; "Sort Order"; Integer) { Caption = 'Sort Order'; }
        field(15; "Country Code"; Code[10]) { Caption = 'Country Code'; TableRelation = "KINTO Country Setup"; }
    }

    keys
    {
        key(PK; "Component ID", "Country Code") { Clustered = true; }
        key(Idx1; "Sort Order") { }
    }
}