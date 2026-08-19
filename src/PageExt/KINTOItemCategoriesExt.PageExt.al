pageextension 50106 "KINTO Item Categories Ext" extends "Item Categories"
{
    actions
    {
        addfirst(processing)
        {
            action(KINTOCreateDefaultCategories)
            {
                Caption = 'Create KINTO Default Categories';
                ApplicationArea = All;
                Image = NewItem;

                trigger OnAction()
                var
                    ItemCategory: Record "Item Category";
                    KINTOCategories: List of [Text];
                    CatName: Text;
                begin
                    KINTOCategories.Add('Vehicle Base');
                    KINTOCategories.Add('Accessory');
                    KINTOCategories.Add('Optional');
                    KINTOCategories.Add('Implement');
                    KINTOCategories.Add('Maintenance Package');
                    KINTOCategories.Add('Insurance Package');
                    KINTOCategories.Add('Glass Coverage');
                    KINTOCategories.Add('24h Assistance');
                    KINTOCategories.Add('Pick-up and Delivery');
                    KINTOCategories.Add('Replacement Vehicle');
                    KINTOCategories.Add('Tires');

                    foreach CatName in KINTOCategories do begin
                        if not ItemCategory.Get(CopyStr(CatName, 1, 20)) then begin
                            ItemCategory.Init();
                            ItemCategory.Code := CopyStr(CatName, 1, 20);
                            ItemCategory.Description := CatName;
                            ItemCategory.Insert(true);
                        end;
                    end;

                    Message('KINTO default categories created/verified.');
                end;
            }
        }
    }
}