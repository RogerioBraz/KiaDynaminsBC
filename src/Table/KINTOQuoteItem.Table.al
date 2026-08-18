table 50111 "KINTO Quote Item"
{
    Caption = 'KINTO Quote Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            TableRelation = "KINTO Quote Header";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }

        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(5; "Vehicle Model No."; Code[20])
        {
            Caption = 'Vehicle Model';
            TableRelation = "KINTO Vehicle Model";
        }

        field(6; "Vehicle Variant"; Code[20])
        {
            Caption = 'Vehicle Variant';
        }

        field(7; "Usage Type"; Enum "KINTO Usage Type")
        {
            Caption = 'Usage Type';
        }

        field(8; "Vehicle Condition"; Enum "KINTO Vehicle Condition")
        {
            Caption = 'Vehicle Condition';
        }

        field(9; "Inventory Vehicle No."; Code[20])
        {
            Caption = 'Inventory Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }

        field(10; "Contract Term (Months)"; Integer)
        {
            Caption = 'Contract Term (months)';
        }

        field(11; "Monthly Mileage (km)"; Decimal)
        {
            Caption = 'Monthly Mileage (km)';
        }

        field(12; "Payment Allowance (days)"; Integer)
        {
            Caption = 'Payment Allowance (days)';
        }

        field(13; "Lead Time (days)"; Integer)
        {
            Caption = 'Lead Time for Delivery (days)';
        }

        field(14; "Insurance Risk Level"; Code[10])
        {
            Caption = 'Insurance Risk Level';
        }

        field(15; "Target ROI %"; Decimal)
        {
            Caption = 'Target ROI %';
            DecimalPlaces = 0 : 5;
        }

        field(16; "Standard Target ROI %"; Decimal)
        {
            Caption = 'Standard Target ROI %';
            DecimalPlaces = 0 : 5;
        }
        field(17; "MSRP"; Decimal)
        {
            Caption = 'MSRP';
        }
        field(18; "Discount Rate %"; Decimal)
        {
            Caption = 'Discount Rate %';
            DecimalPlaces = 0 : 5;
        }
        field(19; "Equipment Price"; Decimal)
        {
            Caption = 'Equipment Price';
        }
        field(20; "Purchase Price"; Decimal)
        {
            Caption = 'Purchase Price (incl. Equipment)';
        }
        field(21; "Total Equipment Price"; Decimal)
        {
            Caption = 'Total Equipment Price';
        }
        field(22; "Depreciation Market %"; Decimal)

        {
            Caption = 'Depreciation (Market) %';
            DecimalPlaces = 0 : 5;
        }
        field(23; "Resale Price to Customer"; Decimal)
        {
            Caption = 'Resale Price to Direct Customer';
        }
        field(24; "Discount to DLR %"; Decimal)
        {
            Caption = 'Discount to DLR or 3rd Party %';
            DecimalPlaces = 0 : 5;
        }

        field(25; "Final Resale Price"; Decimal)
        {
            Caption = 'Final Resale Price';
        }
        field(26; "Resale Cost %"; Decimal)
        {
            Caption = 'Resale Cost %';
            DecimalPlaces = 0 : 5;

        }

        field(27; "Depreciation Accounting %"; Decimal)

        {

            Caption = 'Depreciation (Accounting) %';

            DecimalPlaces = 0 : 5;

        }

        field(28; "Monthly Tariff"; Decimal)
        {
            Caption = 'Monthly Tariff';
        }
        field(29; "Negotiated Monthly Price"; Decimal)
        {
            Caption = 'Negotiated Monthly Price';
        }
        field(30; "DLR Sales Commission %"; Decimal)
        {
            Caption = 'DLR Sales Commission %';
            DecimalPlaces = 0 : 5;
        }
        field(31; "DLR Delivery Commission %"; Decimal)
        {
            Caption = 'DLR Delivery Commission %';
            DecimalPlaces = 0 : 5;
        }
        field(32; "DLR Commission Amount"; Decimal)
        {
            Caption = 'DLR Commission Amount';
        }
        field(33; "Mfr. Sales Commission %"; Decimal)
        {
            Caption = 'Manufacturer Sales Commission %';
            DecimalPlaces = 0 : 5;
        }
        field(34; "Mfr. Delivery Commission %"; Decimal)
        {
            Caption = 'Manufacturer Delivery Commission %';
            DecimalPlaces = 0 : 5;
        }
        field(35; "Total Mfr. Discount %"; Decimal)
        {

            Caption = 'Total Manufacturer Discount %';

            DecimalPlaces = 0 : 5;

        }

        field(36; "KINTO Sales Comm. %"; Decimal)

        {

            Caption = 'KINTO Sales Commission %';

            DecimalPlaces = 0 : 5;

        }
        field(37; "KINTO Delivery Comm. %"; Decimal)

        {

            Caption = 'KINTO Delivery Commission %';

            DecimalPlaces = 0 : 5;

        }

        field(38; "Annual Inflation %"; Decimal)

        {

            Caption = 'Annual Inflation %';

            DecimalPlaces = 0 : 5;

        }

        field(39; "Maintenance Inflation %"; Decimal)

        {

            Caption = 'Inflation of Maintenance/Tire %';

            DecimalPlaces = 0 : 5;

        }
        field(40; "CDI %"; Decimal)
        {
            Caption = 'CDI %';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(PK; "Quote No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        //"Pricing Status" := "Pricing Status"::Draft;
    end;
} // parei no field 40
