table 50111 "KINTO Quote Item"
{
    Caption = 'KINTO Quote Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Quote No."; Code[20]) { Caption = 'Quote No.'; TableRelation = "KINTO Quote Header"; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item; }
        field(4; "Description"; Text[100]) { Caption = 'Description'; }
        field(5; "Vehicle Model No."; Code[20]) { Caption = 'Vehicle Model'; TableRelation = "KINTO Vehicle Model"; }
        field(6; "Vehicle Variant"; Code[20]) { Caption = 'Vehicle Variant'; }
        field(7; "Usage Type"; Enum "KINTO Usage Type") { Caption = 'Usage Type'; }
        field(8; "Vehicle Condition"; Enum "KINTO Vehicle Condition") { Caption = 'Vehicle Condition'; }
        field(9; "Inventory Vehicle No."; Code[20]) { Caption = 'Inventory Vehicle No.'; TableRelation = "KINTO Inventory Vehicle"; }
        field(10; "Contract Term (Months)"; Integer) { Caption = 'Contract Term (months)'; }
        field(11; "Monthly Mileage (km)"; Decimal) { Caption = 'Monthly Mileage (km)'; }
        field(12; "Payment Allowance (days)"; Integer) { Caption = 'Payment Allowance (days)'; }
        field(13; "Lead Time (days)"; Integer) { Caption = 'Lead Time for Delivery (days)'; }
        field(14; "Insurance Risk Level"; Code[10]) { Caption = 'Insurance Risk Level'; }
        field(15; "Target ROI %"; Decimal) { Caption = 'Target ROI %'; DecimalPlaces = 0 : 5; }
        field(16; "Standard Target ROI %"; Decimal) { Caption = 'Standard Target ROI %'; DecimalPlaces = 0 : 5; }
        field(17; "MSRP"; Decimal)
        {
            Caption = 'MSRP';
            trigger OnValidate()
            begin
                Rec."Purchase Price" := Rec.CalculatePurchasePrice();
            end;
        }
        field(18; "Discount Rate %"; Decimal)
        {
            Caption = 'Discount Rate %';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                Rec."Purchase Price" := Rec.CalculatePurchasePrice();
            end;
        }
        field(19; "Equipment Price"; Decimal)
        {
            Caption = 'Equipment Price';
            trigger OnValidate()
            begin
                Rec."Purchase Price" := Rec.CalculatePurchasePrice();
                Rec."Total Equipment Price" := Rec."Equipment Price";
            end;
        }
        field(20; "Purchase Price"; Decimal) { Caption = 'Purchase Price (incl. Equipment)'; Editable = false; }
        field(21; "Total Equipment Price"; Decimal) { Caption = 'Total Equipment Price'; }
        field(22; "Depreciation Market %"; Decimal)
        {
            Caption = 'Depreciation (Market) %';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                if Rec."Purchase Price" > 0 then
                    Rec."Final Resale Price" := Rec.CalculateFinalResalePrice();
            end;
        }
        field(23; "Resale Price to Customer"; Decimal) { Caption = 'Resale Price to Direct Customer'; }
        field(24; "Discount to DLR %"; Decimal)
        {
            Caption = 'Discount to DLR or 3rd Party %';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                if Rec."Purchase Price" > 0 then
                    Rec."Final Resale Price" := Rec.CalculateFinalResalePrice();
            end;
        }
        field(25; "Final Resale Price"; Decimal) { Caption = 'Final Resale Price'; Editable = false; }
        field(26; "Resale Cost %"; Decimal) { Caption = 'Resale Cost %'; DecimalPlaces = 0 : 5; }
        field(27; "Depreciation Accounting %"; Decimal) { Caption = 'Depreciation (Accounting) %'; DecimalPlaces = 0 : 5; }
        field(28; "Monthly Tariff"; Decimal) { Caption = 'Monthly Tariff'; }
        field(29; "Negotiated Monthly Price"; Decimal) { Caption = 'Negotiated Monthly Price'; }
        field(30; "DLR Sales Commission %"; Decimal) { Caption = 'DLR Sales Commission %'; DecimalPlaces = 0 : 5; }
        field(31; "DLR Delivery Commission %"; Decimal) { Caption = 'DLR Delivery Commission %'; DecimalPlaces = 0 : 5; }
        field(32; "DLR Commission Amount"; Decimal) { Caption = 'DLR Commission Amount'; }
        field(33; "Mfr. Sales Commission %"; Decimal) { Caption = 'Manufacturer Sales Commission %'; DecimalPlaces = 0 : 5; }
        field(34; "Mfr. Delivery Commission %"; Decimal) { Caption = 'Manufacturer Delivery Commission %'; DecimalPlaces = 0 : 5; }
        field(35; "Total Mfr. Discount %"; Decimal) { Caption = 'Total Manufacturer Discount %'; DecimalPlaces = 0 : 5; }
        field(36; "KINTO Sales Comm. %"; Decimal) { Caption = 'KINTO Sales Commission %'; DecimalPlaces = 0 : 5; }
        field(37; "KINTO Delivery Comm. %"; Decimal) { Caption = 'KINTO Delivery Commission %'; DecimalPlaces = 0 : 5; }
        field(38; "Annual Inflation %"; Decimal) { Caption = 'Annual Inflation %'; DecimalPlaces = 0 : 5; }
        field(39; "Maintenance Inflation %"; Decimal) { Caption = 'Inflation of Maintenance/Tire %'; DecimalPlaces = 0 : 5; }
        field(40; "CDI %"; Decimal) { Caption = 'CDI %'; DecimalPlaces = 0 : 5; }
        field(41; "Spread"; Decimal) { Caption = 'Spread'; DecimalPlaces = 0 : 5; }
        field(42; "Interest Rate %"; Decimal) { Caption = 'Interest Rate %'; DecimalPlaces = 0 : 5; }
        field(43; "Idleness Rate %"; Decimal) { Caption = 'Idleness Rate %'; DecimalPlaces = 0 : 5; }
        field(44; "Credit Risk %"; Decimal) { Caption = 'Credit Risk %'; DecimalPlaces = 0 : 5; }
        field(45; "SGA Amount"; Decimal) { Caption = 'SG&A'; }
        field(46; "Tax Depreciation Period"; Integer) { Caption = 'Tax Depreciation Period'; }
        field(47; "PIS COFINS Tariff %"; Decimal) { Caption = 'PIS/COFINS on Tariff %'; DecimalPlaces = 0 : 5; }
        field(48; "PIS COFINS Credit %"; Decimal) { Caption = 'PIS/COFINS Credit on Depreciation %'; DecimalPlaces = 0 : 5; }
        field(49; "IPVA Rate %"; Decimal) { Caption = 'IPVA Rate %'; DecimalPlaces = 0 : 5; }
        field(50; "Profit Tax Rate %"; Decimal) { Caption = 'Profit Tax Rate %'; DecimalPlaces = 0 : 5; }
        field(51; "Vehicle Registration Cost"; Decimal) { Caption = 'Vehicle Registration Cost'; }
        field(52; "DPVAT Licensing"; Decimal) { Caption = 'DPVAT + Licensing'; }
        field(53; "Body Insurance"; Decimal) { Caption = 'Vehicle Body Insurance'; }
        field(54; "Third Party Insurance"; Decimal) { Caption = '3rd Party Insurance'; }
        field(55; "Roadside Assistance Y1"; Decimal) { Caption = 'Road Side Assistance (1st Year)'; }
        field(56; "Roadside Assistance Y2"; Decimal) { Caption = 'Road Side Assistance (2nd Year)'; }
        field(57; "Roadside Assistance Y3"; Decimal) { Caption = 'Road Side Assistance (3rd Year)'; }
        field(58; "Spare Car Expense"; Decimal) { Caption = 'Spare Car Expense'; }
        field(59; "KINTO Share Coupon"; Decimal) { Caption = 'KINTO Share Coupon'; }
        field(60; "Return Expense"; Decimal) { Caption = 'Return Expense'; }
        field(61; "Traffic Fine Fee Monthly"; Decimal) { Caption = 'Traffic Fine System Fee (monthly)'; }
        field(62; "Telematics Monthly"; Decimal) { Caption = 'Telematics (unit/month)'; }
        field(63; "Tire Expense"; Decimal) { Caption = 'Tire Expense (1 change)'; }
        field(64; "Tire Change Timing (km)"; Decimal) { Caption = 'Tire Change Timing (km)'; }
        field(65; "Number of Tires"; Integer) { Caption = 'Number of Tires'; }
        field(66; "Maintenance Discount %"; Decimal) { Caption = 'Maintenance Discount Rate %'; DecimalPlaces = 0 : 5; }
        field(67; "Contingency Amount"; Decimal) { Caption = 'Contingency for Corrective Maintenance'; }
        field(68; "Contingency Description"; Text[250]) { Caption = 'Contingency Description'; }
        field(69; "Maintenance Plan ID"; Code[20]) { Caption = 'Maintenance Plan ID'; TableRelation = "KINTO Maintenance Plan Header"; }
        field(70; "Incl. Preventive Maint."; Boolean) { Caption = 'Inclusion of Preventive Maintenance'; }
        field(71; "Incl. Corrective Maint."; Boolean) { Caption = 'Inclusion of Corrective Maintenance'; }
        field(72; "KINTO IRR"; Decimal) { Caption = 'KINTO IRR'; DecimalPlaces = 0 : 10; }
        field(73; "Reference IRR"; Decimal) { Caption = 'Reference IRR'; DecimalPlaces = 0 : 10; }
        field(74; "Calculated ROI"; Decimal) { Caption = 'Calculated ROI'; DecimalPlaces = 0 : 10; }
        field(75; "EBT"; Decimal) { Caption = 'EBT'; }
        field(76; "PAT"; Decimal) { Caption = 'PAT'; }
        field(77; "KINTO FCF"; Decimal) { Caption = 'KINTO FCF'; }
        field(78; "Pricing Status"; Enum "KINTO Pricing Status") { Caption = 'Pricing Status'; }
        field(79; "Error Message"; Text[250]) { Caption = 'Error Message'; }
        field(80; "Contract Start Month"; Integer) { Caption = 'Contract Start Month'; }
        field(81; "Extended Analysis Months"; Integer) { Caption = 'Extended Analysis Months'; }
        field(82; "Initial Value (Used)"; Decimal) { Caption = 'Initial Value (Used Vehicle)'; }
        field(83; "Frozen Booking Value"; Decimal) { Caption = 'Frozen Booking Value'; }
        field(84; "Projected Residual Value"; Decimal) { Caption = 'Projected Residual Value'; }
        field(85; "Projected Depreciation"; Decimal) { Caption = 'Projected Depreciation'; }
        field(86; "Monthly Booking Value"; Decimal) { Caption = 'Monthly Booking Value'; }
        field(87; "Participates in Pool"; Boolean) { Caption = 'Participates in Pool'; }
        field(88; "Over-Mileage Billing Rules"; Text[250]) { Caption = 'Over-Mileage Billing Rules'; }
        field(89; "Price per Excess km 10%"; Decimal) { Caption = 'Price per excess kilometer up to 10%'; }
        field(90; "Price per Excess km >10%"; Decimal) { Caption = 'Price per excess kilometer above 10%'; }
        field(91; "Adjustment Index"; Text[30]) { Caption = 'Applied adjustment index'; }
        field(92; "Adjustment Period"; Option) { Caption = 'Adjustment period for monthly fee'; OptionMembers = No,Monthly,Annually; }
        field(93; "Admin Fee"; Decimal) { Caption = 'Administrative fee'; }
        field(94; "Fine Admin Fee Per Event"; Decimal) { Caption = 'Fine Administration Fee – Per Event'; }
        field(95; "Non-Withdrawal Fee Per Day"; Decimal) { Caption = 'Expense for Non-Withdrawal – Per Day'; }
        field(96; "Advanced Post"; Boolean) { Caption = 'Advanced Post'; }
        field(97; "Deadline Submit Police Rep."; Text[30]) { Caption = 'Deadline to Submit Police Report'; }
        field(98; "Reimbursement Due Date"; Text[30]) { Caption = 'Reimbursement Due Date'; }
        field(99; "Delivery Spare Vehicle"; Text[50]) { Caption = 'Delivery of Spare Vehicle'; }
        field(100; "Inclusion of Armoring"; Boolean) { Caption = 'Inclusion of armoring'; }
        field(101; "Glass Coverage Type"; Text[30]) { Caption = 'Type of glass coverage'; }

        // CAMPOS DE SEGURO E PACOTES (integrados diretamente — não usar TableExtension)
        field(110; "Insurance Quote No."; Code[20])
        {
            Caption = 'Insurance Quote No.';
            TableRelation = "KINTO Insurance Quote";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InsQuote: Record "KINTO Insurance Quote";
            begin
                if Rec."Insurance Quote No." = '' then exit;
                if not InsQuote.Get(Rec."Insurance Quote No.") then
                    Error('Cotação de seguro %1 não encontrada.', Rec."Insurance Quote No.");

                Rec."Body Insurance" := InsQuote."Insurance Value";

                if InsQuote."KINTO Quote No." <> '' then
                    Error('Cotação de seguro %1 já está vinculada à cotação %2.',
                        Rec."Insurance Quote No.", InsQuote."KINTO Quote No.");

                InsQuote."KINTO Quote No." := Rec."Quote No.";
                InsQuote."KINTO Quote Line No." := Rec."Line No.";
                InsQuote.Modify(true);
            end;
        }
        field(111; "Glass Coverage Package ID"; Code[20]) { Caption = 'Glass Coverage'; TableRelation = "KINTO Glass Coverage Package"; DataClassification = CustomerContent; }
        field(112; "24h Assistance Package ID"; Code[20]) { Caption = '24h Assistance'; TableRelation = "KINTO 24h Assistance Package"; DataClassification = CustomerContent; }
        field(113; "Pickup Delivery Package ID"; Code[20]) { Caption = 'Pick-up & Delivery'; TableRelation = "KINTO Pickup Delivery Package"; DataClassification = CustomerContent; }
        field(114; "Replacement Vehicle Pkg ID"; Code[20]) { Caption = 'Replacement Vehicle'; TableRelation = "KINTO Replacement Vehicle Pkg"; DataClassification = CustomerContent; }
        field(115; "Tire Package ID"; Code[20]) { Caption = 'Tire Package'; TableRelation = "KINTO Tire Package"; DataClassification = CustomerContent; }
        field(116; "Service Package ID"; Code[20]) { Caption = 'Service Package'; TableRelation = "KINTO Service Package"; DataClassification = CustomerContent; }
        field(117; "Replacement Vehicle Uses"; Integer) { Caption = 'Replacement Vehicle Uses'; DataClassification = CustomerContent; }
        field(118; "Tire Quantity"; Integer) { Caption = 'Tire Quantity'; DataClassification = CustomerContent; }
    }

    keys { key(PK; "Quote No.", "Line No.") { Clustered = true; } }

    trigger OnInsert()
    begin
        "Pricing Status" := "Pricing Status"::Draft;
    end;

    // CORREÇÃO CRÍTICA: OnModify compara xRec com Rec
    trigger OnModify()
    var
        CFData: Record "KINTO Cash Flow Data";
        CFHeader: Record "KINTO Cash Flow Header";
    begin
        if (xRec."Pricing Status" = xRec."Pricing Status"::Calculated) and
           (Rec."Pricing Status" = xRec."Pricing Status"::Calculated) then begin
            CFData.SetRange("Quote No.", Rec."Quote No.");
            CFData.SetRange("Quote Line No.", Rec."Line No.");
            if CFData.FindSet() then CFData.DeleteAll();

            CFHeader.SetRange("Quote No.", Rec."Quote No.");
            CFHeader.SetRange("Quote Line No.", Rec."Line No.");
            if CFHeader.FindFirst() then CFHeader.Delete();

            Rec."Pricing Status" := Rec."Pricing Status"::Draft;
        end;
    end;

    // CORREÇÃO CRÍTICA: Adicionado / 100 nas fórmulas percentuais
    procedure CalculatePurchasePrice(): Decimal
    begin
        exit(Round("MSRP" * (1 - "Discount Rate %" / 100) + "Equipment Price", 0.01));
    end;

    procedure CalculateFinalResalePrice(): Decimal
    var
        ResaleToCustomer: Decimal;
    begin
        ResaleToCustomer := "Purchase Price" * (1 - "Depreciation Market %" / 100);
        exit(Round(ResaleToCustomer * (1 - "Discount to DLR %" / 100), 0.01));
    end;
}