page 60016 "KINTO Service Level Card"
{
    Caption = 'Service Level Agreement';
    PageType = Card;
    SourceTable = "KINTO Service Level";
    UsageCategory = None;
    ApplicationArea = All;
    Editable = true;
    InsertAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("SLA Profile"; Rec."SLA Profile") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
            group(Times)
            {
                Caption = 'Times';
                field("Response Time (hours)"; Rec."Response Time (hours)") { ApplicationArea = All; }
                field("Resolution Time (hours)"; Rec."Resolution Time (hours)") { ApplicationArea = All; }
                field("Replacement Vehicle Hours"; Rec."Replacement Vehicle Hours") { ApplicationArea = All; }
                field("Max Downtime Days/Year"; Rec."Max Downtime Days/Year") { ApplicationArea = All; }
            }
            group(Penalties)
            {
                Caption = 'Penalties';
                field("Penalty Per Hour"; Rec."Penalty Per Hour") { ApplicationArea = All; }
                field("Penalty Cap %"; Rec."Penalty Cap %") { ApplicationArea = All; }
                field("Availability Target %"; Rec."Availability Target %") { ApplicationArea = All; }
            }
        }
    }
}
