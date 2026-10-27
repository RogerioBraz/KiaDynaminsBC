page 60014 "KINTO Pre-Closure Card"
{
    Caption = 'Pre-Closure';
    PageType = Card;
    SourceTable = "KINTO Pre-Closure";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Pre-Closure No."; Rec."Pre-Closure No.") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Planned Return Date"; Rec."Planned Return Date") { ApplicationArea = All; }
                field("Notice Sent Date"; Rec."Notice Sent Date") { ApplicationArea = All; }
            }
            group(Forecast)
            {
                Caption = 'Forecast';
                field("Odometer Forecast"; Rec."Odometer Forecast") { ApplicationArea = All; }
                field("Mileage Excess Forecast"; Rec."Mileage Excess Forecast") { ApplicationArea = All; }
                field("Estimated Excess Charge"; Rec."Estimated Excess Charge") { ApplicationArea = All; }
                field("Open Fines Count"; Rec."Open Fines Count") { ApplicationArea = All; }
                field("Open Billing Amount"; Rec."Open Billing Amount") { ApplicationArea = All; }
            }
            group(Closure)
            {
                Caption = 'Closure';
                field("Checklist Complete"; Rec."Checklist Complete") { ApplicationArea = All; }
                field("Return No."; Rec."Return No.") { ApplicationArea = All; }
                field(Notes; Rec.Notes) { ApplicationArea = All; MultiLine = true; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Recalculate)
            {
                Caption = 'Recalculate Forecast';
                ApplicationArea = All;
                Image = Refresh;
                trigger OnAction()
                begin
                    Rec.CalcForecasts();
                    Rec.Modify(true);
                    Message('Previsão recalculada.');
                end;
            }
            action(NotifyCustomer)
            {
                Caption = 'Register Notice Sent';
                ApplicationArea = All;
                Image = Send;
                trigger OnAction()
                begin
                    Rec."Notice Sent Date" := Today;
                    if Rec.Status = Rec.Status::Draft then
                        Rec.Status := Rec.Status::Notified;
                    Rec.Modify(true);
                    Message('Aviso registrado.');
                end;
            }
            action(ConvertToReturn)
            {
                Caption = 'Convert to Return';
                ApplicationArea = All;
                Image = Move;
                trigger OnAction()
                var
                    PreClosureMgt: Codeunit "KINTO Pre-Closure Mgt.";
                    ReturnNo: Code[20];
                begin
                    ReturnNo := PreClosureMgt.ConvertToReturn(Rec."Pre-Closure No.", Today);
                    if ReturnNo <> '' then begin
                        Rec.Get(Rec."Pre-Closure No.");
                        Message('Devolução %1 criada.', ReturnNo);
                    end;
                end;
            }
        }
    }
}
