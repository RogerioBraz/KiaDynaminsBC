page 50143 "KINTO Approval Activities"
{
    Caption = 'Aprovações';
    PageType = CardPart;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            cuegroup(Approvals)
            {
                Caption = 'Aprovações Pendentes';

                actions
                {
                    action(PendingApprovals)
                    {
                        Caption = 'Aprovações Pendentes';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            ApprovalReq: Record "KINTO Approval Request";
                        begin
                            ApprovalReq.SetRange(Status, ApprovalReq.Status::Pending);
                            Page.Run(Page::"KINTO Approval Request List", ApprovalReq);
                        end;
                    }
                    action(NonStandardPending)
                    {
                        Caption = 'Non-Standard Pendentes';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            ApprovalReq: Record "KINTO Approval Request";
                        begin
                            ApprovalReq.SetRange(Status, ApprovalReq.Status::Pending);
                            ApprovalReq.SetRange(Classification, ApprovalReq.Classification::"Non-Standard");
                            Page.Run(Page::"KINTO Approval Request List", ApprovalReq);
                        end;
                    }
                }
            }
            cuegroup(Vehicles)
            {
                Caption = 'Veículos';

                actions
                {
                    action(AvailableVehicles)
                    {
                        Caption = 'Veículos Disponíveis';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            InventoryVehicle: Record "KINTO Inventory Vehicle";
                        begin
                            InventoryVehicle.SetRange(Status, InventoryVehicle.Status::Available);
                            Page.Run(Page::"KINTO Inventory Vehicle List", InventoryVehicle);
                        end;
                    }
                    action(SoftReservedVehicles)
                    {
                        Caption = 'Veículos Reservados';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            InventoryVehicle: Record "KINTO Inventory Vehicle";
                        begin
                            InventoryVehicle.SetRange(Status, InventoryVehicle.Status::"Soft Reserved");
                            Page.Run(Page::"KINTO Inventory Vehicle List", InventoryVehicle);
                        end;
                    }
                    action(ReturnedVehicles)
                    {
                        Caption = 'Veículos Devolvidos';
                        ApplicationArea = All;
                        trigger OnAction()
                        var
                            InventoryVehicle: Record "KINTO Inventory Vehicle";
                        begin
                            InventoryVehicle.SetRange(Status, InventoryVehicle.Status::Returned);
                            Page.Run(Page::"KINTO Inventory Vehicle List", InventoryVehicle);
                        end;
                    }
                }
            }

        }
    }
}