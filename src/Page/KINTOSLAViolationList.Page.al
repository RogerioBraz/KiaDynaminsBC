page 60012 "KINTO SLA Violation List"
{
    Caption = 'SLA Violations';
    PageType = List;
    SourceTable = "KINTO SLA Violation";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    CardPageId = "KINTO SLA Violation Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Detected DateTime"; Rec."Detected DateTime") { ApplicationArea = All; }
                field("Ticket No."; Rec."Ticket No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Violation Type"; Rec."Violation Type") { ApplicationArea = All; }
                field("Hours Elapsed"; Rec."Hours Elapsed") { ApplicationArea = All; }
                field("SLA Target Hours"; Rec."SLA Target Hours") { ApplicationArea = All; }
                field("Penalty Amount"; Rec."Penalty Amount") { ApplicationArea = All; }
                field("Credit Created"; Rec."Credit Created") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CheckSLAViolations)
            {
                Caption = 'Check SLA Violations';
                ApplicationArea = All;
                Image = CheckList;
                ToolTip = 'Varre os tickets em aberto e em andamento e grava as violacoes de prazo do SLA.';

                trigger OnAction()
                var
                    DowntimeMgt: Codeunit "KINTO Downtime Mgt.";
                    Count: Integer;
                    Msg: Label 'Varredura concluida: %1 violacao(oes) de SLA registrada(s).';
                begin
                    Count := DowntimeMgt.CheckSLAViolations(Today());
                    Rec.Reset();
                    CurrPage.Update(false);
                    Message(Msg, Count);
                end;
            }
        }
    }
}
