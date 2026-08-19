page 50136 "KINTO Approval Request List"
{
    Caption = 'KINTO Approval Requests';
    PageType = List;
    SourceTable = "KINTO Approval Request";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Approval Request Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Request ID"; Rec."Request ID") { ApplicationArea = All; }
                field("Quote No."; Rec."Quote No.") { ApplicationArea = All; }
                field("Requester ID"; Rec."Requester ID") { ApplicationArea = All; }
                field("Approver ID"; Rec."Approver ID") { ApplicationArea = All; }
                field("Request DateTime"; Rec."Request DateTime") { ApplicationArea = All; }
                field("Approval DateTime"; Rec."Approval DateTime") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
                field("Classification"; Rec."Classification") { ApplicationArea = All; }
            }
        }
    }
}

