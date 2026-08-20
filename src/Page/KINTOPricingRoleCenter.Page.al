page 50140 "KINTO Pricing Role Center"
{
    Caption = 'KINTO Pricing';
    PageType = RoleCenter;
    ApplicationArea = All;

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "KINTO Pricing Headline") { ApplicationArea = All; }
            part(QuoteActivities; "KINTO Quote Activities") { ApplicationArea = All; }
            part(ApprovalActivities; "KINTO Approval Activities") { ApplicationArea = All; }
        }
    }

    actions
    {
        area(Sections)
        {
            // ============================================================
            // COTAÇÕES
            // ============================================================
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

            // ============================================================
            // VEÍCULOS
            // ============================================================
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
                action(NewVehicle)
                {
                    Caption = 'Novo Veículo';
                    ApplicationArea = All;
                    RunObject = page "KINTO Inventory Vehicle Card";
                    RunPageMode = Create;
                    Image = NewItem;
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

            // ============================================================
            // CADASTROS (NOVO — Master Data nativo com extensões KINTO)
            // ============================================================
            group(Cadastros)
            {
                Caption = 'Cadastros';

                action(ItemList)
                {
                    Caption = 'Itens (Veículos e Acessórios)';
                    ApplicationArea = All;
                    RunObject = page "Item List";
                    Image = Item;
                }
                action(ItemCard)
                {
                    Caption = 'Ficha de Item';
                    ApplicationArea = All;
                    RunObject = page "Item Card";
                    Image = Item;
                }
                action(CustomerList)
                {
                    Caption = 'Clientes';
                    ApplicationArea = All;
                    RunObject = page "Customer List";
                    Image = Customer;
                }
                action(CustomerCard)
                {
                    Caption = 'Ficha de Cliente';
                    ApplicationArea = All;
                    RunObject = page "Customer Card";
                    Image = Customer;
                }
                action(VendorList)
                {
                    Caption = 'Dealers (Fornecedores)';
                    ApplicationArea = All;
                    RunObject = page "Vendor List";
                    Image = Vendor;
                }
                action(VendorCard)
                {
                    Caption = 'Ficha de Dealer';
                    ApplicationArea = All;
                    RunObject = page "Vendor Card";
                    Image = Vendor;
                }
                action(FixedAssetList)
                {
                    Caption = 'Ativos Fixos (Booking Value)';
                    ApplicationArea = All;
                    RunObject = page "Fixed Asset List";
                    Image = FixedAssets;
                }
                action(FixedAssetCard)
                {
                    Caption = 'Ficha de Ativo Fixo';
                    ApplicationArea = All;
                    RunObject = page "Fixed Asset Card";
                    Image = FixedAssets;
                }
                action(ItemCategories)
                {
                    Caption = 'Categorias de Item';
                    ApplicationArea = All;
                    RunObject = page "Item Categories";
                    Image = Category;
                }
            }

            // ============================================================
            // CONFIGURAÇÃO
            // ============================================================
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
                    Image = MapSetup;
                }
                action(NewRVEntry)
                {
                    Caption = 'Nova Entrada RV';
                    ApplicationArea = All;
                    RunObject = page "KINTO RV Matrix Card";
                    RunPageMode = Create;
                    Image = New;
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
                action(NewMaintPlan)
                {
                    Caption = 'Novo Plano de Manutenção';
                    ApplicationArea = All;
                    RunObject = page "KINTO Maint. Plan Card";
                    RunPageMode = Create;
                    Image = New;
                }
            }

            // ============================================================
            // APROVAÇÕES
            // ============================================================
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
            // ============================================================
            // SEGUROS (NOVO)
            // ============================================================
            group(Seguros)
            {
                Caption = 'Seguros';

                action(InsurerList)
                {
                    Caption = 'Seguradoras';
                    ApplicationArea = All;
                    RunObject = page "KINTO Insurer List";
                    Image = Vendor;
                }
                action(InsQuoteGroupList)
                {
                    Caption = 'Grupos de Cotação';
                    ApplicationArea = All;
                    RunObject = page "KINTO Ins. Quote Group List";
                    Image = ItemGroups;
                }
                action(InsuranceQuoteList)
                {
                    Caption = 'Cotações de Seguro';
                    ApplicationArea = All;
                    RunObject = page "KINTO Insurance Quote List";
                    Image = Insurance;
                }
                action(NewInsuranceQuote)
                {
                    Caption = 'Nova Cotação de Seguro';
                    ApplicationArea = All;
                    RunObject = page "KINTO Insurance Quote Card";
                    RunPageMode = Create;
                    Image = New;
                }
            }
        }

        // ============================================================
        // CRIAÇÃO RÁPIDA
        // ============================================================
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
            action(NewVehicleAction)
            {
                Caption = 'Novo Veículo';
                ApplicationArea = All;
                RunObject = page "KINTO Inventory Vehicle Card";
                RunPageMode = Create;
                Image = NewItem;
            }
            action(NewRVEntryAction)
            {
                Caption = 'Nova Entrada RV';
                ApplicationArea = All;
                RunObject = page "KINTO RV Matrix Card";
                RunPageMode = Create;
                Image = New;
            }
            action(NewMaintPlanAction)
            {
                Caption = 'Novo Plano de Manutenção';
                ApplicationArea = All;
                RunObject = page "KINTO Maint. Plan Card";
                RunPageMode = Create;
                Image = New;
            }
            action(NewVehicleModelAction)
            {
                Caption = 'Novo Modelo de Veículo';
                ApplicationArea = All;
                RunObject = page "KINTO Vehicle Model Card";
                RunPageMode = Create;
                Image = NewItem;
            }
        }
        // ============================================================
        // PROCESSAMENTO (Import/Export)
        // ============================================================
        area(Processing)
        {
            action(ImportRVMatrix)
            {
                Caption = 'Importar Matriz RV (Excel)';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Importa entradas da Matriz de Valor Residual via arquivo Excel.';
                RunObject = codeunit "KINTO RV Matrix Excel Import";
            }
            action(ImportMaintPlan)
            {
                Caption = 'Importar Plano de Manutenção (Excel)';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Importa um plano de manutenção via arquivo Excel.';
                // RunObject não pode passar parâmetros, então usamos uma codeunit wrapper
                RunObject = codeunit "KINTO Maint. Plan Excel Import";
            }
            action(DownloadRVTemplate)
            {
                Caption = 'Baixar Template RV Matrix';
                ApplicationArea = All;
                Image = Export;
                ToolTip = 'Baixa um arquivo Excel template para preenchimento da Matriz RV.';
                RunObject = codeunit "KINTO RV Matrix Templ Download";
            }
        }

        // ============================================================
        // RELATÓRIOS
        // ============================================================
        area(Reporting)
        {
            action(ViewCashFlowReport)
            {
                Caption = 'Relatório de Fluxo de Caixa';
                ApplicationArea = All;
                RunObject = page "KINTO Cash Flow Data List";
                Image = Report;
            }
            action(ViewSnapshotsReport)
            {
                Caption = 'Relatório de Snapshots';
                ApplicationArea = All;
                RunObject = page "KINTO Snapshot Card";
                Image = Report;
            }
        }
    }
}