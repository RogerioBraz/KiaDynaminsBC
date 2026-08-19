table 50118 "KINTO Pricing Cue"
{
    Caption = 'KINTO Pricing Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; }

        // Cotações
        field(10; "Total Quotes"; Integer)
        {
            Caption = 'Total Quotes';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Quote Header");
        }
        field(11; "Draft Quotes"; Integer)
        {
            Caption = 'Draft Quotes';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Quote Header" where("Pricing Status" = const(Draft)));
        }
        field(12; "Calculated Quotes"; Integer)
        {
            Caption = 'Calculated Quotes';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Quote Header" where("Pricing Status" = const(Calculated)));
        }
        field(13; "Pre-Approved Quotes"; Integer)
        {
            Caption = 'Pre-Approved Quotes';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Quote Header" where("Pricing Status" = const("Pre-Approved")));
        }
        field(14; "Approved Quotes"; Integer)
        {
            Caption = 'Approved Quotes';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Quote Header" where("Pricing Status" = const(Approved)));
        }
        field(15; "Error Quotes"; Integer)
        {
            Caption = 'Error Quotes';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Quote Header" where("Pricing Status" = const(Error)));
        }
        field(16; "Non-Standard Quotes"; Integer)
        {
            Caption = 'Non-Standard Quotes';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Quote Header" where("Approval Classification" = const("Non-Standard")));
        }

        // Aprovações
        field(20; "Pending Approvals"; Integer)
        {
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Approval Request" where(Status = const(Pending)));
        }
        field(21; "Non-Standard Pending"; Integer)
        {
            Caption = 'Non-Standard Pending';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Approval Request" where(Status = const(Pending), Classification = const("Non-Standard")));
        }

        // Veículos
        field(30; "Available Vehicles"; Integer)
        {
            Caption = 'Available Vehicles';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Inventory Vehicle" where(Status = const(Available)));
        }
        field(31; "Soft Reserved Vehicles"; Integer)
        {
            Caption = 'Soft Reserved Vehicles';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Inventory Vehicle" where(Status = const("Soft Reserved")));
        }
        field(32; "In Contract Vehicles"; Integer)
        {
            Caption = 'In Contract Vehicles';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Inventory Vehicle" where(Status = const("In Contract")));
        }
        field(33; "Returned Vehicles"; Integer)
        {
            Caption = 'Returned Vehicles';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Inventory Vehicle" where(Status = const(Returned)));
        }
        field(34; "Used Vehicles"; Integer)
        {
            Caption = 'Used Vehicles';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Inventory Vehicle" where("Vehicle Condition" = const(Used)));
        }

        // Snapshots
        field(40; "Total Snapshots"; Integer)
        {
            Caption = 'Total Snapshots';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Simulation Snapshot");
        }

        // RV Matrix
        field(50; "Active RV Entries"; Integer)
        {
            Caption = 'Active RV Matrix Entries';
            FieldClass = FlowField;
            CalcFormula = count("KINTO RV Matrix" where(Status = const(Active)));
        }

        // Maintenance Plans
        field(60; "Active Maint. Plans"; Integer)
        {
            Caption = 'Active Maintenance Plans';
            FieldClass = FlowField;
            CalcFormula = count("KINTO Maintenance Plan Header" where(Status = const(Active)));
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetSingleInstance()
    begin
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;

    procedure UpdateCues()
    begin
        GetSingleInstance();
        CalcFields(
            "Total Quotes", "Draft Quotes", "Calculated Quotes",
            "Pre-Approved Quotes", "Approved Quotes", "Error Quotes",
            "Non-Standard Quotes",
            "Pending Approvals", "Non-Standard Pending",
            "Available Vehicles", "Soft Reserved Vehicles",
            "In Contract Vehicles", "Returned Vehicles", "Used Vehicles",
            "Total Snapshots", "Active RV Entries", "Active Maint. Plans"
        );
    end;
}