page 50212 "KINTO Extend Contract"
{
    Caption = 'Extend Contract';
    PageType = StandardDialog;
    SourceTable = "KINTO Vehicle Contract";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Extension)
            {
                Caption = 'Extension';
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; Editable = false; }
                field(CurrentEnd; Rec."Current End Date") { ApplicationArea = All; Caption = 'Current End Date'; Editable = false; }
                field(NewEnd; NewEndDate) { ApplicationArea = All; Caption = 'New End Date'; ShowMandatory = true; }
                field(Retention; WithRetention) { ApplicationArea = All; Caption = 'Retention Fee Indicated'; }
            }
        }
    }

    var
        NewEndDate: Date;
        WithRetention: Boolean;

    trigger OnOpenPage()
    begin
        NewEndDate := CalcDate('<CM+1M>', Rec."Current End Date");
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then begin
            Rec.Extend(NewEndDate, WithRetention);
            // Registra o aditivo
            InsertAmendment();
        end;
        exit(true);
    end;

    local procedure InsertAmendment()
    var
        Amendment: Record "KINTO Contract Amendment";
    begin
        Amendment.Init();
        Amendment."Contract No." := Rec."Contract No.";
        Amendment."Amendment No." := Rec."Amendment Count" + 1;
        Amendment."Amendment Type" := Amendment."Amendment Type"::Extension;
        Amendment."Effective Date" := Rec."Current End Date";
        Amendment."New End Date" := NewEndDate;
        Amendment."Retention Fee" := WithRetention;
        Amendment.Description := StrSubstNo('Extension to %1', NewEndDate);
        Amendment.Insert(true);
    end;
}