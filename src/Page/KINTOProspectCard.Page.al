page 60311 "KINTO Prospect Card"
{
    Caption = 'KINTO Prospect Card';
    PageType = Card;
    SourceTable = "KINTO Prospect";
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Prospect No."; Rec."Prospect No.") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Prospect Type"; Rec."Prospect Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Channel; Rec.Channel) { ApplicationArea = All; }
                field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; }
            }
            group(Tax)
            {
                Caption = 'Identification';
                field("Tax ID"; Rec."Tax ID") { ApplicationArea = All; }
                field("Tax ID Validation"; Rec."Tax ID Validation") { ApplicationArea = All; }
                field("Country Code"; Rec."Country Code") { ApplicationArea = All; }
                field("IBGE Code"; Rec."IBGE Code") { ApplicationArea = All; }
                field("Rural Producer"; Rec."Rural Producer") { ApplicationArea = All; }
            }
            group(Address)
            {
                Caption = 'Address';
                field(City; Rec.City) { ApplicationArea = All; }
                field(State; Rec.State) { ApplicationArea = All; }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Contact Name"; Rec."Contact Name") { ApplicationArea = All; }
                field("Contact Email"; Rec."Contact Email") { ApplicationArea = All; }
                field("Contact Phone"; Rec."Contact Phone") { ApplicationArea = All; }
            }
            group(Conversion)
            {
                Caption = 'Conversion';
                field("Converted Customer No."; Rec."Converted Customer No.") { ApplicationArea = All; }
                field("Converted Date"; Rec."Converted Date") { ApplicationArea = All; }
                field("ERP Registration Status"; Rec."ERP Registration Status") { ApplicationArea = All; }
            }
            group(Block)
            {
                Caption = 'Block';
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
                field("Block Reason"; Rec."Block Reason") { ApplicationArea = All; }
            }
            group(NotesGroup)
            {
                Caption = 'Notes';
                field(Notes; Rec.Notes) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConvertToCustomer)
            {
                Caption = 'Convert to Customer';
                ApplicationArea = All;
                Image = Move;
                trigger OnAction()
                var
                    Mgt: Codeunit "KINTO Prospect Management";
                    CustomerNo: Code[20];
                begin
                    if Rec."Prospect No." = '' then
                        exit;
                    CustomerNo := Mgt.ConvertToCustomer(Rec."Prospect No.");
                    Message('Customer %1 created from prospect %2.', CustomerNo, Rec."Prospect No.");
                    CurrPage.Update(false);
                end;
            }
            action(NewInteraction)
            {
                Caption = 'Log Interaction';
                ApplicationArea = All;
                Image = Notes;
                trigger OnAction()
                var
                    Interaction: Record "KINTO Interaction Log";
                begin
                    Interaction.Init();
                    Interaction."Prospect No." := Rec."Prospect No.";
                    Interaction."Interaction Date" := Today();
                    Interaction."Salesperson Code" := Rec."Salesperson Code";
                    Interaction."Contact Name" := Rec."Contact Name";
                    if Interaction.Insert(true) then begin
                        Message('Interaction %1 logged.', Interaction."Entry No.");
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
}
