table 50446 "KINTO Remarketing Setup"
{
    Caption = 'KINTO Remarketing Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Country Code"; Code[10]) { Caption = 'Country Code'; }
        field(2; "Target Sale Days"; Integer) { Caption = 'Target Sale Days (60)'; InitValue = 60; }
        field(3; "Min. Margin %"; Decimal) { Caption = 'Minimum Margin %'; }
        field(4; "Target Margin %"; Decimal) { Caption = 'Target Margin %'; }
        field(5; "Price Formula"; Text[250]) { Caption = 'Price Formula (configurable)'; }
        field(6; "Four Eyes Approval"; Boolean) { Caption = 'Four-eyes Price Approval'; InitValue = true; }
        field(7; "Sale to Driver Closes Contract"; Boolean) { Caption = 'Sale to Driver closes Contract'; InitValue = true; }
        field(8; "NFe Enabled"; Boolean) { Caption = 'NF-e Enabled (BR)'; }
        field(9; "Write-off Before Payment"; Boolean) { Caption = 'Asset Write-off before Payment (AR)'; }
        field(10; "Sales Product Code"; Code[20]) { Caption = 'Sales Product Code'; }
        field(11; "Commission %"; Decimal) { Caption = 'Commission %'; }
        field(12; "Driver Discount %"; Decimal) { Caption = 'Driver Discount %'; }
    }

    keys
    {
        key(PK; "Country Code") { Clustered = true; }
    }

    procedure GetSetup(CountryCode: Code[10])
    begin
        if not Get(CountryCode) then begin
            Init();
            "Country Code" := CountryCode;
            "Target Sale Days" := 60;
            "Four Eyes Approval" := true;
            "Sale to Driver Closes Contract" := true;
            Insert(false);
        end;
    end;
}
