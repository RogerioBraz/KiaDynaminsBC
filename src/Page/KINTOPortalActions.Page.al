page 50483 "KINTO Portal Actions"
{
    Caption = 'Portal Actions (Seminovos)';
    PageType = Card;
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Info)
            {
                Caption = '3 Touchpoints (D8 BR)';
                field(TP1Text; TP1Text) { ApplicationArea = All; ShowCaption = false; Editable = false; }
                field(TP2Text; TP2Text) { ApplicationArea = All; ShowCaption = false; Editable = false; }
                field(TP3Text; TP3Text) { ApplicationArea = All; ShowCaption = false; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendAll)
            {
                Caption = 'TP1: Send All Available Vehicles';
                ApplicationArea = All;
                Image = Export;
                trigger OnAction()
                var
                    PortalIntegration: Codeunit "KINTO Portal Integration";
                    Sent: Integer;
                begin
                    Sent := PortalIntegration.SendAllAvailable();
                    Message(StrSubstNo('%1 vehicle(s) queued for availability.', Sent));
                end;
            }
            action(ProcessPending)
            {
                Caption = 'Process Pending Entries';
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                var
                    PortalIntegration: Codeunit "KINTO Portal Integration";
                    Processed: Integer;
                begin
                    Processed := PortalIntegration.ProcessPendingEntries();
                    Message(StrSubstNo('%1 entry(ies) processed.', Processed));
                end;
            }
        }
    }

    var
        TP1Text: Text;
        TP2Text: Text;
        TP3Text: Text;

    trigger OnOpenPage()
    begin
        TP1Text := 'TP1 — Envio de disponíveis com preço (CalculatePrice → JSON)';
        TP2Text := 'TP2 — Lançamento da venda + boleto (Sale Invoiced → JSON)';
        TP3Text := 'TP3 — Baixa após pagamento (Sale Paid → JSON)';
    end;
}
