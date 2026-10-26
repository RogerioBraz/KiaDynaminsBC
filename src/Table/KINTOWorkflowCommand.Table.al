table 50410 "KINTO Workflow Command"
{
    Caption = 'KINTO Workflow Command';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Pricing Workflow API";
    DrillDownPageId = "KINTO Pricing Workflow API";

    // Padrão command/request p/ integração REST: a API page opera sobre ESTA tabela,
    // nunca sobre o Quote Header — o modify implícito da platform após o OnValidate
    // grava só o comando, e o trigger de invalidação do Quote Header não dispara.

    fields
    {
        field(1; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            TableRelation = "KINTO Quote Header";
        }
        field(2; "Run Pricing Trigger"; Boolean)
        {
            Caption = 'Run Pricing Trigger (integration)';

            trigger OnValidate()
            var
                Quote: Record "KINTO Quote Header";
                Engine: Codeunit "KINTO Pricing Engine Mgt.";
            begin
                if not "Run Pricing Trigger" then
                    exit;
                Quote.Get("Quote No.");
                Engine.RunPricing(Quote);
                Quote.Get("Quote No."); // re-lê o resultado gravado pelo engine
                "Pricing Status" := Quote."Pricing Status";
                "Approval Classification" := Quote."Approval Classification";
                "Calculated Monthly Fee" := Quote."Calculated Monthly Fee";
                "KINTO IRR" := Quote."KINTO IRR";
                "Calculated ROI" := Quote."Calculated ROI";
                EBT := Quote.EBT;
                "Result Message" := CopyStr(Quote."Error Message", 1, MaxStrLen("Result Message"));
                "Last Run DateTime" := CurrentDateTime;
                "Run Pricing Trigger" := false;
            end;
        }
        field(3; "Approve Quote Trigger"; Boolean)
        {
            Caption = 'Approve Quote Trigger (integration)';

            trigger OnValidate()
            var
                Quote: Record "KINTO Quote Header";
            begin
                if not "Approve Quote Trigger" then
                    exit;
                Quote.Get("Quote No.");
                Quote."Pricing Status" := Quote."Pricing Status"::Approved;
                Quote.Modify(true);
                "Pricing Status" := Quote."Pricing Status";
                "Result Message" := CopyStr('Quote approved', 1, MaxStrLen("Result Message"));
                "Last Run DateTime" := CurrentDateTime;
                "Approve Quote Trigger" := false;
            end;
        }
        field(4; "Create Contract Trigger"; Boolean)
        {
            Caption = 'Create Contract Trigger (integration)';

            trigger OnValidate()
            var
                Quote: Record "KINTO Quote Header";
                BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
            begin
                if not "Create Contract Trigger" then
                    exit;
                Quote.Get("Quote No.");
                "Created Contract No." := BillingMgt.CreateContractFromQuote(Quote);
                "Result Message" := CopyStr('Contract ' + "Created Contract No." + ' created', 1, MaxStrLen("Result Message"));
                "Last Run DateTime" := CurrentDateTime;
                "Create Contract Trigger" := false;
            end;
        }
        field(5; "Generate Billing Trigger"; Boolean)
        {
            Caption = 'Generate Billing Trigger (integration)';

            trigger OnValidate()
            var
                Contract: Record "KINTO Vehicle Contract";
                BillingMgt: Codeunit "KINTO Contract Billing Mgt.";
            begin
                if not "Generate Billing Trigger" then
                    exit;
                Contract.SetRange("Quote No.", "Quote No.");
                Contract.FindFirst();
                BillingMgt.GenerateBillingForContract(Contract, CalcDate('<-CM>', WorkDate()));
                "Result Message" := CopyStr('Billing generated for contract ' + Contract."Contract No.", 1, MaxStrLen("Result Message"));
                "Last Run DateTime" := CurrentDateTime;
                "Generate Billing Trigger" := false;
            end;
        }
        field(10; "Pricing Status"; Enum "KINTO Pricing Status") { Caption = 'Quote Pricing Status'; Editable = false; }
        field(11; "Approval Classification"; Enum "KINTO Approval Classification") { Caption = 'Approval Classification'; Editable = false; }
        field(12; "Calculated Monthly Fee"; Decimal) { Caption = 'Calculated Monthly Fee'; Editable = false; DecimalPlaces = 2 : 2; }
        field(13; "KINTO IRR"; Decimal) { Caption = 'KINTO IRR'; Editable = false; DecimalPlaces = 0 : 10; }
        field(14; "Calculated ROI"; Decimal) { Caption = 'Calculated ROI'; Editable = false; DecimalPlaces = 0 : 10; }
        field(15; EBT; Decimal) { Caption = 'EBT'; Editable = false; DecimalPlaces = 2 : 2; }
        field(16; "Created Contract No."; Code[20]) { Caption = 'Created Contract No.'; Editable = false; }
        field(17; "Result Message"; Text[250]) { Caption = 'Result Message'; Editable = false; }
        field(18; "Last Run DateTime"; DateTime) { Caption = 'Last Run DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Quote No.") { Clustered = true; }
    }

    trigger OnInsert()
    var
        Quote: Record "KINTO Quote Header";
    begin
        if not Quote.Get("Quote No.") then
            Error(QuoteNotFoundErr, "Quote No.");
    end;

    var
        QuoteNotFoundErr: Label 'Quote %1 does not exist.';
}