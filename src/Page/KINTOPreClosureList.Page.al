page 60013 "KINTO Pre-Closure List"
{
    Caption = 'Pre-Closures';
    PageType = List;
    SourceTable = "KINTO Pre-Closure";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Pre-Closure Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Pre-Closure No."; Rec."Pre-Closure No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Planned Return Date"; Rec."Planned Return Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Notice Sent Date"; Rec."Notice Sent Date") { ApplicationArea = All; }
                field("Mileage Excess Forecast"; Rec."Mileage Excess Forecast") { ApplicationArea = All; }
                field("Estimated Excess Charge"; Rec."Estimated Excess Charge") { ApplicationArea = All; }
                field("Open Fines Count"; Rec."Open Fines Count") { ApplicationArea = All; }
                field("Open Billing Amount"; Rec."Open Billing Amount") { ApplicationArea = All; }
                field("Checklist Complete"; Rec."Checklist Complete") { ApplicationArea = All; }
            }
        }
    }
}
