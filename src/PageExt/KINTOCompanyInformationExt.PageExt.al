pageextension 50110 "KINTO Company Information Ext" extends "Company Information"
{
    layout
    {
        addlast(General)
        {
            field("KINTO Country Code"; Rec."KINTO Country Code")
            {
                ApplicationArea = All;
                ToolTip = 'País do KINTO usado por esta empresa. Define qual KINTO Country Setup os processos usam (séries, impostos, limites de cálculo).';
            }
        }
    }
}
