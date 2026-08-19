page 50140 "KINTO Pricing Role Center"
{
    Caption = 'KINTO Pricing';
    PageType = RoleCenter;
    ApplicationArea = All;

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "KINTO Pricing Headline")
            {
                ApplicationArea = All;
            }
            part(QuoteActivities; "KINTO Quote Activities")
            {
                ApplicationArea = All;
            }
            part(ApprovalActivities; "KINTO Approval Activities")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Cotacoes)
            {
                Caption = 'Cotações';

                action(QuoteList)
                {
                    Caption = 'Cotações';
                    ApplicationArea = All;
                    RunObject = page "KINTO Quote List";
                    Image = List;
                }
                action(NewQuote)
                {
                    Caption = 'Nova Cotação';
                    ApplicationArea = All;
                    RunObject = page "KINTO Quote Card";
                    RunPageMode = Create;
                    Image = New;
                }
                action(CashFlowData)
                {
                    Caption = 'Fluxo de Caixa';
                    ApplicationArea = All;
                    RunObject = page "KINTO Cash Flow Data List";
                    Image = CashFlow;
                }
                action(Snapshots)
                {
                    Caption = 'Snapshots de Simulação';
                    ApplicationArea = All;
                    RunObject = page "KINTO Snapshot Card";
                    Image = Snapshot;
                }
            }

            group(Veiculos)
            {
                Caption = 'Veículos';

                action(InventoryVehicleList)
                {
                    Caption = 'Veículos em Estoque';
                    ApplicationArea = All;
                    RunObject = page "KINTO Inventory Vehicle List";
                    Image = Item;
                }
                action(VehicleModelList)
                {
                    Caption = 'Modelos de Veículos';
                    ApplicationArea = All;
                    RunObject = page "KINTO Vehicle Model List";
                    Image = ItemLedger;
                }
                action(OdometerHistory)
                {
                    Caption = 'Histórico de Odômetro';
                    ApplicationArea = All;
                    RunObject = page "KINTO Odometer History List";
                    Image = History;
                }
            }

            group(Configuracao)
            {
                Caption = 'Configuração';

                action(CountrySetup)
                {
                    Caption = 'Configuração por País';
                    ApplicationArea = All;
                    RunObject = page "KINTO Country Setup Card";
                    Image = Setup;
                }
                action(RVMatrix)
                {
                    Caption = 'Matriz de Valor Residual';
                    ApplicationArea = All;
                    RunObject = page "KINTO RV Matrix List";
                    Image = Matrix;
                }
                action(CFComponents)
                {
                    Caption = 'Componentes de Cash Flow';
                    ApplicationArea = All;
                    RunObject = page "KINTO CF Component List";
                    Image = SetupLines;
                }
                action(MaintenancePlans)
                {
                    Caption = 'Planos de Manutenção';
                    ApplicationArea = All;
                    RunObject = page "KINTO Maint. Plan List";
                    Image = TaskList;
                }
            }

            group(Aprovacoes)
            {
                Caption = 'Aprovações';

                action(ApprovalRequests)
                {
                    Caption = 'Solicitações de Aprovação';
                    ApplicationArea = All;
                    RunObject = page "KINTO Approval Request List";
                    Image = Approval;
                }
            }
        }

        area(Creation)
        {
            action(NewQuoteAction)
            {
                Caption = 'Nova Cotação';
                ApplicationArea = All;
                RunObject = page "KINTO Quote Card";
                RunPageMode = Create;
                Image = NewDocument;
            }
            action(NewVehicle)
            {
                Caption = 'Novo Veículo';
                ApplicationArea = All;
                RunObject = page "KINTO Inventory Vehicle Card";
                RunPageMode = Create;
                Image = NewItem;
            }
            action(NewRVEntry)
            {
                Caption = 'Nova Entrada RV';
                ApplicationArea = All;
                RunObject = page "KINTO RV Matrix Card";
                RunPageMode = Create;
                Image = New;
            }
            action(NewMaintPlan)
            {
                Caption = 'Novo Plano de Manutenção';
                ApplicationArea = All;
                RunObject = page "KINTO Maint. Plan Card";
                RunPageMode = Create;
                Image = New;
            }
        }

        area(Processing)
        {
            action(ImportRVMatrix)
            {
                Caption = 'Importar Matriz RV (Excel)';
                ApplicationArea = All;
                Image = ImportExcel;
                // trigger OnAction()
                // var
                //     RVImport: Codeunit "KINTO RV Matrix Excel Import";
                // begin
                //     RVImport.ImportRVMatrixFromExcel();
                // end;
            }
            action(ImportMaintPlan)
            {
                Caption = 'Importar Plano de Manutenção (Excel)';
                ApplicationArea = All;
                Image = Import;
                // trigger OnAction()
                // var
                //     MaintImport: Codeunit "KINTO Maint. Plan Excel Import";
                //     PlanID: Code[20];
                //     Description: Text[100];
                //     DiscountPct: Decimal;
                // begin
                //     // In production, show a dialog page to capture PlanID, Description, Discount
                //     PlanID := '';
                //     Description := '';
                //     DiscountPct := 0;
                //     MaintImport.ImportMaintenancePlanFromExcel(PlanID, Description, DiscountPct);
                // end;
            }
            action(DownloadRVTemplate)
            {
                Caption = 'Baixar Template RV Matrix';
                ApplicationArea = All;
                Image = ExportExcel;
                // trigger OnAction()
                // var
                //     RVImport: Codeunit "KINTO RV Matrix Excel Import";
                // begin
                //     RVImport.DownloadTemplate();
                // end;
            }
        }

        area(Reporting)
        {
            action(ViewCashFlow)
            {
                Caption = 'Relatório de Fluxo de Caixa';
                ApplicationArea = All;
                RunObject = page "KINTO Cash Flow Data List";
                Image = Report;
            }
            action(ViewSnapshots)
            {
                Caption = 'Relatório de Snapshots';
                ApplicationArea = All;
                RunObject = page "KINTO Snapshot Card";
                Image = Report;
            }
        }
    }
}