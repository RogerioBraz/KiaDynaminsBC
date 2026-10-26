page 50476 "KINTO Task Instances"
{
    Caption = 'Task Instances';
    PageType = List;
    SourceTable = "KINTO Task Instance";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Recovery Case No."; Rec."Recovery Case No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Step No."; Rec."Step No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Due Date"; Rec."Due Date") { ApplicationArea = All; }
                field(Completed; Rec.Completed) { ApplicationArea = All; StyleExpr = DoneStyle; }
                field("Completed Date"; Rec."Completed Date") { ApplicationArea = All; }
                field("Assigned To"; Rec."Assigned To") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CompleteTask)
            {
                Caption = 'Complete Task';
                ApplicationArea = All;
                Image = Approve;
                Editable = true;
                trigger OnAction()
                var
                    TaskChainMgt: Codeunit "KINTO Task Chain Mgt.";
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    TaskChainMgt.CompleteTask(Rec);
                    CurrPage.Update(true);
                end;
            }
        }
    }

    var
        DoneStyle: Text;

    trigger OnAfterGetRecord()
    begin
        if Rec.Completed then
            DoneStyle := 'Favorable'
        else
            DoneStyle := 'Standard';
    end;
}
