page 60015 "KINTO Service Level List"
{
    Caption = 'Service Level Agreements';
    PageType = List;
    SourceTable = "KINTO Service Level";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Service Level Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("SLA Profile"; Rec."SLA Profile") { ApplicationArea = All; }
                field("Response Time (hours)"; Rec."Response Time (hours)") { ApplicationArea = All; }
                field("Resolution Time (hours)"; Rec."Resolution Time (hours)") { ApplicationArea = All; }
                field("Max Downtime Days/Year"; Rec."Max Downtime Days/Year") { ApplicationArea = All; }
                field("Availability Target %"; Rec."Availability Target %") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}
