page 50451 "KINTO Telematic Device"
{
    Caption = 'Telematic Device';
    PageType = Card;
    SourceTable = "KINTO Telematic Device";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Device No."; Rec."Device No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Serial Number"; Rec."Serial Number") { ApplicationArea = All; }
                field("IMEI"; Rec."IMEI") { ApplicationArea = All; }
                field("Device Model"; Rec."Device Model") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
            group(Installation)
            {
                Caption = 'Installation';
                field("Installed Vehicle No."; Rec."Installed Vehicle No.") { ApplicationArea = All; }
                field("Install Date"; Rec."Install Date") { ApplicationArea = All; }
                field("Removal Date"; Rec."Removal Date") { ApplicationArea = All; }
                field("Install Count"; Rec."Install Count") { ApplicationArea = All; }
                field("Last Communication"; Rec."Last Communication") { ApplicationArea = All; }
            }
            group(Aging)
            {
                Caption = 'Aging';
                field("Aging Days"; Rec."Aging Days") { ApplicationArea = All; }
                field("Aging Charge Vendor"; Rec."Aging Charge Vendor") { ApplicationArea = All; Style = Attention; }
            }
            group(Plan)
            {
                Caption = 'Paid Plan';
                field("Paid Plan Code"; Rec."Paid Plan Code") { ApplicationArea = All; }
                field("Paid Plan Monthly Fee"; Rec."Paid Plan Monthly Fee") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InstallOnVehicle)
            {
                Caption = 'Install on Vehicle...';
                ApplicationArea = All;
                Image = Link;
                trigger OnAction()
                var
                    FleetMgt: Codeunit "KINTO Fleet Management";
                    VehicleNo: Code[20];
                    ContractNo: Code[20];
                begin
                    if Rec.Status <> Rec.Status::"In Stock" then
                        Error('Device is not in stock.');
                    if Page.RunModal(Page::"KINTO Inventory Vehicle List") = Action::LookupOK then begin
                        CurrPage.SetSelectionFilter(Rec); // placeholder — seleção real via dialog
                    end;
                end;
            }
            action(RemoveFromVehicle)
            {
                Caption = 'Remove from Vehicle';
                ApplicationArea = All;
                Image = Unlink;
                trigger OnAction()
                var
                    FleetMgt: Codeunit "KINTO Fleet Management";
                begin
                    FleetMgt.RemoveDevice(Rec."Device No.");
                    CurrPage.Update(true);
                end;
            }
        }
    }
}
