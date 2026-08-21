codeunit 50111 "KINTO Event Subscribers"
{
    SingleInstance = true;

    // ================================================================
    // QUOTE ITEM — AUTO-POPULAR A PARTIR DO ITEM SELECIONADO
    // ================================================================

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

        if Item."MSRP Metallic Paint" > 0 then
            Rec.MSRP := Item."MSRP Metallic Paint";

        if Item."Comm. Depreciation %" > 0 then
            Rec."Depreciation Market %" := Item."Comm. Depreciation %";

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

    // ================================================================
    // QUOTE ITEM — AUTO-POPULAR A PARTIR DO VEHICLE MODEL
    // ================================================================

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

    // ================================================================
    // QUOTE ITEM — AUTO-POPULAR A PARTIR DO INVENTORY VEHICLE (usados)
    // ================================================================

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

    // ================================================================
    // QUOTE HEADER — AUTO-POPULAR CREDIT SCORE A PARTIR DO CUSTOMER
    // ================================================================

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

    // ================================================================
    // QUOTE HEADER — PROPAGAR COMISSÕES DLR A PARTIR DO DEALER (VENDOR)
    // ================================================================

    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Header", 'OnAfterValidateEvent', 'Dealer No.', false, false)]
    local procedure OnAfterValidateDealer(var Rec: Record "KINTO Quote Header"; var xRec: Record "KINTO Quote Header")
    var
        Vendor: Record Vendor;
        VendorCatAssign: Record "KINTO Vendor Category Assign";
        QuoteItem: Record "KINTO Quote Item";
        IsDealer: Boolean;
    begin
        if Rec."Dealer No." = '' then exit;
        if not Vendor.Get(Rec."Dealer No.") then exit;

        IsDealer := VendorCatAssign.Get(Rec."Dealer No.", 'DEALER');

        if IsDealer then begin
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

    // ================================================================
    // INVENTORY VEHICLE — CRIAR ODOMETER HISTORY QUANDO ODÔMETRO MUDA
    // ================================================================

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

    // ================================================================
    // INSURANCE QUOTE — AUTO-POPULAR DADOS DO VEÍCULO
    // CORREÇÃO: Removido Item."Inclusion of Armoring" — esse campo
    // existe no Quote Item (field 100), não na tabela Item.
    // O Armoring da Insurance Quote deve ser setado manualmente
    // ou validado no OnValidate do campo Armoring da própria tabela.
    // ================================================================

    [EventSubscriber(ObjectType::Table, Database::"KINTO Insurance Quote", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure OnAfterValidateInsQuoteItemNo(var Rec: Record "KINTO Insurance Quote"; var xRec: Record "KINTO Insurance Quote")
    var
        Item: Record Item;
        VehicleModel: Record "KINTO Vehicle Model";
    begin
        if Rec."Item No." = '' then exit;
        if not Item.Get(Rec."Item No.") then exit;

        Rec."Vehicle Name" := Item.Description;
        Rec."Vehicle Model No." := Item."Vehicle Model No.";

        if Rec."Vehicle Model No." <> '' then begin
            if VehicleModel.Get(Rec."Vehicle Model No.") then begin
                Rec."FIPE Code" := VehicleModel."FIPE Code";
                Rec."Manufacturer Code" := VehicleModel."Manufacturer Code";
                Rec."Manufacturer Name" := VehicleModel."Manufacturer Name";
                Rec."Manufacturer Part Code" := VehicleModel."Manufacturer Part Code";
            end;
        end;

        // CORREÇÃO: Removido Rec.Armoring := Item."Inclusion of Armoring"
        // O campo "Inclusion of Armoring" existe no Quote Item (field 100),
        // não na tabela Item. O Armoring da Insurance Quote é preenchido
        // manualmente pelo usuário ou herdado do Quote Group vinculado.
    end;

    // ================================================================
    // INSURANCE QUOTE — AUTO-CALCULAR VALOR DO SEGURO
    // ================================================================

    [EventSubscriber(ObjectType::Table, Database::"KINTO Insurance Quote", 'OnAfterValidateEvent', 'Insurance %', false, false)]
    local procedure OnAfterValidateInsurancePct(var Rec: Record "KINTO Insurance Quote"; var xRec: Record "KINTO Insurance Quote")
    begin
        if Rec."Hull Value" > 0 then
            Rec."Insurance Value" := Rec.CalculateInsuranceValue();
    end;

    [EventSubscriber(ObjectType::Table, Database::"KINTO Insurance Quote", 'OnAfterValidateEvent', 'Hull Value', false, false)]
    local procedure OnAfterValidateHullValue(var Rec: Record "KINTO Insurance Quote"; var xRec: Record "KINTO Insurance Quote")
    begin
        if Rec."Insurance %" > 0 then
            Rec."Insurance Value" := Rec.CalculateInsuranceValue();
    end;

    // ================================================================
    // QUOTE ITEM — AUTO-POPULAR TIRE QUANTITY
    // ================================================================

    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Item", 'OnAfterValidateEvent', 'Tire Package ID', false, false)]
    local procedure OnAfterValidateTirePackage(var Rec: Record "KINTO Quote Item"; var xRec: Record "KINTO Quote Item")
    var
        TirePkg: Record "KINTO Tire Package";
    begin
        if Rec."Tire Package ID" = '' then exit;
        if not TirePkg.Get(Rec."Tire Package ID") then exit;
        if Rec."Tire Quantity" = 0 then
            Rec."Tire Quantity" := TirePkg."Default Quantity";
        if Rec."Number of Tires" = 0 then
            Rec."Number of Tires" := TirePkg."Default Quantity";
    end;

    // ================================================================
    // QUOTE ITEM — AUTO-POPULAR REPLACEMENT VEHICLE USES
    // ================================================================

    [EventSubscriber(ObjectType::Table, Database::"KINTO Quote Item", 'OnAfterValidateEvent', 'Replacement Vehicle Pkg ID', false, false)]
    local procedure OnAfterValidateReplVehiclePkg(var Rec: Record "KINTO Quote Item"; var xRec: Record "KINTO Quote Item")
    var
        ReplPkg: Record "KINTO Replacement Vehicle Pkg";
    begin
        if Rec."Replacement Vehicle Pkg ID" = '' then exit;
        if not ReplPkg.Get(Rec."Replacement Vehicle Pkg ID") then exit;
        if Rec."Replacement Vehicle Uses" = 0 then
            Rec."Replacement Vehicle Uses" := ReplPkg."Default Uses";
    end;

    // ================================================================
    // VENDOR — VALIDAR CATEGORIA DEALER AO CONFIGURAR COMISSÃO VD
    // ================================================================

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'KINTO VD Sales Commission %', false, false)]
    local procedure OnAfterValidateVDComm(var Rec: Record Vendor; var xRec: Record Vendor)
    var
        VendorCatAssign: Record "KINTO Vendor Category Assign";
        VendorCat: Record "KINTO Vendor Category";
    begin
        if Rec."KINTO VD Sales Commission %" > 0 then begin
            VendorCat.SetRange("Category Type", VendorCat."Category Type"::Dealer);
            if VendorCat.FindFirst() then begin
                VendorCatAssign.SetRange("Vendor No.", Rec."No.");
                VendorCatAssign.SetRange("Category Code", VendorCat."Category Code");
                if not VendorCatAssign.FindFirst() then begin
                    VendorCatAssign.Init();
                    VendorCatAssign."Vendor No." := Rec."No.";
                    VendorCatAssign."Category Code" := VendorCat."Category Code";
                    VendorCatAssign."Is Primary" := true;
                    VendorCatAssign.Insert(true);
                end;
            end;
        end;
    end;

    // ================================================================
    // ITEM — CRIAR VERSION HISTORY QUANDO KINTO CATEGORY É DEFINIDA
    // CORREÇÃO: Enum não tem valor blank " ". Em AL, o valor default
    // de um Enum é o primeiro value (0 = "Vehicle Base").
    // A verificação correta é: se o valor mudou (xRec <> Rec) E
    // ainda não existe nenhum registro de Version History para este Item.
    // ================================================================

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyItem(var Rec: Record Item; var xRec: Record Item)
    var
        VersionHist: Record "KINTO Item Version History";
    begin
        // Só executa se a KINTO Category mudou de valor
        if xRec."KINTO Category" <> Rec."KINTO Category" then begin

            // Verifica se já existe um histórico para este Item
            VersionHist.SetRange("Item No.", Rec."No.");
            if not VersionHist.IsEmpty then exit;

            // Cria o primeiro registro de versão
            VersionHist.Init();
            VersionHist."Item No." := Rec."No.";
            VersionHist."Version No." := 1;
            VersionHist."Active Start Date" := Today;
            VersionHist.Cost := Rec."Unit Cost";
            VersionHist."Markup %" := 0;
            VersionHist.Insert(true);
        end;
    end;
}