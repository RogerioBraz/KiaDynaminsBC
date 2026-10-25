page 50301 "KINTO Traffic Fine List"
{
    Caption = 'KINTO Traffic Fines';
    PageType = List;
    SourceTable = "KINTO Traffic Fine";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "KINTO Traffic Fine Card";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Fine No."; Rec."Fine No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("License Plate"; Rec."License Plate") { ApplicationArea = All; }
                field("AIIP Code"; Rec."AIIP Code") { ApplicationArea = All; }
                field("Issuing Authority Code"; Rec."Issuing Authority Code") { ApplicationArea = All; }
                field("Infraction DateTime"; Rec."Infraction DateTime") { ApplicationArea = All; }
                field("Customer Amount"; Rec."Customer Amount") { ApplicationArea = All; }
                field("Vendor Amount"; Rec."Vendor Amount") { ApplicationArea = All; }
                field("Full Amount"; Rec."Full Amount") { ApplicationArea = All; }
                field("Link Status"; Rec."Link Status") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("Vendor Paid"; Rec."Vendor Paid") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LinkAllUnlinked)
            {
                Caption = 'Link All Unlinked Fines';
                ApplicationArea = All;
                Image = Link;
                trigger OnAction()
                var
                    FineMgt: Codeunit "KINTO Fine Management";
                    Linked: Integer;
                begin
                    Linked := FineMgt.LinkAllUnlinkedFines();
                    Message('%1 fine(s) linked.', Linked);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}