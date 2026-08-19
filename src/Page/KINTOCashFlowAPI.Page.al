page 50124 "KINTO Cash Flow API"
{
    Caption = 'KINTO Cash Flow API';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'cashFlowEntry';
    EntitySetName = 'cashFlowEntries';
    SourceTable = "KINTO Cash Flow Data";
    DelayedInsert = true;
    ODataKeyFields = "Quote No.", "Quote Line No.", "Month No.", "Component ID";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; }
                field(quoteLineNo; Rec."Quote Line No.") { ApplicationArea = All; }
                field(monthNo; Rec."Month No.") { ApplicationArea = All; }
                field(monthDate; Rec."Month Date") { ApplicationArea = All; }
                field(componentId; Rec."Component ID") { ApplicationArea = All; }
                field(componentDescription; Rec."Component Description") { ApplicationArea = All; }
                field(componentType; Rec."Component Type") { ApplicationArea = All; }
                field(amount; Rec."Amount") { ApplicationArea = All; }
                field(signedAmount; Rec."Signed Amount") { ApplicationArea = All; }
                field(accumulatedMileage; Rec."Accumulated Mileage") { ApplicationArea = All; }
                field(inflationFactor; Rec."Inflation Factor") { ApplicationArea = All; }
            }
        }
    }
}