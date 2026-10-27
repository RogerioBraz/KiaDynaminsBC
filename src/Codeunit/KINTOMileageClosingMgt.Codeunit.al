codeunit 50214 "KINTO Mileage Closing Mgt."
{
    // D5: Mileage Closing com cap FIPE — excesso de km na devolução.
    // Faixas: até 10% do contratado usa tarifa 1; acima, tarifa 2.
    // Cap: cobrança não excede o valor FIPE/booking do veículo.

    var
        NoOdometerErr: Label 'Return %1 has no Odometer at Return.';

    procedure ContractedTotalMileage(Contract: Record "KINTO Vehicle Contract"): Decimal
    begin
        // FIX 27/10: km contratado total = mensal × PRAZO do contrato (não meses decorridos).
        // O cliente contrata 12×1.500 = 18.000 km — a devolução antecipada cobra o excesso
        // sobre o total contratado (meses decorridos davam contratado menor e cobrança maior).
        if (Contract."Monthly Mileage (km)" = 0) or (Contract."Contract Term (Months)" = 0) then
            exit(0);
        exit(Contract."Monthly Mileage (km)" * Contract."Contract Term (Months)");
    end;

    procedure CalcExcessKm(Contract: Record "KINTO Vehicle Contract"; OdometerAtReturn: Decimal): Decimal
    var
        Contracted: Decimal;
    begin
        if OdometerAtReturn = 0 then
            Error(NoOdometerErr, '');
        Contracted := ContractedTotalMileage(Contract);
        if OdometerAtReturn <= Contracted then
            exit(0);
        exit(Round(OdometerAtReturn - Contracted, 1));
    end;

    procedure CalcCharge(Contract: Record "KINTO Vehicle Contract"; ExcessKm: Decimal): Decimal
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Charge: Decimal;
        CapValue: Decimal;
        Band1Km: Decimal;
    begin
        if ExcessKm <= 0 then
            exit(0);

        // Faixa 1: até 10% do contratado = tarifa 1; acima = tarifa 2
        Band1Km := ContractedTotalMileage(Contract) * (GetBand1Percent(Contract) / 100);
        if ExcessKm <= Band1Km then
            Charge := ExcessKm * Contract."Excess Km Price (up to 10%)"
        else
            Charge := (Band1Km * Contract."Excess Km Price (up to 10%)") +
                ((ExcessKm - Band1Km) * Contract."Excess Km Price (above 10%)");

        // Cap FIPE: cobrança não excede o booking value do veículo
        if Vehicle.Get(Contract."Vehicle No.") then begin
            CapValue := Vehicle."Booking Value";
            if (CapValue > 0) and (Charge > CapValue) then
                Charge := CapValue;
        end;
        exit(Round(Charge, 0.01));
    end;

    local procedure ContractMonths(Contract: Record "KINTO Vehicle Contract"): Integer
    var
        EndDate: Date;
    begin
        EndDate := Contract."Current End Date";
        if (EndDate = 0D) or (EndDate > WorkDate()) then
            EndDate := WorkDate();
        if Contract."Start Date" = 0D then
            exit(0);
        // Meses decorridos (mínimo 1)
        exit((EndDate - Contract."Start Date") div 30 + 1);
    end;

    // Limite da faixa 1 configuravel por pais (Country Setup). Default 10%.
    local procedure GetBand1Percent(Contract: Record "KINTO Vehicle Contract"): Decimal
    var
        CountrySetup: Record "KINTO Country Setup";
    begin
        if (Contract."Country Code" <> '') and CountrySetup.Get(Contract."Country Code") then
            if CountrySetup."Excess Km Band 1 %" > 0 then
                exit(CountrySetup."Excess Km Band 1 %");
        exit(10);
    end;
}
