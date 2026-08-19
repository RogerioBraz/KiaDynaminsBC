page 50143 "KINTO Approval Activities"
{
    Caption = 'Aprovações e Veículos';
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "KINTO Pricing Cue";
    SourceTableView = sorting("Primary Key");

    layout
    {
        area(Content)
        {
            cuegroup(Approvals)
            {
                Caption = 'Aprovações Pendentes';
                actions
                {
                    action("Pending Approvals")
                    {
                        Caption = 'Pendentes';
                        ApplicationArea = All;
                        RunObject = page "KINTO Approval Request List";
                    }
                    action("Non-Standard Pending")
                    {
                        Caption = 'Non-Standard Pendentes';
                        ApplicationArea = All;
                        RunObject = page "KINTO Approval Request List";
                    }
                }
            }
            cuegroup(Vehicles)
            {
                Caption = 'Veículos';

                actions
                {
                    action("Available Vehicles")
                    {
                        Caption = 'Disponíveis';
                        ApplicationArea = All;
                        RunObject = page "KINTO Inventory Vehicle List";
                    }
                    action("Soft Reserved Vehicles")
                    {
                        Caption = 'Reservados';
                        ApplicationArea = All;
                        RunObject = page "KINTO Inventory Vehicle List";
                    }
                    action("In Contract Vehicles")
                    {
                        Caption = 'Em Contrato';
                        ApplicationArea = All;
                        RunObject = page "KINTO Inventory Vehicle List";
                    }
                    action("Returned Vehicles")
                    {
                        Caption = 'Devolvidos';
                        ApplicationArea = All;
                        RunObject = page "KINTO Inventory Vehicle List";
                    }
                }
            }
            cuegroup(Config)
            {
                Caption = 'Configuração';
                actions
                {
                    action("Active RV Entries")
                    {
                        Caption = 'Entradas RV Ativas';
                        ApplicationArea = All;
                        RunObject = page "KINTO RV Matrix List";
                    }
                    action("Active Maint. Plans")
                    {
                        Caption = 'Planos de Manutenção Ativos';
                        ApplicationArea = All;
                        RunObject = page "KINTO Maint. Plan List";
                    }
                    action("Total Snapshots")
                    {
                        Caption = 'Snapshots';
                        ApplicationArea = All;
                        RunObject = page "KINTO Snapshot Card";
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