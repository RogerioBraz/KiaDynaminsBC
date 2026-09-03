page 50113 "KINTO Cash Flow Data List"
{
    Caption = 'Cash Flow Data';
    PageType = List;
    SourceTable = "KINTO Cash Flow Data";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Quote No."; Rec."Quote No.") { ApplicationArea = All; }
                field("Quote Line No."; Rec."Quote Line No.") { ApplicationArea = All; }
                field("Month No."; Rec."Month No.") { ApplicationArea = All; }
                field("Month Date"; Rec."Month Date") { ApplicationArea = All; }
                field("Component ID"; Rec."Component ID") { ApplicationArea = All; }
                field("Component Description"; Rec."Component Description") { ApplicationArea = All; }
                field("Component Type"; Rec."Component Type") { ApplicationArea = All; }
                field("Amount"; Rec."Amount") { ApplicationArea = All; }
                field("Signed Amount"; Rec."Signed Amount") { ApplicationArea = All; }
                field("Accumulated Mileage"; Rec."Accumulated Mileage") { ApplicationArea = All; }
                field("Inflation Factor"; Rec."Inflation Factor") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewQuote)
            {
                Caption = 'Ver Cotação';
                ApplicationArea = All;
                Image = Document;
                trigger OnAction()
                var
                    QuoteHeader: Record "KINTO Quote Header";
                begin
                    if QuoteHeader.Get(Rec."Quote No.") then
                        Page.Run(Page::"KINTO Quote Card", QuoteHeader);
                end;
            }
            action(ViewSnapshot)
            {
                Caption = 'Ver Snapshot';
                ApplicationArea = All;
                Image = View;
                trigger OnAction()
                var
                    Snapshot: Record "KINTO Simulation Snapshot";
                begin
                    Snapshot.SetRange("Quote No.", Rec."Quote No.");
                    if Snapshot.FindFirst() then
                        Page.Run(Page::"KINTO Snapshot Card", Snapshot);
                end;
            }
        }
    }
}