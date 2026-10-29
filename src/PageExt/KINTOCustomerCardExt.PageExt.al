pageextension 50100 "KINTO Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            group(KINTO)
            {
                Caption = 'KINTO';
                Visible = true;

                field("KINTO Customer Type"; Rec."KINTO Customer Type")
                {
                    ApplicationArea = All;
                }
                field("KINTO Credit Score"; Rec."KINTO Credit Score")
                {
                    ApplicationArea = All;
                }
                field("KINTO Credit Risk Override %"; Rec."KINTO Credit Risk Override %")
                {
                    ApplicationArea = All;
                }
                field("KINTO Eligible for reKINTO"; Rec."KINTO Eligible for reKINTO")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            group(KINTOLocation)
            {
                Caption = 'KINTO — Localização';
                Image = Address;

                action(KINTOFillFromCep)
                {
                    Caption = 'Preencher endereço pelo CEP';
                    ApplicationArea = All;
                    Image = Post;
                    ToolTip = 'Consulta o CEP na base local (carregada) e preenche endereço, cidade, UF e bairro.';

                    trigger OnAction()
                    var
                        PostCode: Record "Post Code";
                        Loader: Codeunit "KINTO CEP Loader";
                        Cep: Text;
                    begin
                        Cep := Rec."Post Code";
                        if Cep = '' then
                            Error(NoCepErr);
                        Cep := OnlyDigits(Cep);

                        PostCode.SetRange(Code, CopyStr(Cep, 1, 20));
                        if not PostCode.FindFirst() then begin
                            if not Confirm(CreateConfirm, false) then
                                exit;
                            if not Loader.LookupAndCreate(Cep) then
                                exit;
                            PostCode.SetRange(Code, CopyStr(Cep, 1, 20));
                            if not PostCode.FindFirst() then
                                exit;
                        end;

                        Rec.Address := CopyStr(PostCode."KINTO Street", 1, 100);
                        Rec."Post Code" := CopyStr(Cep, 1, 20);
                        Rec.City := CopyStr(PostCode.City, 1, 30);
                        Rec."County" := CopyStr(PostCode."KINTO Neighborhood", 1, 30);
                        Rec."Country/Region Code" := 'BR';
                        Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }

            }
        }
    }

    var
        NoCepErr: Label 'Preencha o campo CEP (Post Code) antes de consultar.';
        CreateConfirm: Label 'CEP %1 não está na base local. Consultar na API pública e incluir?';

    local procedure OnlyDigits(V: Text): Text
    var
        I: Integer;
        C: Text[1];
        Out: Text;
    begin
        Out := '';
        for I := 1 to StrLen(V) do begin
            C := CopyStr(V, I, 1);
            if (C >= '0') and (C <= '9') then
                Out := Out + C;
        end;
        exit(Out);
    end;
}