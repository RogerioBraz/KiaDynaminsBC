page 50142 "KINTO Quote Activities"
{
    Caption = 'Cotações';
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "KINTO Pricing Cue";
    SourceTableView = sorting("Primary Key");

    layout
    {
        area(Content)
        {
            cuegroup(Quotes)
            {
                Caption = 'Cotações';
                actions
                {
                    action("Total Quotes")
                    {
                        Caption = 'Total de Cotações';
                        ApplicationArea = All;
                        Image = TileViolet;
                        RunObject = page "KINTO Quote List";
                    }
                    action("Draft Quotes")
                    {
                        Caption = 'Rascunho';
                        ApplicationArea = All;
                        Image = TileNew;
                        RunObject = page "KINTO Quote List";

                    }
                    action("Calculated Quotes")
                    {
                        Caption = 'Calculadas';
                        ApplicationArea = All;
                        Image = TileSettings;
                        RunObject = page "KINTO Quote List";
                    }
                    action("Approved Quotes")
                    {
                        Caption = 'Aprovadas';
                        ApplicationArea = All;
                        Image = TileHelp;
                        RunObject = page "KINTO Quote List";
                    }
                }
            }
            cuegroup(Attention)
            {
                Caption = 'Requerem Atenção';
                actions
                {
                    action("Non-Standard Quotes")
                    {
                        Caption = 'Non-Standard';
                        ApplicationArea = All;
                        RunObject = page "KINTO Quote List";
                    }
                    action("Error Quotes")
                    {
                        Caption = 'Com Erro';
                        ApplicationArea = All;
                        RunObject = page "KINTO Quote List";
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSingleInstance();
        Rec.UpdateCues();
    end;
}