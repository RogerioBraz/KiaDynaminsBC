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
                field("IPVA Rate %"; Rec."IPVA Rate %") { ApplicationArea = All; }
                field("State Revenue Tax %"; Rec."State Revenue Tax %") { ApplicationArea = All; }
                field("Municipal Tax %"; Rec."Municipal Tax %") { ApplicationArea = All; }
                field("Financial Trans. Tax %"; Rec."Financial Trans. Tax %") { ApplicationArea = All; }
                field("Stamp Tax %"; Rec."Stamp Tax %") { ApplicationArea = All; }
                field("Security Fee %"; Rec."Security Fee %") { ApplicationArea = All; }
                field("Contingencies %"; Rec."Contingencies %") { ApplicationArea = All; }
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
                Caption = 'Dates & Periods';
                field("Standard Grace Period"; Rec."Standard Grace Period") { ApplicationArea = All; }
                field("Validity Period"; Rec."Validity Period") { ApplicationArea = All; }
                field("Min. Extended Analysis Months"; Rec."Min. Extended Analysis Months") { ApplicationArea = All; }
                field("Extended Analysis Months"; Rec."Extended Analysis Months") { ApplicationArea = All; }
            }
        }
    }
}