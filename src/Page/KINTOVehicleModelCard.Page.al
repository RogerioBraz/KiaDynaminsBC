page 50139 "KINTO Vehicle Model Card"
{
    Caption = 'KINTO Vehicle Model';
    PageType = Card;
    SourceTable = "KINTO Vehicle Model";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Model No."; Rec."Model No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Manufacturer Code"; Rec."Manufacturer Code") { ApplicationArea = All; }
                field(Brand; Rec.Brand) { ApplicationArea = All; }
                field("Vehicle Type"; Rec."Vehicle Type") { ApplicationArea = All; }
                field("Fuel Type"; Rec."Fuel Type") { ApplicationArea = All; }
                field("Transmission Type"; Rec."Transmission Type") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
            group(Defaults)
            {
                Caption = 'Default Parameters';
                field("Default Usage Type"; Rec."Default Usage Type") { ApplicationArea = All; }
                field("Default Monthly Mileage"; Rec."Default Monthly Mileage") { ApplicationArea = All; }
                field("Default Contract Term"; Rec."Default Contract Term") { ApplicationArea = All; }
            }
        }
    }
}