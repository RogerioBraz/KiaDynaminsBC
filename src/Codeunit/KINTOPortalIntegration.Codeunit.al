codeunit 50213 "KINTO Portal Integration"
{
    // D8 BR: os 3 touchpoints com o portal de seminovos (fora do NFMS).
    // TP1: envio de disponíveis com preço. TP2: lançamento da venda+boleto.
    // TP3: baixa após pagamento. Cada evento grava Portal Sync Entry com
    // payload JSON — o middleware do portal consome (pull) ou recebe (push).

    var
        NotRemarketingErr: Label 'Vehicle %1 is not in Remarketing status.';
        NoPriceErr: Label 'Vehicle %1 has no calculated price. Run CalculatePrice first.';
        NotPaidErr: Label 'Sale %1 is not Paid.';
        NotInvoicedErr: Label 'Sale %1 is not Invoiced.';
        DisabledErr: Label 'Portal integration is disabled in KINTO Portal Config.';

    // ============================================================
    // TOUCHPOINT 1 — ENVIO DE DISPONÍVEIS COM PREÇO
    // ============================================================
    procedure SendAvailability(VehicleNo: Code[20]): Code[20]
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Setup: Record "KINTO Remarketing Setup";
        PortalConfig: Record "KINTO Portal Config";
        RemarkMgt: Codeunit "KINTO Remarketing Mgt.";
        SyncEntry: Record "KINTO Portal Sync Entry";
        Price: Decimal;
        Payload: Text;
    begin
        PortalConfig.GetConfig();
        if not PortalConfig.Enabled then
            Error(DisabledErr);
        Vehicle.Get(VehicleNo);
        if Vehicle.Status <> Vehicle.Status::Remarketing then
            Error(NotRemarketingErr, VehicleNo);
        Setup.GetSetup(Vehicle."Country Code");

        Price := RemarkMgt.CalculatePrice(VehicleNo);
        if Price <= 0 then
            Error(NoPriceErr, VehicleNo);

        Payload := BuildAvailabilityPayload(Vehicle, Price, Setup);
        SyncEntry.Init();
        SyncEntry."Event Type" := SyncEntry."Event Type"::"Availability Sent";
        SyncEntry."Vehicle No." := VehicleNo;
        SyncEntry."License Plate" := Vehicle."License Plate";
        SyncEntry."Sync Status" := SyncEntry."Sync Status"::Pending;
        SyncEntry."Created DateTime" := CurrentDateTime;
        SyncEntry.SetPayload(Payload);
        SyncEntry.Insert(true);
        exit(Format(SyncEntry."Entry No."));
    end;

    procedure SendAllAvailable(): Integer
    var
        Vehicle: Record "KINTO Inventory Vehicle";
        Count: Integer;
    begin
        Vehicle.SetRange(Status, Vehicle.Status::Remarketing);
        if Vehicle.FindSet() then
            repeat
                if TrySendAvailability(Vehicle."Vehicle No.") then
                    Count += 1;
            until Vehicle.Next() = 0;
        exit(Count);
    end;

    [TryFunction]
    local procedure TrySendAvailability(VehicleNo: Code[20])
    begin
        SendAvailability(VehicleNo);
    end;

    // ============================================================
    // TOUCHPOINT 2 — LANÇAMENTO DA VENDA + BOLETO
    // ============================================================
    procedure PostSaleToPortal(var Sale: Record "KINTO Remarketing Sale")
    var
        PortalConfig: Record "KINTO Portal Config";
        SyncEntry: Record "KINTO Portal Sync Entry";
        Payload: Text;
    begin
        PortalConfig.GetConfig();
        if not PortalConfig.Enabled then
            Error(DisabledErr);
        if Sale.Status <> Sale.Status::Invoiced then
            Error(NotInvoicedErr, Sale."Sale No.");

        Payload := BuildSalePayload(Sale);
        SyncEntry.Init();
        SyncEntry."Event Type" := SyncEntry."Event Type"::"Sale Posted";
        SyncEntry."Vehicle No." := Sale."Vehicle No.";
        SyncEntry."Sale No." := Sale."Sale No.";
        SyncEntry."Sync Status" := SyncEntry."Sync Status"::Pending;
        SyncEntry."Created DateTime" := CurrentDateTime;
        SyncEntry.SetPayload(Payload);
        SyncEntry.Insert(true);
    end;

    // ============================================================
    // TOUCHPOINT 3 — BAIXA APÓS PAGAMENTO
    // ============================================================
    procedure WriteOffToPortal(var Sale: Record "KINTO Remarketing Sale")
    var
        PortalConfig: Record "KINTO Portal Config";
        SyncEntry: Record "KINTO Portal Sync Entry";
        Payload: Text;
    begin
        PortalConfig.GetConfig();
        if not PortalConfig.Enabled then
            Error(DisabledErr);
        if Sale.Status <> Sale.Status::Paid then
            Error(NotPaidErr, Sale."Sale No.");

        Payload := BuildWriteOffPayload(Sale);
        SyncEntry.Init();
        SyncEntry."Event Type" := SyncEntry."Event Type"::"Asset Written Off";
        SyncEntry."Vehicle No." := Sale."Vehicle No.";
        SyncEntry."Sale No." := Sale."Sale No.";
        SyncEntry."Sync Status" := SyncEntry."Sync Status"::Pending;
        SyncEntry."Created DateTime" := CurrentDateTime;
        SyncEntry.SetPayload(Payload);
        SyncEntry.Insert(true);
    end;

    // ============================================================
    // PAYLOADS JSON
    // ============================================================
    local procedure BuildAvailabilityPayload(Vehicle: Record "KINTO Inventory Vehicle"; Price: Decimal; Setup: Record "KINTO Remarketing Setup"): Text
    var
        Payload: Text;
    begin
        Payload := '{' +
            '"event":"availability",' +
            '"vehicleNo":"' + Vehicle."Vehicle No." + '",' +
            '"plate":"' + Vehicle."License Plate" + '",' +
            '"brand":"' + 'KIA' + '",' +
            '"model":"' + Vehicle."Vehicle Model No." + '",' +
            '"year":' + Format(Vehicle."Age in Months") + ',' +
            '"odometer":' + Format(Vehicle."Current Odometer", 0, 9) + ',' +
            '"condition":"' + Format(Vehicle."Vehicle Condition") + '",' +
            '"price":' + Format(Price, 0, 9) + ',' +
            '"currency":"BRL"' +
        '}';
        exit(Payload);
    end;

    local procedure BuildSalePayload(Sale: Record "KINTO Remarketing Sale"): Text
    var
        Payload: Text;
    begin
        Payload := '{' +
            '"event":"sale",' +
            '"saleNo":"' + Sale."Sale No." + '",' +
            '"vehicleNo":"' + Sale."Vehicle No." + '",' +
            '"plate":"' + GetPlate(Sale."Vehicle No.") + '",' +
            '"buyerName":"' + Sale."Buyer Name" + '",' +
            '"salePrice":' + Format(Sale."Sale Price", 0, 9) + ',' +
            '"invoiceNo":"' + Sale."Invoice No." + '",' +
            '"boletoDueDate":"' + Format(Sale."Payment Due Date", 0, 9) + '",' +
            '"currency":"BRL"' +
        '}';
        exit(Payload);
    end;

    local procedure BuildWriteOffPayload(Sale: Record "KINTO Remarketing Sale"): Text
    var
        Payload: Text;
    begin
        Payload := '{' +
            '"event":"writeoff",' +
            '"saleNo":"' + Sale."Sale No." + '",' +
            '"vehicleNo":"' + Sale."Vehicle No." + '",' +
            '"plate":"' + GetPlate(Sale."Vehicle No.") + '",' +
            '"paymentDate":"' + Format(Sale."Payment Date", 0, 9) + '"' +
        '}';
        exit(Payload);
    end;

    local procedure GetPlate(VehicleNo: Code[20]): Text
    var
        Vehicle: Record "KINTO Inventory Vehicle";
    begin
        if Vehicle.Get(VehicleNo) then
            exit(Vehicle."License Plate");
        exit('');
    end;

    // ============================================================
    // RETRY / PROCESSAMENTO (Job Queue consome as pendentes)
    // ============================================================
    procedure ProcessPendingEntries(): Integer
    var
        PortalConfig: Record "KINTO Portal Config";
        SyncEntry: Record "KINTO Portal Sync Entry";
        Processed: Integer;
    begin
        PortalConfig.GetConfig();
        if not PortalConfig.Enabled then
            exit(0);
        SyncEntry.SetRange("Sync Status", SyncEntry."Sync Status"::Pending);
        if SyncEntry.FindSet() then
            repeat
                if TryDeliver(SyncEntry, PortalConfig) then
                    Processed += 1;
            until SyncEntry.Next() = 0;
        exit(Processed);
    end;

    [TryFunction]
    local procedure TryDeliver(var SyncEntry: Record "KINTO Portal Sync Entry"; PortalConfig: Record "KINTO Portal Config")
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
        Response: HttpResponseMessage;
        Payload: Text;
        Json: JsonBuffer;
    begin
        SyncEntry.CalcFields(Payload);
        Payload := SyncEntry.GetPayload();
        HttpContent.WriteFrom(Payload);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        HttpContent.GetHeaders(ContentHeaders);

        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', 'Bearer ' + PortalConfig."API Key");
        HttpClient.DefaultRequestHeaders := HttpHeaders;

        HttpClient.Post(PortalConfig."Endpoint URL", HttpContent, Response);
        if Response.IsSuccessStatusCode() then begin
            SyncEntry."Sync Status" := SyncEntry."Sync Status"::Sent;
            SyncEntry."Sent DateTime" := CurrentDateTime;
            SyncEntry.Modify(true);
        end else begin
            SyncEntry."Retry Count" += 1;
            if SyncEntry."Retry Count" >= PortalConfig."Max Retry" then
                SyncEntry."Sync Status" := SyncEntry."Sync Status"::Error;
            Response.Content.ReadAs(Payload);
            SyncEntry."Error Message" := CopyStr(Payload, 1, 250);
            SyncEntry.Modify(true);
        end;
    end;
}
