tableextension 50101 "KINTO Customer Extension" extends Customer
{
    fields
    {
        field(50100; "KINTO Customer Type"; Enum "KINTO Customer Type") { Caption = 'KINTO Customer Type'; DataClassification = CustomerContent; }
        field(50101; "KINTO Credit Score"; Code[5]) { Caption = 'KINTO Credit Score'; DataClassification = CustomerContent; }
        field(50102; "KINTO Credit Risk Override %"; Decimal) { Caption = 'KINTO Credit Risk Factor Override %'; DecimalPlaces = 0 : 5; DataClassification = CustomerContent; }
        field(50103; "KINTO Eligible for reKINTO"; Boolean) { Caption = 'KINTO Eligible for reKINTO'; DataClassification = CustomerContent; }

    }
}