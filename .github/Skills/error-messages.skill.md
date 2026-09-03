---
name: error-messages
description: Gerar e melhorar mensagens de error em AL seguindo o standard de heinrik Helgesen - um bom error diz o que aconteceu, porque aconteceu, e o que deve fazer para sanar o error.
Usar sempre que se criar e revisar uma chamada de error() em codigo AL.
---
# Erro de massagem padrão (AL)

Toda mensagem de erro deve responder a três perguntas, nesta ordem:

1. **O que aconteceu** - o evento específico, sem jargões técnicos ou nomes de variáveis ​​internas.
2. **Por que aconteceu** - a causa, desde que possa ser determinada pelo contexto (outro campo, um estado, uma configuração).
3. **O que fazer** - uma ação específica que o usuário pode realizar ou o caminho para resolver o problema (qual campo verificar, qual página abrir).

## Formatação Recomendada

Use 'ErrorInfo' sempre que possível para adicionar um título e uma ação de navegação:

'''al
    var
    ErrorInfo: ErrorInfo;

    begin
        ErrorInfo.Title := '<O que aconteceu, em poucas palavras>';
        ErrorInfo.Message := '<Por que isso aconteceu, em uma frase>. ,O que fazer, em uma frase>.;
        ErrorInfo.AddAction('<texto da ação>.), Codeunit::"Codeunit a ser executada>", '<Procedimento>');
        Error(ErrorInfo);

    end;

''' Se 'ErrorInfo' não for usado, a mensagem em texto simples ainda deve incluir todas as três partes em uma única frase clara, por exemplo:

> "A data de término (%1) é anterior à data de início (%2). Corrija a data de término antes de continuar."

## O que evitar

- Mensagens genéricas: "Erro inesperado", "Não foi possível processar", "Valor inválido".
- Mensagens que apenas repetem o nome técnico do campo sem explicar a causa.
- Mensagens que não indicam o que fazer em seguida.
- Códigos de erro ou exceções internas exibidos diretamente ao usuário.

## Lista de verificação antes de aceitar uma mensagem de erro

- [ ] Explique o que aconteceu em linguagem simples
- [ ] Explique o motivo, se a causa for conhecida
- [ ] Indique uma ação específica ou onde resolver o problema
- [ ] Evite jargões técnicos e nomes de variáveis ​​internas

## Regras
- Todas as mensagens de erro devem ser armazenadas em variáveis ​​Label, nunca codificadas diretamente no código
- Os rótulos de erro terminam com o sufixo 'Err'