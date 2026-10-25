page 50211 "KINTO Contract Change Log"
{
    Caption = 'KINTO Contract Change Log';
    PageType = List;
    SourceTable = "KINTO Contract Change Log";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Change Type"; Rec."Change Type") { ApplicationArea = All; }
                field("Change DateTime"; Rec."Change DateTime") { ApplicationArea = All; }
                field("Changed By"; Rec."Changed By") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}