codeunit 50111 "KINTO Event Subscribers"
{
    SingleInstance = true;

    // ================================================================
    // EVENT SUBSCRIBERS DE CAMPO (OnAfterValidateEvent) — funcionam
    // ================================================================

    // Auto-popular Quote Item a partir do Item selecionado
    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Item", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure OnAfterValidateItemNo(var Rec: Record "KINTO Quote Item"; var xRec: Record "KINTO Quote Item")
    var
        Item: Record Item;
        VehicleModel: Record "KINTO Vehicle Model";
    begin
        if Rec."Item No." = '' then exit;
        if not Item.Get(Rec."Item No.") then exit;

        Rec.Description := Item.Description;
        Rec."Vehicle Model No." := Item."Vehicle Model No.";
        Rec."Vehicle Condition" := Item."Vehicle Condition";

        // MSRP: usa MSRP Metallic Paint se preenchido, senão usa Unit Price
        if Item."MSRP Metallic Paint" > 0 then
            Rec.MSRP := Item."MSRP Metallic Paint";

        // CORREÇÃO: "Comm. Depreciation %" existe no Item, não no Quote Item.
        // Mapeia para "Depreciation Market %" no Quote Item.
        if Item."Comm. Depreciation %" > 0 then
            Rec."Depreciation Market %" := Item."Comm. Depreciation %";

        // Carregar defaults do Vehicle Model
        if Rec."Vehicle Model No." <> '' then
            if VehicleModel.Get(Rec."Vehicle Model No.") then begin
                if Rec."Usage Type" = Rec."Usage Type"::Normal then
                    Rec."Usage Type" := VehicleModel."Default Usage Type";
                if Rec."Monthly Mileage (km)" = 0 then
                    Rec."Monthly Mileage (km)" := VehicleModel."Default Monthly Mileage";
                if Rec."Contract Term (Months)" = 0 then
                    Rec."Contract Term (Months)" := VehicleModel."Default Contract Term";
            end;
    end;

    // Auto-popular a partir do Vehicle Model
    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Item", 'OnAfterValidateEvent', 'Vehicle Model No.', false, false)]
    local procedure OnAfterValidateVehicleModel(var Rec: Record "KINTO Quote Item"; var xRec: Record "KINTO Quote Item")
    var
        VehicleModel: Record "KINTO Vehicle Model";
    begin
        if Rec."Vehicle Model No." = '' then exit;
        if not VehicleModel.Get(Rec."Vehicle Model No.") then exit;

        if Rec."Usage Type" = Rec."Usage Type"::Normal then
            Rec."Usage Type" := VehicleModel."Default Usage Type";
        if Rec."Monthly Mileage (km)" = 0 then
            Rec."Monthly Mileage (km)" := VehicleModel."Default Monthly Mileage";
        if Rec."Contract Term (Months)" = 0 then
            Rec."Contract Term (Months)" := VehicleModel."Default Contract Term";
    end;

    // Auto-popular a partir do Inventory Vehicle (plate-by-plate para usados)
    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Item", 'OnAfterValidateEvent', 'Inventory Vehicle No.', false, false)]
    local procedure OnAfterValidateInventoryVehicle(var Rec: Record "KINTO Quote Item"; var xRec: Record "KINTO Quote Item")
    var
        InventoryVehicle: Record "KINTO Inventory Vehicle";
    begin
        if Rec."Inventory Vehicle No." = '' then exit;
        if not InventoryVehicle.Get(Rec."Inventory Vehicle No.") then exit;

        Rec."Vehicle Condition" := InventoryVehicle."Vehicle Condition";
        Rec."Item No." := InventoryVehicle."Item No.";
        Rec."Vehicle Model No." := InventoryVehicle."Vehicle Model No.";

        if InventoryVehicle."Vehicle Condition" = InventoryVehicle."Vehicle Condition"::Used then begin
            Rec."Initial Value (Used)" := InventoryVehicle."Frozen Booking Value";
            Rec."Frozen Booking Value" := InventoryVehicle."Frozen Booking Value";
        end;
    end;

    // Auto-popular Credit Score a partir do Customer
    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure OnAfterValidateCustomer(var Rec: Record "KINTO Quote Header"; var xRec: Record "KINTO Quote Header")
    var
        Customer: Record Customer;
    begin
        if Rec."Customer No." = '' then exit;
        if not Customer.Get(Rec."Customer No.") then exit;

        if Customer."KINTO Credit Score" <> '' then
            Rec."Credit Score" := Customer."KINTO Credit Score";
        if Customer."KINTO Credit Risk Override %" <> 0 then
            Rec."Credit Risk Factor %" := Customer."KINTO Credit Risk Override %";
    end;

    // Auto-popular comissões DLR a partir do Vendor (Dealer)
    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Header", 'OnAfterValidateEvent', 'Dealer No.', false, false)]
    local procedure OnAfterValidateDealer(var Rec: Record "KINTO Quote Header"; var xRec: Record "KINTO Quote Header")
    var
        Vendor: Record Vendor;
        QuoteItem: Record "KINTO Quote Item";
    begin
        if Rec."Dealer No." = '' then exit;
        if not Vendor.Get(Rec."Dealer No.") then exit;

        if Vendor."KINTO Dealer" then begin
            QuoteItem.SetRange("Quote No.", Rec."Quote No.");
            if QuoteItem.FindSet() then
                repeat
                    if Vendor."KINTO Default DLR Sales Comm %" > 0 then
                        QuoteItem."DLR Sales Commission %" := Vendor."KINTO Default DLR Sales Comm %";
                    if Vendor."KINTO Default DLR Delivery Comm %" > 0 then
                        QuoteItem."DLR Delivery Commission %" := Vendor."KINTO Default DLR Delivery Comm %";
                    QuoteItem.Modify(true);
                until QuoteItem.Next() = 0;
        end;
    end;

    // Auto-criar Odometer History quando odômetro muda
    [EventSubscriber(ObjectType::Table, Database::"KINTO Inventory Vehicle", 'OnAfterValidateEvent', 'Current Odometer', false, false)]
    local procedure OnAfterValidateOdometer(var Rec: Record "KINTO Inventory Vehicle"; var xRec: Record "KINTO Inventory Vehicle")
    var
        OdometerHistory: Record "KINTO Vehicle Odometer History";
        NextEntryNo: Integer;
    begin
        if Rec."Current Odometer" = xRec."Current Odometer" then exit;
        if Rec."Current Odometer" = 0 then exit;

        if OdometerHistory.FindLast() then
            NextEntryNo := OdometerHistory."Entry No." + 1
        else
            NextEntryNo := 1;

        OdometerHistory.Init();
        OdometerHistory."Entry No." := NextEntryNo;
        OdometerHistory."Vehicle No." := Rec."Vehicle No.";
        OdometerHistory."Reading Date" := Today;
        OdometerHistory."Odometer Reading" := Rec."Current Odometer";
        OdometerHistory.Source := 'Manual Update';
        OdometerHistory.Insert(true);
    end;

    // Auto-popular dados do veículo na Cotação de Seguro ao selecionar Item No.
    [EventSubscriber(ObjectType::Table, Database::"KINTO Insurance Quote", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure OnAfterValidateInsQuoteItemNo(
    var Rec: Record "KINTO Insurance Quote";
    var xRec: Record "KINTO Insurance Quote")
    var
        Item: Record Item;
        VehicleModel: Record "KINTO Vehicle Model";
        QuoteItem: Record "KINTO Quote Item";
    begin
        if Rec."Item No." = '' then
            exit;

        if not Item.Get(Rec."Item No.") then
            exit;

        Rec."Vehicle Name" := Item.Description;
        Rec."Vehicle Model No." := Item."Vehicle Model No.";

        if Rec."Vehicle Model No." <> '' then
            if VehicleModel.Get(Rec."Vehicle Model No.") then begin
                Rec."FIPE Code" := VehicleModel."FIPE Code";
                Rec."Manufacturer Code" := VehicleModel."Manufacturer Code";
                Rec."Manufacturer Name" := VehicleModel."Manufacturer Name";
                Rec."Manufacturer Part Code" := VehicleModel."Manufacturer Part Code";
            end;

        if (Rec."KINTO Quote No." <> '') and
           (Rec."KINTO Quote Line No." <> 0) then begin

            if QuoteItem.Get(
                Rec."KINTO Quote No.",
                Rec."KINTO Quote Line No.") then
                Rec.Armoring := QuoteItem."Inclusion of Armoring";
        end;
    end;

    // Auto-calcular Valor do Seguro ao mudar Insurance %
    [EventSubscriber(ObjectType::Table, Database::"KINTO Insurance Quote", 'OnAfterValidateEvent', 'Insurance %', false, false)]
    local procedure OnAfterValidateInsurancePct(var Rec: Record "KINTO Insurance Quote"; var xRec: Record "KINTO Insurance Quote")
    begin
        if Rec."Hull Value" > 0 then
            Rec."Insurance Value" := Rec.CalculateInsuranceValue();
    end;

    // Auto-calcular Valor do Seguro ao mudar Hull Value
    [EventSubscriber(ObjectType::Table, Database::"KINTO Insurance Quote", 'OnAfterValidateEvent', 'Hull Value', false, false)]
    local procedure OnAfterValidateHullValue(var Rec: Record "KINTO Insurance Quote"; var xRec: Record "KINTO Insurance Quote")
    begin
        if Rec."Insurance %" > 0 then
            Rec."Insurance Value" := Rec.CalculateInsuranceValue();
    end;
}