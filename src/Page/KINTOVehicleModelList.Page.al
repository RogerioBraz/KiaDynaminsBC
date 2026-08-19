page 50138 "KINTO Vehicle Model List"
{
    Caption = 'KINTO Vehicle Models';
    PageType = List;
    SourceTable = "KINTO Vehicle Model";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO Vehicle Model Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Model No."; Rec."Model No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Manufacturer; Rec."Manufacturer Code") { ApplicationArea = All; }
                field(Brand; Rec.Brand) { ApplicationArea = All; }
                field("Vehicle Type"; Rec."Vehicle Type") { ApplicationArea = All; }
                field("Fuel Type"; Rec."Fuel Type") { ApplicationArea = All; }
                field("Transmission Type"; Rec."Transmission Type") { ApplicationArea = All; }
                field("Default Usage Type"; Rec."Default Usage Type") { ApplicationArea = All; }
                field("Default Monthly Mileage"; Rec."Default Monthly Mileage") { ApplicationArea = All; }
                field("Default Contract Term"; Rec."Default Contract Term") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
        }
    }
}

