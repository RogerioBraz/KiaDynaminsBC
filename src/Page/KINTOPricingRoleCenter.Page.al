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
            // QUOTES
            // ============================================================
            group(Quotes)
            {
                Caption = 'Quotes';

                action(QuoteList)
                {
                    Caption = 'Quotes';
                    ApplicationArea = All;
                    RunObject = page "KINTO Quote List";
                    Image = List;
                }
                action(NewQuote)
                {
                    Caption = 'New Quote';
                    ApplicationArea = All;
                    RunObject = page "KINTO Quote Card";
                    RunPageMode = Create;
                    Image = New;
                }
                action(CashFlowData)
                {
                    Caption = 'Cash Flow';
                    ApplicationArea = All;
                    RunObject = page "KINTO Cash Flow Data List";
                    Image = CashFlow;
                }
                action(Snapshots)
                {
                    Caption = 'Simulation Snapshots';
                    ApplicationArea = All;
                    RunObject = page "KINTO Snapshot Card";
                    Image = CopyBudget;
                }
            }

            // ============================================================
            // VEHICLES
            // ============================================================
            group(Vehicles)
            {
                Caption = 'Vehicles';

                action(InventoryVehicleList)
                {
                    Caption = 'Vehicles in Stock';
                    ApplicationArea = All;
                    RunObject = page "KINTO Inventory Vehicle List";
                    Image = Item;
                }
                action(NewVehicle)
                {
                    Caption = 'New Vehicle';
                    ApplicationArea = All;
                    RunObject = page "KINTO Inventory Vehicle Card";
                    RunPageMode = Create;
                    Image = NewItem;
                }
                action(VehicleModelList)
                {
                    Caption = 'Vehicle Models';
                    ApplicationArea = All;
                    RunObject = page "KINTO Vehicle Model List";
                    Image = ItemLedger;
                }
                action(OdometerHistory)
                {
                    Caption = 'Odometer History';
                    ApplicationArea = All;
                    RunObject = page "KINTO Odometer History List";
                    Image = History;
                }
            }

            // ============================================================
            // SETUP (NEW — Native Master Data with KINTO Extensions)
            // ============================================================
            group(MasterData)
            {
                Caption = 'Master Data';

                action(ItemList)
                {
                    Caption = 'Items (Vehicles and Accessories)';
                    ApplicationArea = All;
                    RunObject = page "Item List";
                    Image = Item;
                }
                action(ItemCard)
                {
                    Caption = 'Item Card';
                    ApplicationArea = All;
                    RunObject = page "Item Card";
                    Image = Item;
                }
                action(CustomerList)
                {
                    Caption = 'Customers';
                    ApplicationArea = All;
                    RunObject = page "Customer List";
                    Image = Customer;
                }
                action(CustomerCard)
                {
                    Caption = 'Customer Card';
                    ApplicationArea = All;
                    RunObject = page "Customer Card";
                    Image = Customer;
                }
                action(VendorList)
                {
                    Caption = 'Dealers (Vendors)';
                    ApplicationArea = All;
                    RunObject = page "Vendor List";
                    Image = Vendor;
                }
                action(VendorCard)
                {
                    Caption = 'Dealer Card';
                    ApplicationArea = All;
                    RunObject = page "Vendor Card";
                    Image = Vendor;
                }
                action(FixedAssetList)
                {
                    Caption = 'Fixed Assets (Booking Value)';
                    ApplicationArea = All;
                    RunObject = page "Fixed Asset List";
                    Image = FixedAssets;
                }
                action(FixedAssetCard)
                {
                    Caption = 'Fixed Asset Card';
                    ApplicationArea = All;
                    RunObject = page "Fixed Asset Card";
                    Image = FixedAssets;
                }
                action(ItemCategories)
                {
                    Caption = 'Item Categories';
                    ApplicationArea = All;
                    RunObject = page "Item Categories";
                    Image = Category;
                }
            }

            // ============================================================
            // SETUP
            // ============================================================
            group(Setup)
            {
                Caption = 'Setup';

                action(CountrySetup)
                {
                    Caption = 'Country Setup';
                    ApplicationArea = All;
                    RunObject = page "KINTO Country Setup Card";
                    Image = Setup;
                }
                action(RVMatrix)
                {
                    Caption = 'Residual Value Matrix';
                    ApplicationArea = All;
                    RunObject = page "KINTO RV Matrix List";
                    Image = MapSetup;
                }
                action(NewRVEntry)
                {
                    Caption = 'New RV Entry';
                    ApplicationArea = All;
                    RunObject = page "KINTO RV Matrix Card";
                    RunPageMode = Create;
                    Image = New;
                }
                action(CFComponents)
                {
                    Caption = 'Cash Flow Components';
                    ApplicationArea = All;
                    RunObject = page "KINTO CF Component List";
                    Image = SetupLines;
                }
                action(MaintenancePlans)
                {
                    Caption = 'Maintenance Plans';
                    ApplicationArea = All;
                    RunObject = page "KINTO Maint. Plan List";
                    Image = TaskList;
                }
                action(NewMaintPlan)
                {
                    Caption = 'New Maintenance Plan';
                    ApplicationArea = All;
                    RunObject = page "KINTO Maint. Plan Card";
                    RunPageMode = Create;
                    Image = New;
                }
            }
            group(Packages)
            {
                Caption = 'Service Packages';

                action(GlassCoverageList)
                {
                    Caption = 'Glass Coverage';
                    ApplicationArea = All;
                    RunObject = page "KINTO Glass Coverage List";
                    Image = Insurance;
                }
                action(Assistance24hList)
                {
                    Caption = '24h Assistance';
                    ApplicationArea = All;
                    RunObject = page "KINTO 24h Assistance List";
                    Image = Assistance;
                }
                action(PickupDeliveryList)
                {
                    Caption = 'Pick-up & Delivery';
                    ApplicationArea = All;
                    RunObject = page "KINTO Pickup Delivery List";
                    Image = Delivery;
                }
                action(ReplacementVehicleList)
                {
                    Caption = 'Replacement Vehicle';
                    ApplicationArea = All;
                    RunObject = page "KINTO Repl Vehicle List";
                    Image = Car;
                }
                action(TirePackageList)
                {
                    Caption = 'Tires';
                    ApplicationArea = All;
                    RunObject = page "KINTO Tire Package List";
                    Image = Item;
                }
                action(ServicePackageList)
                {
                    Caption = 'Services (Telemetry)';
                    ApplicationArea = All;
                    RunObject = page "KINTO Service Package List";
                    Image = ServiceCode;
                }
            }
            group(Vendors)
            {
                Caption = 'Vendors';

                action(VendorCategoryList)
                {
                    Caption = 'Vendor Categories';
                    ApplicationArea = All;
                    RunObject = page "KINTO Vendor Category List";
                    Image = Category;
                }
                action(VendorContactList)
                {
                    Caption = 'Contacts (Dealer Portal)';
                    ApplicationArea = All;
                    RunObject = page "KINTO Vendor Contact List";
                    Image = ContactPerson;
                }
                action(SupplierGroupList)
                {
                    Caption = 'Vendor Groups';
                    ApplicationArea = All;
                    RunObject = page "KINTO Supplier Group List";
                    Image = Group;
                }
                action(ItemVersionHistory)
                {
                    Caption = 'Item Version History';
                    ApplicationArea = All;
                    RunObject = page "KINTO Item Version History";
                    Image = History;
                }
            }


            // ============================================================
            //  APPROVALS
            // ============================================================
            group(Approvals)
            {
                Caption = 'Approvals';

                action(ApprovalRequests)
                {
                    Caption = 'Approval Requests';
                    ApplicationArea = All;
                    RunObject = page "KINTO Approval Request List";
                    Image = Approval;
                }
            }
            // ============================================================
            // INSURANCE (NEW)
            // ============================================================
            group(Insurance)
            {
                Caption = 'Insurance';

                action(InsurerList)
                {
                    Caption = 'Insurers';
                    ApplicationArea = All;
                    RunObject = page "KINTO Insurer List";
                    Image = Vendor;
                }
                action(InsQuoteGroupList)
                {
                    Caption = 'Quote Groups';
                    ApplicationArea = All;
                    RunObject = page "KINTO Ins. Quote Group List";
                    Image = ItemGroups;
                }
                action(InsuranceQuoteList)
                {
                    Caption = 'Insurance Quotes';
                    ApplicationArea = All;
                    RunObject = page "KINTO Insurance Quote List";
                    Image = Insurance;
                }
                action(NewInsuranceQuote)
                {
                    Caption = 'New Insurance Quote';
                    ApplicationArea = All;
                    RunObject = page "KINTO Insurance Quote Card";
                    RunPageMode = Create;
                    Image = New;
                }
                action(InsCoverageLimitSub)
                {
                    Caption = 'KINTO Ins Coverage Limit Sub';
                    ApplicationArea = All;
                    RunObject = page "KINTO Ins Coverage Limit Sub";
                    RunPageMode = Create;
                    Image = New;
                }

            }
        }

        // ============================================================
        // FAST CREATION
        // ============================================================
        area(Creation)
        {
            action(NewQuoteAction)
            {
                Caption = 'New Quote';
                ApplicationArea = All;
                RunObject = page "KINTO Quote Card";
                RunPageMode = Create;
                Image = NewDocument;
            }
            action(NewVehicleAction)
            {
                Caption = 'New Vehicle';
                ApplicationArea = All;
                RunObject = page "KINTO Inventory Vehicle Card";
                RunPageMode = Create;
                Image = NewItem;
            }
            action(NewRVEntryAction)
            {
                Caption = 'New RV Entry';
                ApplicationArea = All;
                RunObject = page "KINTO RV Matrix Card";
                RunPageMode = Create;
                Image = New;
            }
            action(NewMaintPlanAction)
            {
                Caption = 'New Maintenance Plan';
                ApplicationArea = All;
                RunObject = page "KINTO Maint. Plan Card";
                RunPageMode = Create;
                Image = New;
            }
            action(NewVehicleModelAction)
            {
                Caption = 'New Vehicle Model';
                ApplicationArea = All;
                RunObject = page "KINTO Vehicle Model Card";
                RunPageMode = Create;
                Image = NewItem;
            }
        }
        // ============================================================
        // PROCESSING (Import/Export)
        // ============================================================
        area(Processing)
        {
            action(ImportRVMatrix)
            {
                Caption = 'Import RV Matrix (Excel)';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Imports Residual Value Matrix entries from an Excel file.';
                RunObject = codeunit "KINTO RV Matrix Excel Import";
            }
            action(ImportMaintPlan)
            {
                Caption = 'Import Maintenance Plan (Excel)';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Imports a maintenance plan from an Excel file.';
                //RunObject cannot pass parameters, so we use a wrapper codeunit.
                RunObject = codeunit "KINTO Maint. Plan Excel Import";
            }
            action(DownloadRVTemplate)
            {
                Caption = 'Download RV Matrix Template';
                ApplicationArea = All;
                Image = Export;
                ToolTip = 'Downloads an Excel template for entering the Residual Value Matrix.';
                RunObject = codeunit "KINTO RV Matrix Templ Download";
            }
        }

        // ============================================================
        // REPORTING
        // ============================================================
        area(Reporting)
        {
            action(ViewCashFlowReport)
            {
                Caption = 'Cash Flow Report';
                ApplicationArea = All;
                RunObject = page "KINTO Cash Flow Data List";
                Image = Report;
            }
            action(ViewSnapshotsReport)
            {
                Caption = 'Snapshots Report';
                ApplicationArea = All;
                RunObject = page "KINTO Snapshot Card";
                Image = Report;
            }
        }
    }
}