page 50160 "KINTO Tire Package List"
{
    Caption = 'KINTO Tire Packages';
    PageType = List;
    SourceTable = "KINTO Tire Package";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Package ID"; Rec."Package ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Rim Size"; Rec."Rim Size") { ApplicationArea = All; }
                field("Aspect Ratio"; Rec."Aspect Ratio") { ApplicationArea = All; }
                field("Section Width"; Rec."Section Width") { ApplicationArea = All; }
                field("Cost per Tire"; Rec."Cost per Tire") { ApplicationArea = All; }
                field("Markup %"; Rec."Markup %") { ApplicationArea = All; }
                field("Default Quantity"; Rec."Default Quantity") { ApplicationArea = All; }
                field("Usage Type"; Rec."Usage Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}
