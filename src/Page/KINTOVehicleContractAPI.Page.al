page 50189 "KINTO Vehicle Contract API"
{
    Caption = 'KINTO Vehicle Contracts';
    PageType = API;
    APIPublisher = 'kinto';
    APIGroup = 'pricing';
    APIVersion = 'v1.1';
    EntityName = 'vehicleContract';
    EntitySetName = 'vehicleContracts';
    SourceTable = "KINTO Vehicle Contract";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(contractNo; Rec."Contract No.") { ApplicationArea = All; }
                field(quoteNo; Rec."Quote No.") { ApplicationArea = All; }
                field(customerNo; Rec."Customer No.") { ApplicationArea = All; }
                field(status; Rec.Status) { ApplicationArea = All; }
                field(startDate; Rec."Start Date") { ApplicationArea = All; }
                field(currentEndDate; Rec."Current End Date") { ApplicationArea = All; }
                field(contractTerm; Rec."Contract Term (Months)") { ApplicationArea = All; }
                field(monthlyMileage; Rec."Monthly Mileage (km)") { ApplicationArea = All; }
                field(systemId; Rec.SystemId) { ApplicationArea = All; }
            }
        }
    }
}
