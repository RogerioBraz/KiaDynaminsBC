table 60000 "KINTO Vendor Labor Rate"
{
    Caption = 'KINTO Vendor Labor Rate';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Vendor Labor Rate List";
    DrillDownPageId = "KINTO Vendor Labor Rate List";

    // D1 — taxa hora-homem (HH) por fornecedor e tipo de servico.
    // Consumida no ticket: linha de mao de obra herda a taxa vigente na data do servico.

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = "Vendor"."No.";
            NotBlank = true;
        }
        field(2; "Service Type"; Enum "KINTO Maint Service Type")
        {
            Caption = 'Service Type';
            NotBlank = true;
        }
        field(3; "Valid From"; Date) { Caption = 'Valid From'; NotBlank = true; }
        field(4; "HH Rate"; Decimal)
        {
            Caption = 'HH Rate (hourly labor rate)';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
        }
        field(5; "Minimum Hours"; Decimal)
        {
            Caption = 'Minimum Billable Hours';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(6; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency; }
        field(7; Active; Boolean) { Caption = 'Active'; InitValue = true; }
        field(8; Description; Text[100]) { Caption = 'Description'; }
        field(9; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
        }
    }

    keys
    {
        key(PK; "Vendor No.", "Service Type", "Valid From") { Clustered = true; }
        key(Idx1; "Valid From") { }
    }

    // Carrega a taxa VIGENTE do fornecedor para o tipo de servico na data
    // informada. A PK e (Fornecedor, Tipo de Servico, Valido a Partir), entao
    // FindLast() apos os SetRange devolve a vigencia MAIS RECENTE que ainda
    // valia na data do servico — e nao a mais antiga.
    procedure FindRate(VendorNo: Code[20]; ServiceType: Enum "KINTO Maint Service Type"; ServiceDate: Date): Boolean
    begin
        SetRange("Vendor No.", VendorNo);
        SetRange("Service Type", ServiceType);
        SetRange(Active, true);
        SetFilter("Valid From", '<=%1', ServiceDate);
        exit(FindLast());
    end;

    procedure GetRate(VendorNo: Code[20]; ServiceType: Enum "KINTO Maint Service Type"; ServiceDate: Date): Decimal
    begin
        SetRange("Vendor No.", VendorNo);
        SetRange("Service Type", ServiceType);
        SetRange(Active, true);
        SetFilter("Valid From", '<=%1', ServiceDate);
        if FindLast() then
            exit("HH Rate");
        exit(0);
    end;

    procedure GetMinimumHours(VendorNo: Code[20]; ServiceType: Enum "KINTO Maint Service Type"; ServiceDate: Date): Decimal
    begin
        SetRange("Vendor No.", VendorNo);
        SetRange("Service Type", ServiceType);
        SetRange(Active, true);
        SetFilter("Valid From", '<=%1', ServiceDate);
        if FindLast() then
            exit("Minimum Hours");
        exit(0);
    end;
}
