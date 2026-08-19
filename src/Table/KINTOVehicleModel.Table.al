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
    }

    keys
    {
        key(PK; "Model No.") { Clustered = true; }
    }
}