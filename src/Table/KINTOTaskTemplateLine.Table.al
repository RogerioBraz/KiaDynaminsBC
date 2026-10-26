table 50467 "KINTO Task Template Line"
{
    Caption = 'KINTO Task Template Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "KINTO Task Template";
        }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Step No."; Integer) { Caption = 'Step (order)'; }
        field(4; Description; Text[100]) { Caption = 'Task Description'; }
        field(5; "Days After Previous"; Integer) { Caption = 'Days After Previous Step'; InitValue = 3; }
        field(6; "Task Type"; Option) { Caption = 'Task Type'; OptionMembers = Notification,Call,Visit,Legal; }
        field(7; "Assigned To"; Code[50]) { Caption = 'Assigned To'; }
    }

    keys
    {
        key(PK; "Template Code", "Line No.") { Clustered = true; }
        key(Idx1; "Template Code", "Step No.") { }
    }
}
