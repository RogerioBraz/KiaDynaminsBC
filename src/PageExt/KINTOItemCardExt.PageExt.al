pageextension 50104 "KINTO Item Card Ext" extends "Item Card"
{
    layout
    {
        addafter(Item)
        {
            group(KINTOClassification)
            {
                Caption = 'KINTO Classification';

                field("KINTO Category"; Rec."KINTO Category")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("KINTO Subcategory"; Rec."KINTO Subcategory")
                {
                    ApplicationArea = All;
                    Visible = Rec."KINTO Category" <> Rec."KINTO Category"::"Vehicle Base";
                }
                field("Vehicle Model No."; Rec."Vehicle Model No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Vehicle Version"; Rec."Vehicle Version")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Year"; Rec."Vehicle Year")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Condition"; Rec."Vehicle Condition")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Vehicle Market Code"; Rec."Vehicle Market Code")
                {
                    ApplicationArea = All;
                }
                field("Part Number"; Rec."Part Number")
                {
                    ApplicationArea = All;
                }
            }
            group(KINTOVehicleData)
            {
                Caption = 'KINTO Vehicle Data';
                Visible = Rec."KINTO Category" = Rec."KINTO Category"::"Vehicle Base";

                field("Vehicle Mileage"; Rec."Vehicle Mileage")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Age Months"; Rec."Vehicle Age Months")
                {
                    ApplicationArea = All;
                }
                field("Latest 0km Model"; Rec."Latest 0km Model")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Tax %"; Rec."Vehicle Tax %")
                {
                    ApplicationArea = All;
                }
                field("Fixed Asset Eligible"; Rec."Fixed Asset Eligible")
                {
                    ApplicationArea = All;
                }
                field("Pool Allowed"; Rec."Pool Allowed")
                {
                    ApplicationArea = All;
                }
                field("Valid for All Vehicles"; Rec."Valid for All Vehicles")
                {
                    ApplicationArea = All;
                }
                field("Implement is Removable"; Rec."Implement is Removable")
                {
                    ApplicationArea = All;
                    Visible = Rec."KINTO Category" = Rec."KINTO Category"::Implement;
                }
            }
            group(KINTOPricing)
            {
                Caption = 'KINTO Pricing';
                Visible = Rec."KINTO Category" = Rec."KINTO Category"::"Vehicle Base";

                field("MSRP Metallic Paint"; Rec."MSRP Metallic Paint")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Metallic Paint Adjustment %"; Rec."Metallic Paint Adjustment %")
                {
                    ApplicationArea = All;
                }
                field("Comm. Depreciation %"; Rec."Comm. Depreciation %")
                {
                    ApplicationArea = All;
                }
                field("Remarketing Sales Comm. %"; Rec."Remarketing Sales Comm. %")
                {
                    ApplicationArea = All;
                }
                field("Billing from Supplier Freq."; Rec."Billing from Supplier Freq.")
                {
                    ApplicationArea = All;
                }
                field("Discontinued Date"; Rec."Discontinued Date")
                {
                    ApplicationArea = All;
                }
            }
            group(KINTOInsurance)
            {
                Caption = 'KINTO Insurance Coverage';
                // Visible = (Rec."KINTO Category" = Rec."KINTO Category"::"Insurance Package") or
                //           (Rec."KINTO Category" = Rec."KINTO Category"::"Vehicle Base");
                Visible = false;

                field("Property Damage %"; Rec."Property Damage %")
                {
                    ApplicationArea = All;
                }
                field("Moral Damages %"; Rec."Moral Damages %")
                {
                    ApplicationArea = All;
                }
                field("Bodily Injury %"; Rec."Bodily Injury %")
                {
                    ApplicationArea = All;
                }
                field("PPA Death Benefit %"; Rec."PPA Death Benefit %")
                {
                    ApplicationArea = All;
                }
                field("PPA Permanent Disability %"; Rec."PPA Permanent Disability %")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Body Coverage %"; Rec."Vehicle Body Coverage %")
                {
                    ApplicationArea = All;
                }
                field("Deductible Type"; Rec."Deductible Type")
                {
                    ApplicationArea = All;
                }
                field("Deductible Amount"; Rec."Deductible Amount")
                {
                    ApplicationArea = All;
                    Visible = Rec."Deductible Type" = Rec."Deductible Type"::"Fixed Amount";
                }
                field("Coverage Limit Type"; Rec."Coverage Limit Type")
                {
                    ApplicationArea = All;
                }
                field("Coverage Limit"; Rec."Coverage Limit")
                {
                    ApplicationArea = All;
                    Visible = Rec."Coverage Limit Type" = Rec."Coverage Limit Type"::"Fixed Amount";
                }
            }
            group(KINTOPortal)
            {
                Caption = 'KINTO Portal & Approval';
                field("Show on Dealer Portal"; Rec."Show on Dealer Portal")
                {
                    ApplicationArea = All;
                }
                field("Block Pre-Approved Pricing"; Rec."Block Pre-Approved Pricing")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addfirst(processing)
        {
            action(KINTOViewVehicleModel)
            {
                Caption = 'View Vehicle Model';
                ApplicationArea = All;
                Image = ItemLedger;
                Visible = Rec."Vehicle Model No." <> '';

                trigger OnAction()
                var
                    VehicleModel: Record "KINTO Vehicle Model";
                begin
                    if Rec."Vehicle Model No." <> '' then
                        if VehicleModel.Get(Rec."Vehicle Model No.") then
                            Page.Run(Page::"KINTO Vehicle Model Card", VehicleModel);
                end;
            }
            action(KINTOViewRVMatrix)
            {
                Caption = 'View RV Matrix Entries';
                ApplicationArea = All;
                Image = Matrix;
                Visible = Rec."KINTO Category" = Rec."KINTO Category"::"Vehicle Base";

                trigger OnAction()
                var
                    RVMatrix: Record "KINTO RV Matrix";
                begin
                    RVMatrix.SetRange("Item No.", Rec."No.");
                    Page.Run(Page::"KINTO RV Matrix List", RVMatrix);
                end;
            }
            action(KINTOViewInventory)
            {
                Caption = 'View Inventory Vehicles';
                ApplicationArea = All;
                Image = Item;
                Visible = Rec."KINTO Category" = Rec."KINTO Category"::"Vehicle Base";

                trigger OnAction()
                var
                    InventoryVehicle: Record "KINTO Inventory Vehicle";
                begin
                    InventoryVehicle.SetRange("Item No.", Rec."No.");
                    Page.Run(Page::"KINTO Inventory Vehicle List", InventoryVehicle);
                end;
            }
        }
    }
}