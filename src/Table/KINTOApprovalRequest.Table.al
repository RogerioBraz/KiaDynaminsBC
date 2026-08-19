table 50117 "KINTO Approval Request"
{
    Caption = 'KINTO Approval Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Request ID"; Code[20]) { Caption = 'Request ID'; }
        field(2; "Quote No."; Code[20]) { Caption = 'Quote No.'; TableRelation = "KINTO Quote Header"; }
        field(3; "Requester ID"; Code[50]) { Caption = 'Requester ID'; }
        field(4; "Approver ID"; Code[50]) { Caption = 'Approver ID'; }
        field(5; "Request DateTime"; DateTime) { Caption = 'Request DateTime'; }
        field(6; "Approval DateTime"; DateTime) { Caption = 'Approval DateTime'; }
        field(7; "Status"; Option) { Caption = 'Status'; OptionMembers = Pending,Approved,Rejected,Cancelled; }
        field(8; "Classification"; Enum "KINTO Approval Classification") { Caption = 'Classification'; }
        field(9; "Comments"; Text[500]) { Caption = 'Comments'; }
        field(10; "Rejection Reason"; Text[250]) { Caption = 'Rejection Reason'; }
    }

    keys
    {
        key(PK; "Request ID") { Clustered = true; }
        key(Idx1; "Quote No.") { }
        key(Idx2; "Status") { }
    }

    trigger OnInsert()
    begin
        "Request DateTime" := CurrentDateTime;
        "Requester ID" := UserId;
        Status := Status::Pending;
    end;
}