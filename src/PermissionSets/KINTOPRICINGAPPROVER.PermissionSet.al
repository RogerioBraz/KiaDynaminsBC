permissionset 50102 "KINTOPRICINGAPPROVER"
{
    Caption = 'KINTO Pricing - Approver';
    Assignable = true;

    Permissions =
        table "KINTO Country Setup" = X,
        table "KINTO Vehicle Model" = X,
        table "KINTO Inventory Vehicle" = X,
        table "KINTO RV Matrix" = X,
        table "KINTO CF Component" = X,
        table "KINTO Quote Header" = X,
        table "KINTO Quote Item" = X,
        table "KINTO Cash Flow Header" = X,
        table "KINTO Cash Flow Data" = X,
        table "KINTO Simulation Snapshot" = X,
        table "KINTO Maintenance Plan Header" = X,
        table "KINTO Maintenance Plan Line" = X,
        table "KINTO Approval Request" = X,
        codeunit "KINTO Pricing Engine Mgt." = X,
        page "KINTO Quote Card" = X,
        page "KINTO Quote List" = X,
        page "KINTO Cash Flow Data List" = X,
        page "KINTO Snapshot Card" = X,
        page "KINTO Approval Request List" = X,
        page "KINTO Approval Request Card" = X,
        page "KINTO Pricing Role Center" = X;
}