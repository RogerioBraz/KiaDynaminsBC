permissionset 50100 "KINTO PRICING ADMIN"
{
    Caption = 'KINTO Pricing - Admin';
    Assignable = true;

    Permissions =
        // ... objetos existentes ...
        // NOVOS: Tabelas de Pacotes
        table "KINTO Glass Coverage Package" = X,
        table "KINTO 24h Assistance Package" = X,
        table "KINTO Pickup Delivery Package" = X,
        table "KINTO Replacement Vehicle Pkg" = X,
        table "KINTO Tire Package" = X,
        table "KINTO Service Package" = X,
        table "KINTO Insurance Coverage Limit" = X,
        // NOVOS: Tabelas de Vendor/Supplier
        table "KINTO Vendor Category" = X,
        table "KINTO Vendor Category Assign" = X,
        table "KINTO Vendor Contact" = X,
        table "KINTO Supplier Group" = X,
        table "KINTO Supplier Group Assign" = X,
        table "KINTO Item Supplier Group" = X,
        // NOVOS: Tabelas de Manutenção
        table "KINTO Maintenance Range" = X,
        table "KINTO Maintenance Number" = X,
        table "KINTO Mainten Generic Range" = X,
        // NOVOS: Item Version History
        table "KINTO Item Version History" = X,
        // NOVOS: Codeunits
        codeunit "KINTO Package Pricing Calc" = X,
        // NOVOS: Pages
        page "KINTO Glass Coverage List" = X,
        page "KINTO Glass Coverage Card" = X,
        page "KINTO 24h Assistance List" = X,
        page "KINTO Pickup Delivery List" = X,
        page "KINTO Repl Vehicle List" = X,
        page "KINTO Tire Package List" = X,
        page "KINTO Service Package List" = X,
        page "KINTO Vendor Category List" = X,
        page "KINTO Vendor Contact List" = X,
        page "KINTO Supplier Group List" = X,
        page "KINTO Item Version History" = X,
        page "KINTO Maint Range Subform" = X,
        page "KINTO Maint Number Subform" = X,
        page "KINTO Maint Generic Range Sub" = X,
        page "KINTO Ins Coverage Limit Sub" = X,
        page "KINTO Vendor Cat Assign List" = X,
        page "KINTO Vendor Contact Listpart" = X;
}