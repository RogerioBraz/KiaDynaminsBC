page 50472 "KINTO Substitution List"
{
    Caption = 'Contract Substitutions';
    PageType = List;
    SourceTable = "KINTO Contract Substitution";
    SourceTableView = sorting("Substitution No.") order(descending);
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Contract Substitution";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Substitution No."; Rec."Substitution No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Old Vehicle No."; Rec."Old Vehicle No.") { ApplicationArea = All; }
                field("New Vehicle No."; Rec."New Vehicle No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Request Date"; Rec."Request Date") { ApplicationArea = All; }
                field("Delivery Date"; Rec."Delivery Date") { ApplicationArea = All; }
                field("Is Provisional"; Rec."Is Provisional") { ApplicationArea = All; }
            }
        }
    }
}
