page 50475 "KINTO Task Templates"
{
    Caption = 'Task Templates';
    PageType = List;
    SourceTable = "KINTO Task Template";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Template Code"; Rec."Template Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Risk Level Filter"; Rec."Risk Level Filter") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateDefaultBR)
            {
                Caption = 'Create Default BR Template';
                ApplicationArea = All;
                Image = New;
                trigger OnAction()
                var
                    TaskChainMgt: Codeunit "KINTO Task Chain Mgt.";
                begin
                    TaskChainMgt.CreateDefaultTemplate();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
