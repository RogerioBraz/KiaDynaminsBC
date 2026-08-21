page 50165 "KINTO Item Version History"
{
    Caption = 'KINTO Item Version History';
    PageType = List;
    SourceTable = "KINTO Item Version History";
    ApplicationArea = All;
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Version No."; Rec."Version No.") { ApplicationArea = All; }
                field(Cost; Rec.Cost) { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field("Pricing Value"; Rec."Pricing Value") { ApplicationArea = All; }
                field("Active Start Date"; Rec."Active Start Date") { ApplicationArea = All; }
                field("Active End Date"; Rec."Active End Date") { ApplicationArea = All; }
                field("Created By"; Rec."Created By") { ApplicationArea = All; }
                field("Created DateTime"; Rec."Created DateTime") { ApplicationArea = All; }
            }
        }
    }
}
