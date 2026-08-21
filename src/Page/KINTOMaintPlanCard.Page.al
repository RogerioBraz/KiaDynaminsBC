page 50134 "KINTO Maint. Plan Card"
{
    Caption = 'KINTO Maintenance Plan Card';
    PageType = Card;
    SourceTable = "KINTO Maintenance Plan Header";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Informações Gerais';
                field("Plan ID"; Rec."Plan ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Vehicle Model No."; Rec."Vehicle Model No.") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Discount %"; Rec."Discount %") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
            }
            group(PoolAndArmoring)
            {
                Caption = 'Pool e Blindagem';
                field(Armoring; Rec.Armoring) { ApplicationArea = All; }
                field("Enable Pool"; Rec."Enable Pool") { ApplicationArea = All; }
                field("Usage Type Filter"; Rec."Usage Type Filter") { ApplicationArea = All; }
            }
            group(MonetaryBalance)
            {
                Caption = 'Monetary Balance (Corrective)';
                field("Monetary Balance Amount"; Rec."Monetary Balance Amount") { ApplicationArea = All; }
                field("Monetary Balance Markup %"; Rec."Monetary Balance Markup %") { ApplicationArea = All; }
            }
            group(Validity)
            {
                Caption = 'Validade';
                field("Active Start Date"; Rec."Active Start Date") { ApplicationArea = All; }
                field("Active End Date"; Rec."Active End Date") { ApplicationArea = All; }
                field("Show on Dealer Portal"; Rec."Show on Dealer Portal") { ApplicationArea = All; }
                field("Block Pre-Approved Pricing"; Rec."Block Pre-Approved Pricing") { ApplicationArea = All; }
            }
            group(Ranges)
            {
                Caption = 'Faixas de Manutenção Preventiva';
                part(RangeSubform; "KINTO Maint Range Subform")
                {
                    ApplicationArea = All;
                    SubPageLink = "Plan ID" = field("Plan ID");
                }
            }
            group(GenericRange)
            {
                Caption = 'Faixa Genérica (Corretiva)';
                part(GenericSubform; "KINTO Maint Generic Range Sub")
                {
                    ApplicationArea = All;
                    SubPageLink = "Plan ID" = field("Plan ID");
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateForContract)
            {
                Caption = 'Calcular Custo para Contrato';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                var
                    ContractTerm: Integer;
                    EstMileage: Decimal;
                    TotalCost: Decimal;
                begin
                    ContractTerm := 36;
                    EstMileage := 30000;
                    TotalCost := Rec.GetTotalCostForContract(ContractTerm, EstMileage, 0, 0);
                    Message('Custo total para contrato %1 meses / %2 km: %3', ContractTerm, EstMileage, TotalCost);
                end;
            }
        }
    }
}