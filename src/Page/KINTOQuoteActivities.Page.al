page 50142 "KINTO Quote Activities"
{
    Caption = 'Cotações';
    PageType = CardPart;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            cuegroup(Quotes)
            {
                Caption = 'Cotações';
                actions
                {
                    action(TotalQuotes)
                    {
                        Caption = 'Total de Cotações';
                        ApplicationArea = All;
                        trigger OnAction()
                        begin
                            Page.Run(Page::"KINTO Quote List");
                        end;
                    }

                    action(DraftQuotes)
                    {
                        Caption = 'Cotações em Rascunho';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            QuoteHeader: Record "KINTO Quote Header";
                        begin
                            QuoteHeader.SetRange("Pricing Status", QuoteHeader."Pricing Status"::Draft);
                            Page.Run(Page::"KINTO Quote List", QuoteHeader);
                        end;
                    }
                    action(CalculatedQuotes)
                    {
                        Caption = 'Cotações Calculadas';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            QuoteHeader: Record "KINTO Quote Header";
                        begin
                            QuoteHeader.SetRange("Pricing Status", QuoteHeader."Pricing Status"::Calculated);
                            Page.Run(Page::"KINTO Quote List", QuoteHeader);
                        end;
                    }
                    action(ApprovedQuotes)
                    {
                        Caption = 'Cotações Aprovadas';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            QuoteHeader: Record "KINTO Quote Header";
                        begin
                            QuoteHeader.SetRange("Pricing Status", QuoteHeader."Pricing Status"::Approved);
                            Page.Run(Page::"KINTO Quote List", QuoteHeader);
                        end;
                    }
                }
            }
            cuegroup(NonStandard)
            {
                Caption = 'Requerem Atenção';
                actions
                {
                    action(NonStandardQuotes)
                    {
                        Caption = 'Non-Standard';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            QuoteHeader: Record "KINTO Quote Header";
                        begin
                            QuoteHeader.SetRange("Approval Classification", QuoteHeader."Approval Classification"::"Non-Standard");
                            Page.Run(Page::"KINTO Quote List", QuoteHeader);
                        end;
                    }
                    action(ErrorQuotes)
                    {
                        Caption = 'Cotações com Erro';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            QuoteHeader: Record "KINTO Quote Header";
                        begin
                            QuoteHeader.SetRange("Pricing Status", QuoteHeader."Pricing Status"::Error);
                            Page.Run(Page::"KINTO Quote List", QuoteHeader);
                        end;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // No code needed — cues are calculated automatically
    end;

    var
        TotalQuotes: Integer;
        DraftQuotes: Integer;
        CalculatedQuotes: Integer;
        ApprovedQuotes: Integer;
        NonStandardQuotes: Integer;
        ErrorQuotes: Integer;
}