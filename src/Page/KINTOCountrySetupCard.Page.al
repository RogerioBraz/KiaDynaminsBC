page 50100 "KINTO Country Setup Card"
{
    Caption = 'KINTO Country Setup';
    PageType = Card;
    SourceTable = "KINTO Country Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Pricing Methodology"; Rec."Pricing Methodology") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Allow USD Contracts"; Rec."Allow USD Contracts") { ApplicationArea = All; }
                field("Emergency Stop"; Rec."Emergency Stop") { ApplicationArea = All; }
            }
            group(Commissions)
            {
                Caption = 'Commissions';
                field("DLR Commission Model"; Rec."DLR Commission Model") { ApplicationArea = All; }
            }
            group(Taxes)
            {
                Caption = 'Taxes';
                field("National Revenue Tax %"; Rec."National Revenue Tax %") { ApplicationArea = All; }
                field("National Revenue Tax Desc."; Rec."National Revenue Tax Desc.") { ApplicationArea = All; }
                field("PIS COFINS Credit %"; Rec."PIS COFINS Credit %") { ApplicationArea = All; }
                field("IPVA Rate %"; Rec."IPVA Rate %") { ApplicationArea = All; }
                field("State Revenue Tax %"; Rec."State Revenue Tax %") { ApplicationArea = All; }
                field("State Revenue Tax Desc."; Rec."State Revenue Tax Desc.") { ApplicationArea = All; }
                field("Municipal Tax %"; Rec."Municipal Tax %") { ApplicationArea = All; }
                field("Municipal Tax Desc."; Rec."Municipal Tax Desc.") { ApplicationArea = All; }
                field("Financial Trans. Tax %"; Rec."Financial Trans. Tax %") { ApplicationArea = All; }
                field("Financial Trans. Tax Desc."; Rec."Financial Trans. Tax Desc.") { ApplicationArea = All; }
                field("Stamp Tax %"; Rec."Stamp Tax %") { ApplicationArea = All; }
                field("Stamp Tax Desc."; Rec."Stamp Tax Desc.") { ApplicationArea = All; }
                field("Security Fee %"; Rec."Security Fee %") { ApplicationArea = All; }
                field("Security Fee Desc."; Rec."Security Fee Desc.") { ApplicationArea = All; }
                field("Contingencies %"; Rec."Contingencies %") { ApplicationArea = All; }
                field("Contingencies Desc."; Rec."Contingencies Desc.") { ApplicationArea = All; }
                field("Profit Tax Rate %"; Rec."Profit Tax Rate %") { ApplicationArea = All; }
                field("Tax Depreciation Period"; Rec."Tax Depreciation Period") { ApplicationArea = All; }
            }
            group(Financial)
            {
                Caption = 'Financial Parameters';
                field("Annual Interest Expense %"; Rec."Annual Interest Expense %") { ApplicationArea = All; }
                field("Spread"; Rec."Spread") { ApplicationArea = All; }
                field("Default Inflation Index %"; Rec."Default Inflation Index %") { ApplicationArea = All; }
                field("Inflation Adj. Frequency"; Rec."Inflation Adj. Frequency") { ApplicationArea = All; }
                field("Annual Tire Inflation %"; Rec."Annual Tire Inflation %") { ApplicationArea = All; }
                field("Idleness Rate %"; Rec."Idleness Rate %") { ApplicationArea = All; }
            }
            group(CreditRisk)
            {
                Caption = 'Credit Risk Factors';
                field("Credit Risk A %"; Rec."Credit Risk A %") { ApplicationArea = All; }
                field("Credit Risk B %"; Rec."Credit Risk B %") { ApplicationArea = All; }
                field("Credit Risk C %"; Rec."Credit Risk C %") { ApplicationArea = All; }
                field("Credit Risk D %"; Rec."Credit Risk D %") { ApplicationArea = All; }
                field("Credit Risk E %"; Rec."Credit Risk E %") { ApplicationArea = All; }
                field("Credit Risk F %"; Rec."Credit Risk F %") { ApplicationArea = All; }
                field("Default Credit Risk %"; Rec."Default Credit Risk %") { ApplicationArea = All; }
            }
            group(Pricing)
            {
                Caption = 'Pricing Parameters';
                field("Suggested Negot. Buffer %"; Rec."Suggested Negot. Buffer %") { ApplicationArea = All; }
                field("Net Contribution Margin %"; Rec."Net Contribution Margin %") { ApplicationArea = All; }
                field("Apply SGA in Cash Flow"; Rec."Apply SGA in Cash Flow") { ApplicationArea = All; }
                field("Apply Monthly Fee Inflation"; Rec."Apply Monthly Fee Inflation") { ApplicationArea = All; }
            }
            group(UsedVehicles)
            {
                Caption = 'Used Vehicles';
                field("reKinto Pre-Approved"; Rec."reKinto Pre-Approved") { ApplicationArea = All; }
                field("Renew Used Car Pre-Approved"; Rec."Renew Used Car Pre-Approved") { ApplicationArea = All; }
                field("Max Projected Vehicle Age"; Rec."Max Projected Vehicle Age") { ApplicationArea = All; }
                field("Max Projected Mileage"; Rec."Max Projected Mileage") { ApplicationArea = All; }
            }
            group(Mileage)
            {
                Caption = 'Mileage';
                field("Exceeded Mileage Cost Cap"; Rec."Exceeded Mileage Cost Cap") { ApplicationArea = All; }
                field("Excess Mileage Aggrav. %"; Rec."Excess Mileage Aggrav. %") { ApplicationArea = All; }
                field("Aggravated Excess Mileage"; Rec."Aggravated Excess Mileage") { ApplicationArea = All; }
            }
            group(Dates)
            {
                Caption = 'Dates and Periods';
                field("Standard Grace Period"; Rec."Standard Grace Period") { ApplicationArea = All; }
                field("Validity Period"; Rec."Validity Period") { ApplicationArea = All; }
                field("Min. Extended Analysis Months"; Rec."Min. Extended Analysis Months") { ApplicationArea = All; }
                field("Extended Analysis Months"; Rec."Extended Analysis Months") { ApplicationArea = All; }
            }

            group(NumberSeries)
            {
                Caption = 'Number Series';
                field("Pricing Series"; Rec."Pricing Series") { ApplicationArea = All; }
                field("Contract Series"; Rec."Contract Series") { ApplicationArea = All; }
                field("Condition Series"; Rec."Condition Series") { ApplicationArea = All; }
                field("Billing Series"; Rec."Billing Series") { ApplicationArea = All; }
                field("Vehicle Series"; Rec."Vehicle Series") { ApplicationArea = All; }
                field("Ticket Series"; Rec."Ticket Series") { ApplicationArea = All; }
                field("Return Series"; Rec."Return Series") { ApplicationArea = All; }
                field("Substitution Series"; Rec."Substitution Series") { ApplicationArea = All; }
                field("Settlement Series"; Rec."Settlement Series") { ApplicationArea = All; }
                field("Recovery Series"; Rec."Recovery Series") { ApplicationArea = All; }
                field("Claim Series"; Rec."Claim Series") { ApplicationArea = All; }
                field("Fine Series"; Rec."Fine Series") { ApplicationArea = All; }
                field("Policy Series"; Rec."Policy Series") { ApplicationArea = All; }
                field("Device Series"; Rec."Device Series") { ApplicationArea = All; }
                field("Approval Series"; Rec."Approval Series") { ApplicationArea = All; }
            }
            group(NumberSeriesRemarketing)
            {
                Caption = 'Number Series — Remarketing & Contracts';
                field("Remarketing Offer Series"; Rec."Remarketing Offer Series") { ApplicationArea = All; }
                field("Remarketing Sale Series"; Rec."Remarketing Sale Series") { ApplicationArea = All; }
                field("Evaluation Series"; Rec."Evaluation Series") { ApplicationArea = All; }
                field("Pre-Closure Series"; Rec."Pre-Closure Series") { ApplicationArea = All; }
            }
            group(CalcLimits)
            {
                Caption = 'Calculation Limits and Caps';
                field("Excess Km Band 1 %"; Rec."Excess Km Band 1 %") { ApplicationArea = All; }
                field("Service Credit Cap %"; Rec."Service Credit Cap %") { ApplicationArea = All; }
                field("SLA Penalty Cap %"; Rec."SLA Penalty Cap %") { ApplicationArea = All; }
                field("Total Loss Threshold %"; Rec."Total Loss Threshold %") { ApplicationArea = All; }
                field("Remarketing Km Deprec. Base"; Rec."Remarketing Km Deprec. Base") { ApplicationArea = All; }
                field("Remarketing Km Deprec. %"; Rec."Remarketing Km Deprec. %") { ApplicationArea = All; }
                field("Device Daily Charge"; Rec."Device Daily Charge") { ApplicationArea = All; }
            }
            group(MaintenanceRules)
            {
                Caption = 'Maintenance and Contract Rules';
                field("Preventive Interval Months"; Rec."Preventive Interval Months") { ApplicationArea = All; }
                field("Odometer Tolerance (km)"; Rec."Odometer Tolerance (km)") { ApplicationArea = All; }
                field("Contract Notice Days"; Rec."Contract Notice Days") { ApplicationArea = All; }
                field("Auto Extend Contracts"; Rec."Auto Extend Contracts") { ApplicationArea = All; }
            }
            group(FleetOps)
            {
                Caption = 'Fleet Operations';
                field("Fleet Behavior"; Rec."Fleet Behavior") { ApplicationArea = All; }
                field("Device Aging Charge Days"; Rec."Device Aging Charge Days") { ApplicationArea = All; }
                field("Demob. SLA Days (Lot)"; Rec."Demob. SLA Days (Lot)") { ApplicationArea = All; }
                field("Demob. SLA Days (Wash)"; Rec."Demob. SLA Days (Wash)") { ApplicationArea = All; }
                field("Demob. SLA Days (Save)"; Rec."Demob. SLA Days (Save)") { ApplicationArea = All; }
                field("Closing Reconcile By VIN"; Rec."Closing Reconcile By VIN") { ApplicationArea = All; }
                field("Closing Reconcile By Plate"; Rec."Closing Reconcile By Plate") { ApplicationArea = All; }
            }
            group(CashFlow)
            {
                Caption = 'Cash Flow and Inflation';
                field("Ref. Interest Rate Period"; Rec."Ref. Interest Rate Period") { ApplicationArea = All; }
                field("SGA Inflation Adj. Freq."; Rec."SGA Inflation Adj. Freq.") { ApplicationArea = All; }
            }
        }
    }
}
