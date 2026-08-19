page 50141 "KINTO Pricing Headline"
{
    Caption = 'KINTO Pricing Headline';
    PageType = HeadlinePart;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Headline1)
            {
                Visible = Headline1Visible;

                field(HeadlineText; Headline1Text)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                }
            }
            group(Headline2)
            {
                Visible = Headline2Visible;

                field(HeadlineText2; Headline2Text)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Headline1Text := 'Bem-vindo ao KINTO Pricing Engine';
        Headline2Text := 'Solução de precificação para locação de veículos no Dynamics 365 Business Central';
        Headline1Visible := true;
        Headline2Visible := true;
    end;

    var
        Headline1Text: Text;
        Headline2Text: Text;
        Headline1Visible: Boolean;
        Headline2Visible: Boolean;
}