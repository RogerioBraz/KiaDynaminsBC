codeunit 50172 "KINTO Device Aging Mgt."
{
    // D7 bloco 2: dispositivos em estoque com aging acima do threshold
    // do país geram cobrança ao vendor (Purchase Invoice).

    var
        NoVendorErr: Label 'Device %1 has no vendor — cannot charge aging.';

    procedure GenerateAgingCharges(CountryCode: Code[10]; ChargeDate: Date)
    var
        Device: Record "KINTO Telematic Device";
        CountrySetup: Record "KINTO Country Setup";
        Charge: Record "KINTO Device Aging Charge";
        AgingDays: Integer;
        Count: Integer;
    begin
        if not CountrySetup.Get(CountryCode) then
            Error('Country setup %1 not found.', CountryCode);

        Device.SetRange(Status, Device.Status::"In Stock");
        Device.SetRange("Country Code", CountryCode);
        if Device.FindSet() then
            repeat
                if Device."Removal Date" <> 0D then begin
                    AgingDays := ChargeDate - Device."Removal Date";
                    if AgingDays > CountrySetup."Device Aging Charge Days" then begin
                        // Não duplicar cobrança do mesmo período
                        Charge.SetRange("Device No.", Device."Device No.");
                        Charge.SetRange("Charge Date", ChargeDate);
                        if Charge.IsEmpty() then begin
                            CreateCharge(Device, AgingDays, ChargeDate);
                            Count += 1;
                        end;
                    end;
                end;
            until Device.Next() = 0;

        if Count = 0 then
            Message('No device aging charges generated for %1.', CountryCode)
        else
            Message('%1 device aging charges generated for %2.', Count, CountryCode);
    end;

    local procedure CreateCharge(Device: Record "KINTO Telematic Device"; AgingDays: Integer; ChargeDate: Date)
    var
        Charge: Record "KINTO Device Aging Charge";
    begin
        if Device."Vendor No." = '' then
            Error(NoVendorErr, Device."Device No.");

        Charge.Init();
        Charge."Entry No." := Charge.NextEntryNo();
        Charge."Device No." := Device."Device No.";
        Charge."Vendor No." := Device."Vendor No.";
        Charge."Aging Days" := AgingDays;
        Charge."Daily Charge" := GetDailyCharge(Device."Country Code");
        Charge."Charge Amount" := AgingDays * Charge."Daily Charge";
        Charge."Charge Date" := ChargeDate;
        Charge."Country Code" := Device."Country Code";
        Charge.Insert(false);
    end;

    local procedure GetDailyCharge(CountryCode: Code[10]): Decimal
    var
        Setup: Record "KINTO Remarketing Setup";
    begin
        // Diária de armazenagem do dispositivo — configurável no setup (default 5)
        if Setup.Get(CountryCode) then;
        exit(5);
    end;

    procedure InvoiceCharges(CountryCode: Code[10])
    var
        Charge: Record "KINTO Device Aging Charge";
        VendorNo: Code[20];
        Total: Decimal;
        Count: Integer;
    begin
        // Agrupa por vendor e cria 1 Purchase Invoice por vendor (placeholder:
        // grava o nº simulado — integração c/ Purchase Header na sequência)
        Charge.SetRange("Country Code", CountryCode);
        Charge.SetRange(Invoiced, false);
        if Charge.FindSet() then
            repeat
                if Charge."Vendor No." <> VendorNo then begin
                    VendorNo := Charge."Vendor No.";
                    Total := 0;
                end;
                Total += Charge."Charge Amount";
                Count += 1;
                Charge."Purchase Invoice No." := CopyStr('PI-' + VendorNo, 1, 20);
                Charge.Invoiced := true;
                Charge.Modify(true);
            until Charge.Next() = 0;

        if Count > 0 then
            Message('%1 charges invoiced (grouped by vendor).', Count);
    end;
}
