table 50205 "KINTO Billing Line"
{
    Caption = 'KINTO Billing Line';
    DataClassification = CustomerContent;
    LookupPageId = "KINTO Billing Line List";
    DrillDownPageId = "KINTO Billing Line List";

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "KINTO Vehicle Contract";
        }
        field(3; "Billing Month"; Date) { Caption = 'Billing Month'; }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(5; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            TableRelation = "KINTO Inventory Vehicle";
        }
        field(6; "Condition ID"; Code[20])
        {
            Caption = 'Condition ID';
            TableRelation = "KINTO Contract Condition"."Condition ID" where("Contract No." = field("Contract No."));
        }
        field(7; "Financial Product Code"; Code[20])
        {
            Caption = 'Financial Product Code';
            TableRelation = "KINTO Financial Product";
        }
        field(8; "Product Type"; Enum "KINTO Financial Product Type") { Caption = 'Product Type'; }
        field(9; Description; Text[100]) { Caption = 'Description'; }
        field(10; Quantity; Decimal) { Caption = 'Quantity'; DecimalPlaces = 0 : 2; InitValue = 1; }
        field(11; "Unit Price"; Decimal) { Caption = 'Unit Price'; DecimalPlaces = 2 : 2; }
        field(12; Amount; Decimal) { Caption = 'Amount'; DecimalPlaces = 2 : 2; }
        field(13; Status; Enum "KINTO Billing Status") { Caption = 'Status'; }
        field(14; "Sales Invoice No."; Code[20])
        {
            Caption = 'Sales Invoice No.';
            TableRelation = "Sales Invoice Header";
        }
        field(15; "Credit Memo No."; Code[20])
        {
            Caption = 'Credit Memo No.';
            TableRelation = "Sales Cr.Memo Header";
        }
        field(16; "Origin Ticket Type"; Enum "KINTO Termination Type") { Caption = 'Origin (reserved)'; Editable = false; }
        field(17; "Origin Description"; Text[100]) { Caption = 'Origin Description'; Editable = false; }
        field(18; "Approved By"; Code[50]) { Caption = 'Approved By'; Editable = false; }
        field(19; "Approved DateTime"; DateTime) { Caption = 'Approved DateTime'; Editable = false; }
        field(20; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(21; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(22; "Cost Center Code"; Code[20]) { Caption = 'Cost Center Code'; Editable = false; }
        field(23; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency; }
        field(24; "Billing Period From"; Date) { Caption = 'Billing Period From'; }
        field(25; "Billing Period To"; Date) { Caption = 'Billing Period To'; }
        field(26; "Days Billed"; Decimal) { Caption = 'Days Billed'; DecimalPlaces = 0 : 2; }
        field(27; "Prorated"; Boolean) { Caption = 'Prorated'; }
        field(28; "Reversal Of Entry No."; Integer) { Caption = 'Reversal Of Entry No.'; Editable = false; }
        field(29; "Cancellation Reason"; Text[250]) { Caption = 'Cancellation Reason'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Idx1; "Contract No.", "Billing Month") { }
        key(Idx2; Status) { }
        key(Idx3; "Customer No.", "Billing Month") { }
        key(Idx4; "Sales Invoice No.") { }
    }

    trigger OnInsert()
    var
        Contract: Record "KINTO Vehicle Contract";
    begin
        "Created By" := UserId;
        "Created DateTime" := CurrentDateTime;
        if Status = Status::Open then
            Status := Status::Open;

        if ("Customer No." = '') and Contract.Get("Contract No.") then begin
            "Customer No." := Contract."Customer No.";
            "Vehicle No." := Contract."Vehicle No.";
            "Cost Center Code" := Contract."Cost Center Code";
            "Currency Code" := Contract."Currency Code";
        end;
    end;

    procedure Approve()
    var
        NotOpenErr: Label 'Billing line %1 is not open.';
    begin
        if Status <> Status::Open then
            Error(NotOpenErr, "Entry No.");
        TestField(Amount);
        Status := Status::Approved;
        "Approved By" := UserId;
        "Approved DateTime" := CurrentDateTime;
        Modify(true);
    end;

    procedure Cancel(Reason: Text[250])
    var
        InvoicedErr: Label 'Billing line %1 is already invoiced — issue a credit memo instead.';
    begin
        if Status = Status::Invoiced then
            Error(InvoicedErr, "Entry No.");
        Status := Status::Cancelled;
        "Cancellation Reason" := Reason;
        Modify(true);
    end;
}