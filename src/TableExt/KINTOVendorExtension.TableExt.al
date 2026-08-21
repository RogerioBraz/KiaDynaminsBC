tableextension 50102 "KINTO Vendor Extension" extends Vendor
{
    fields
    {
        // Removido KINTO Dealer boolean — agora é via Vendor Category
        field(50100; "KINTO Is Dealer"; Boolean)
        {
            Caption = 'KINTO Dealer';
            FieldClass = FlowField;
            CalcFormula = exist("KINTO Vendor Category Assign" where("Vendor No." = field("No."), "Category Code" = const('DEALER')));
            Editable = false;
        }
        field(50101; "KINTO Has Portal Access"; Boolean)
        {
            Caption = 'KINTO Dealer Portal Access';
            FieldClass = FlowField;
            CalcFormula = exist("KINTO Vendor Contact" where("Vendor No." = field("No."), "Dealer Portal Access" = const(true)));
            Editable = false;
        }

        field(50102; "KINTO Default DLR Sales Comm %"; Decimal) { Caption = 'KINTO Default DLR Sales Commission %'; DecimalPlaces = 0 : 5; }
        field(50103; "KINTO Default DLR Delivery Comm %"; Decimal) { Caption = 'KINTO Default DLR Delivery Commission %'; DecimalPlaces = 0 : 5; }
        field(50104; "KINTO Max Sales Commission %"; Decimal) { Caption = 'KINTO Max Sales Commission %'; DecimalPlaces = 0 : 5; }
        field(50105; "KINTO Max Delivery Commission %"; Decimal) { Caption = 'KINTO Max Delivery Commission %'; DecimalPlaces = 0 : 5; }
        field(50106; "KINTO VD Sales Commission %"; Decimal) { Caption = 'KINTO VD Sales Commission % (by Vehicle Model)'; DecimalPlaces = 0 : 5; }
        field(50107; "KINTO VD Delivery Commission %"; Decimal) { Caption = 'KINTO VD Delivery Commission % (by Vehicle Model)'; DecimalPlaces = 0 : 5; }

    }
}