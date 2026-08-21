permissionset 50101 "KINTO PRICING USER"
{
    Caption = 'KINTO Pricing - User';
    Assignable = true;

    Permissions =
        // ... objetos existentes ...
        // Pacotes: R (read-only para Users — Admin cria)
        table "KINTO Glass Coverage Package" = X,
        table "KINTO 24h Assistance Package" = X,
        table "KINTO Pickup Delivery Package" = X,
        table "KINTO Replacement Vehicle Pkg" = X,
        table "KINTO Tire Package" = X,
        table "KINTO Service Package" = X,
        table "KINTO Insurance Coverage Limit" = X,
        table "KINTO Vendor Category" = X,
        table "KINTO Vendor Category Assign" = X,
        table "KINTO Vendor Contact" = X,
        table "KINTO Supplier Group" = X,
        table "KINTO Supplier Group Assign" = X,
        table "KINTO Item Supplier Group" = X,
        table "KINTO Maintenance Range" = X,
        table "KINTO Maintenance Number" = X,
        table "KINTO Mainten Generic Range" = X,
        table "KINTO Item Version History" = X,
        codeunit "KINTO Package Pricing Calc" = X,
        page "KINTO Glass Coverage List" = X,
        page "KINTO 24h Assistance List" = X,
        page "KINTO Pickup Delivery List" = X,
        page "KINTO Repl Vehicle List" = X,
        page "KINTO Tire Package List" = X,
        page "KINTO Service Package List" = X,
        page "KINTO Vendor Category List" = X,
        page "KINTO Vendor Contact List" = X,
        page "KINTO Supplier Group List" = X,
        page "KINTO Item Version History" = X;
}