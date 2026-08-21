table 50101 "KINTO Vehicle Model"
{
    Caption = 'KINTO Vehicle Model';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Model No."; Code[20])
        {
            Caption = 'Model No.';
        }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; "Manufacturer Code"; Code[20]) { Caption = 'Manufacturer Code'; }
        field(4; "Brand"; Text[50]) { Caption = 'Brand'; }
        field(5; "Vehicle Type"; Text[30]) { Caption = 'Vehicle Type'; }
        field(6; "Fuel Type"; Option) { Caption = 'Fuel Type'; OptionMembers = Flex,Diesel,Gasoline,Hybrid,Electric; }
        field(7; "Transmission Type"; Option) { Caption = 'Transmission'; OptionMembers = Manual,Automatic,CVT; }
        field(8; "Default Usage Type"; Enum "KINTO Usage Type") { Caption = 'Default Usage Type'; }
        field(9; "Default Monthly Mileage"; Decimal) { Caption = 'Default Monthly Mileage'; }
        field(10; "Default Contract Term"; Integer) { Caption = 'Default Contract Term (months)'; }
        field(11; "Status"; Option) { Caption = 'Status'; OptionMembers = Active,Inactive; }
        field(12; "VD Sales Commission %"; Decimal) { Caption = 'VD Sales Commission %'; DecimalPlaces = 0 : 5; }
        field(13; "VD Delivery Commission %"; Decimal) { Caption = 'VD Delivery Commission %'; DecimalPlaces = 0 : 5; }
        field(14; "VD Commission Model"; Enum "KINTO Commission Model") { Caption = 'VD Commission Model'; }
        field(15; "FIPE Code"; Code[20])
        {
            Caption = 'FIPE Code';
            DataClassification = CustomerContent;
        }

        field(16; "Manufacturer Name"; Text[50])
        {
            Caption = 'Manufacturer Name';
            DataClassification = CustomerContent;
        }

        field(17; "Manufacturer Part Code"; Code[20])
        {
            Caption = 'Manufacturer Part Code';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Model No.") { Clustered = true; }
    }
}