page 50454 "KINTO Insurance Policy"
{
    Caption = 'Insurance Policy';
    PageType = Card;
    SourceTable = "KINTO Insurance Policy";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Policy No."; Rec."Policy No.") { ApplicationArea = All; }
                field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                field("Insurer Code"; Rec."Insurer Code") { ApplicationArea = All; }
                field("Policy Number (Ext.)"; Rec."Policy Number (Ext.)") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
            group(Conditions)
            {
                Caption = 'Conditions';
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Annual Premium"; Rec."Annual Premium") { ApplicationArea = All; }
                field("Monthly Cost"; Rec."Monthly Cost") { ApplicationArea = All; }
                field("Coverage Type"; Rec."Coverage Type") { ApplicationArea = All; }
                field("Deductible Amount"; Rec."Deductible Amount") { ApplicationArea = All; }
                field("Contract No."; Rec."Contract No.") { ApplicationArea = All; }
            }
        }
    }
}
