page 50125 "KINTO RV Matrix API"
{
    Caption = 'KINTO RV Matrix API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'rvMatrixEntry';
    EntitySetName = 'rvMatrixEntries';
    SourceTable = "KINTO RV Matrix";
    DelayedInsert = true;
    ODataKeyFields = "Entry No.";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(entryNo; Rec."Entry No.") { ApplicationArea = All; }
                field(itemNo; Rec."Item No.") { ApplicationArea = All; }
                field(usageType; Rec."Usage Type") { ApplicationArea = All; }
                field(hasImplement; Rec."Has Implement") { ApplicationArea = All; }
                field(effectiveStartDate; Rec."Effective Start Date") { ApplicationArea = All; }
                field(maxMileage; Rec."Max Mileage") { ApplicationArea = All; }
                field(maxAge; Rec."Max Age") { ApplicationArea = All; }
                field(tabulatedAge; Rec."Tabulated Age") { ApplicationArea = All; }
                field(residualValuePct; Rec."Residual Value %") { ApplicationArea = All; }
                field(status; Rec."Status") { ApplicationArea = All; }
            }
        }
    }
}