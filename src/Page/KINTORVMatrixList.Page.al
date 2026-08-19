page 50101 "KINTO RV Matrix List"
{
    Caption = 'KINTO Residual Value Matrix';
    PageType = List;
    SourceTable = "KINTO RV Matrix";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "KINTO RV Matrix Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Usage Type"; Rec."Usage Type") { ApplicationArea = All; }
                field("Has Implement"; Rec."Has Implement") { ApplicationArea = All; }
                field("Effective Start Date"; Rec."Effective Start Date") { ApplicationArea = All; }
                field("Max Mileage"; Rec."Max Mileage") { ApplicationArea = All; }
                field("Max Age"; Rec."Max Age") { ApplicationArea = All; }
                field("Tabulated Age"; Rec."Tabulated Age") { ApplicationArea = All; }
                field("Residual Value %"; Rec."Residual Value %") { ApplicationArea = All; }
                field("Status"; Rec."Status") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportExcel)
            {
                Caption = 'Import from Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                trigger OnAction()
                begin
                    // Excel import logic — to be implemented with Excel Buffer
                    Message('Excel import — implement with Excel Buffer table');
                end;
            }
        }
    }
}
