page 50455 "KINTO Insurance Policy List"
{
    Caption = 'Insurance Policies';
    PageType = List;
    SourceTable = "KINTO Insurance Policy";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Insurance Policy";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Policy No."; Rec."Policy No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Insurer Code"; Rec."Insurer Code") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Monthly Cost"; Rec."Monthly Cost") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
            }
        }
    }
}
