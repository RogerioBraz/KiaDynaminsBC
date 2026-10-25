page 50210 "KINTO Contract Amendment List"
{
    Caption = 'KINTO Contract Amendments';
    PageType = List;
    SourceTable = "KINTO Contract Amendment";
    UsageCategory = Lists;
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; Editable = false; }
                field("Amendment No."; Rec."Amendment No.") { ApplicationArea = All; }
                field("Amendment Type"; Rec."Amendment Type") { ApplicationArea = All; }
                field("Effective Date"; Rec."Effective Date") { ApplicationArea = All; }
                field("New End Date"; Rec."New End Date") { ApplicationArea = All; }
                field("Retention Fee"; Rec."Retention Fee") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}