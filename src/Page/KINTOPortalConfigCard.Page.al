page 50482 "KINTO Portal Config"
{
    Caption = 'Portal Config (Seminovos)';
    PageType = Card;
    SourceTable = "KINTO Portal Config";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Enabled; Rec.Enabled) { ApplicationArea = All; }
            }
            group(Connection)
            {
                Caption = 'Connection';
                field("Endpoint URL"; Rec."Endpoint URL") { ApplicationArea = All; }
                field("API Key"; Rec."API Key") { ApplicationArea = All; ExtendedDatatype = Masked; }
            }
            group(Batch)
            {
                Caption = 'Batch & Retry';
                field("Availability Batch Size"; Rec."Availability Batch Size") { ApplicationArea = All; }
                field("Max Retry"; Rec."Max Retry") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetConfig();
        Rec.InsertIfMissing();
    end;
}
