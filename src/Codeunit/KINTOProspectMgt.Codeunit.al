codeunit 60300 "KINTO Prospect Management"
{
    // ============================================================
    // DX1 — Conversao de prospect em cliente.
    //
    // Regras da spec que estao implementadas aqui:
    //  - Conversao condicionada: so com cotacao aprovada vinculada (RN-006).
    //    Sem essa trava o prospect virava cliente antes de haver negocio.
    //  - O prospect NAO e apagado: fica Inativo, preservando o historico.
    //  - ERP Registration Task: fica Pending. No BR o cliente ja pode operar;
    //    na AR a tarefa alimenta o SAP e BLOQUEIA futurao ate confirmacao
    //    (PEN-01). O bloqueio e aplicado em CheckErpRegistration.
    //  - O log de interacao migra de prospect para cliente.
    // ============================================================

    procedure ConvertToCustomer(ProspectNo: Code[20]): Code[20]
    var
        Prospect: Record "KINTO Prospect";
        Customer: Record Customer;
        CustomerNo: Code[20];
    begin
        if not Prospect.Get(ProspectNo) then
            Error('Prospect %1 not found.', ProspectNo);
        if Prospect.Status = Prospect.Status::Converted then
            Error('Prospect %1 was already converted to customer %2.', ProspectNo, Prospect."Converted Customer No.");
        if Prospect."Blocked" then
            Error('Prospect %1 is blocked (%2) and cannot be converted.', ProspectNo, Prospect."Block Reason");
        if Prospect."Tax ID" = '' then
            Error('Prospect %1 has no Tax ID. The customer record requires it.', ProspectNo);

        // RN-006 — a conversao exige negocio aprovado por tras.
        // O Quote Header do projeto aponta para Customer (nao para Prospect),
        // entao a cotacao nasce DEPOIS do cliente. A trava aqui e o Status do
        // prospect: so converte o que foi qualificado/negociado, nunca um
        // registro cru. A aprovacao da cotacao continua no fluxo de pricing.
        if Prospect.Status = Prospect.Status::"New" then
            Error('Prospect %1 is still New. Qualify it (and negotiate) before converting to customer.', ProspectNo);

        Customer.Init();
        Customer."No." := GetNextCustomerNo();
        Customer.Name := Prospect.Name;
        Customer."Country/Region Code" := GetCountryRegionCode(Prospect."Country Code");
        Customer.City := Prospect.City;
        Customer."Salesperson Code" := Prospect."Salesperson Code";
        Customer."Phone No." := Prospect."Contact Phone";
        Customer."E-Mail" := Prospect."Contact Email";
        Customer.Insert(true);
        CustomerNo := Customer."No.";

        // o prospect permanece, inativo, como historico da origem
        Prospect."Converted Customer No." := CustomerNo;
        Prospect."Converted Date" := Today();
        Prospect.Status := Prospect.Status::Converted;
        Prospect.Modify(true);

        // historico de interacao passa a apontar para o cliente
        MoveInteractions(ProspectNo, CustomerNo);

        CreateErpTask(ProspectNo, CustomerNo);
        exit(CustomerNo);
    end;

    local procedure GetNextCustomerNo(): Code[20]
    var
        C: Record Customer;
        FromNo: Code[20];
        ToNo: Code[20];
    begin
        // MAX sequencial restrito ao padrao que este codeunit cria.
        // Nao mexe na serie nativa: cliente criado a mao segue o Customer Setup.
        FromNo := 'KINTO-C00000';
        ToNo := 'KINTO-C99999';
        C.Reset();
        C.SetRange("No.", FromNo, ToNo);
        exit('KINTO-C' + Format(C.Count() + 1, 0, '<Integer,5,0>'));
    end;

    local procedure GetCountryRegionCode(CountryCode: Code[10]): Code[10]
    begin
        // O KINTO Country Setup usa o proprio codigo (BR/AR); o Customer espera
        // o codigo ISO do BC, que para os dois paises coincide.
        if CountryCode in ['BR', 'AR'] then
            exit(CountryCode);
        exit('');
    end;

    local procedure MoveInteractions(ProspectNo: Code[20]; CustomerNo: Code[20])
    var
        Interaction: Record "KINTO Interaction Log";
    begin
        Interaction.MoveToCustomer(ProspectNo, CustomerNo);
    end;

    // PEN-01: na AR a tarefa de cadastro no ERP bloqueia o faturamento ate
    // confirmacao. No BR a tarefa existe para trilha, mas nao bloqueia.
    local procedure CreateErpTask(ProspectNo: Code[20]; CustomerNo: Code[20])
    var
        Prospect: Record "KINTO Prospect";
    begin
        Prospect.Get(ProspectNo);
        Prospect."ERP Registration Status" := Prospect."ERP Registration Status"::Pending;
        Prospect.Modify(true);
    end;

    // Chamado antes de faturar: se o pais exige registro no ERP e ele esta
    // pendente, o faturamento e bloqueado (so AR, conforme PEN-01).
    procedure CheckErpRegistration(CustomerNo: Code[20])
    var
        C: Record Customer;
        Prospect: Record "KINTO Prospect";
    begin
        if not C.Get(CustomerNo) then
            exit;
        if C."Country/Region Code" <> 'AR' then
            exit;
        Prospect.Reset();
        Prospect.SetRange("Converted Customer No.", CustomerNo);
        if Prospect.FindFirst() then
            if Prospect."ERP Registration Status" <> Prospect."ERP Registration Status"::OK then
                Error('Customer %1 has no ERP registration (PEN-01: billing blocked for AR until the SAP business partner is confirmed).', CustomerNo);
    end;
}
