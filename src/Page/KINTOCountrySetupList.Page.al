page 50103 "KINTO Country Setup List"
{
    Caption = 'KINTO Country Setups';
    PageType = List;
    SourceTable = "KINTO Country Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    CardPageId = "KINTO Country Setup Card";

    // Um registro por pais (PK = Country Code). Cada empresa aponta para um
    // deles via Company Information -> KINTO Country.

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Pricing Methodology"; Rec."Pricing Methodology") { ApplicationArea = All; }
                field("National Revenue Tax %"; Rec."National Revenue Tax %") { ApplicationArea = All; }
                field("Default Inflation Index %"; Rec."Default Inflation Index %") { ApplicationArea = All; }
                field("Contract Series"; Rec."Contract Series") { ApplicationArea = All; }
                field("Ticket Series"; Rec."Ticket Series") { ApplicationArea = All; }
                field("Emergency Stop"; Rec."Emergency Stop") { ApplicationArea = All; }
            }
        }
    }
}
