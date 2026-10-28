page 60012 "KINTO SLA Violation List"
{
    Caption = 'SLA Violations';
    PageType = List;
    SourceTable = "KINTO SLA Violation";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    CardPageId = "KINTO SLA Violation Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Detected DateTime"; Rec."Detected DateTime") { ApplicationArea = All; }
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Violation Type"; Rec."Violation Type") { ApplicationArea = All; }
                field("Hours Elapsed"; Rec."Hours Elapsed") { ApplicationArea = All; }
                field("SLA Target Hours"; Rec."SLA Target Hours") { ApplicationArea = All; }
                field("Penalty Amount"; Rec."Penalty Amount") { ApplicationArea = All; }
            }
        }
    }
}
