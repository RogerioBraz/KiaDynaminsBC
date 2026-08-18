tableextension 50100 "KINTO Item Extension" extends Item
{
    fields
    {
        field(50100; "KINTO Category"; Enum "KINTO Item Category")
        {
            Caption = 'KINTO Category';
        }

        field(50101; "KINTO Subcategory"; Code[20])
        {
            Caption = 'KINTO Subcategory';
        }

        field(50102; "Vehicle Model No."; Code[20])
        {
            Caption = 'Vehicle Model';
            TableRelation = "KINTO Vehicle Model";
        }

        field(50103; "Vehicle Version"; Text[50])
        {
            Caption = 'Vehicle Version';
        }

        field(50104; "Vehicle Year"; Integer)
        {
            Caption = 'Vehicle Year';
        }

        field(50105; "Vehicle Market Code"; Text[30])
        {
            Caption = 'Vehicle Market Code';
        }

        field(50106; "Vehicle Tax %"; Decimal)
        {
            Caption = 'Vehicle Tax %';
            DecimalPlaces = 0 : 5;
        }

        field(50107; "Vehicle Condition"; Enum "KINTO Vehicle Condition")
        {
            Caption = 'Condition';
        }

        field(50108; "Vehicle Mileage"; Integer)
        {
            Caption = 'Mileage';
        }

        field(50109; "Vehicle Age Months"; Integer)
        {
            Caption = 'Age in Months';
        }

        field(50110; "Latest 0km Model"; Boolean)
        {
            Caption = 'Latest 0km Model';
        }

        field(50111; "Fixed Asset Eligible"; Boolean)
        {
            Caption = 'Fixed Asset Eligible';
        }

        field(50112; "Show on Dealer Portal"; Boolean)
        {
            Caption = 'Show on Dealer Portal';
        }

        field(50113; "Block Pre-Approved Pricing"; Boolean)
        {
            Caption = 'Block Pre-Approved Pricing';
        }

        field(50114; "Pool Allowed"; Option)
        {
            Caption = 'Pool Allowed';
            OptionMembers = No,Yes,"Yes (Restricted)";
        }

        field(50115; "Valid for All Vehicles"; Boolean)
        {
            Caption = 'Valid for All Vehicles';
        }

        field(50116; "Implement is Removable"; Boolean)
        {
            Caption = 'Implement is Removable';
        }
        field(50117; "Part Number"; Text[30])
        {
            Caption = 'Part Number';
        }

        field(50118; "Property Damage %"; Decimal)
        {
            Caption = 'Property Damage %';
            DecimalPlaces = 0 : 5;
        }

        field(50119; "Moral Damages %"; Decimal)
        {
            Caption = 'Moral Damages %';
            DecimalPlaces = 0 : 5;
        }

        field(50120; "Bodily Injury %"; Decimal)
        {
            Caption = 'Bodily Injury %';
            DecimalPlaces = 0 : 5;
        }

        field(50121; "PPA Death Benefit %"; Decimal)
        {
            Caption = 'PPA Death Benefit %';
            DecimalPlaces = 0 : 5;
        }

        field(50122; "PPA Permanent Disability %"; Decimal)
        {
            Caption = 'PPA Permanent Disability %';
            DecimalPlaces = 0 : 5;
        }

        field(50123; "Vehicle Body Coverage %"; Decimal)
        {
            Caption = 'Vehicle Body Coverage %';
            DecimalPlaces = 0 : 5;
        }

        field(50124; "Deductible Type"; Option)
        {
            Caption = 'Deductible Type';
            OptionMembers = "Fixed Amount","Percentage";
        }

        field(50125; "Deductible Amount"; Decimal)
        {
            Caption = 'Deductible';
        }

        field(50126; "Coverage Limit Type"; Option)
        {
            Caption = 'Coverage Limit Type';
            OptionMembers = "Fixed Amount","Unlimited";
        }

        field(50127; "Coverage Limit"; Decimal)
        {
            Caption = 'Coverage Limit';
        }

        field(50128; "Comm. Depreciation %"; Decimal)
        {
            Caption = 'Commercial Depreciation %';
            DecimalPlaces = 0 : 5;
        }

        field(50129; "Remarketing Sales Comm. %"; Decimal)
        {
            Caption = 'Remarketing Sales Commission %';
            DecimalPlaces = 0 : 5;
        }

        field(50130; "Discontinued Date"; Date)
        {
            Caption = 'Discontinued Date';
        }

        field(50131; "Billing from Supplier Freq."; Integer)
        {
            Caption = 'Billing from Supplier Frequency';
        }

        field(50132; "MSRP Metallic Paint"; Decimal)
        {
            Caption = 'MSRP with Metallic Paint';
        }

        field(50133; "Metallic Paint Adjustment %"; Decimal)
        {
            Caption = 'Metallic Paint Adjustment %';
            DecimalPlaces = 0 : 5;
        }
    }
}