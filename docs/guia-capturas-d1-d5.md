# Guia de captura — telas D1–D5 (manual v7)

**Status: 14 de 16 telas capturadas.** Faltam duas.

| # | Tela | Page ID | Status |
|---|---|---|---|
| 1 | KINTO Contract Clause List | 60003 | ✅ 21-clausulas-lista.png |
| 2 | KINTO Contract Clause Card | 60004 | ✅ 22-clausula-card.png |
| 3 | KINTO Service Level List | 60015 | ✅ 23-sla-lista.png |
| 4 | KINTO Service Level Card | 60016 | ✅ 24-sla-card.png |
| 5 | KINTO SLA Violation List | 60012 | ⬜ falta |
| 6 | KINTO Vehicle Downtime List | 60009 | ✅ 26-downtime-lista.png |
| 7 | KINTO Ticket Subtask List | 60011 | ✅ 27-subtarefas.png |
| 8 | KINTO Vehicle Document List | 60008 | ✅ 28-documentos-veiculo.png |
| 9 | KINTO Contract Evaluation List | 60005 | ✅ 29-avaliacao-lista.png |
| 10 | KINTO Contract Evaluation Card | 60006 | ✅ 30-avaliacao-card.png |
| 11 | KINTO Pre-Closure List | 60013 | ✅ 31-prefechamento-lista.png |
| 12 | KINTO Pre-Closure Card | 60014 | ✅ 32-prefechamento-card.png |
| 13 | KINTO Vendor Labor Rate List | 60000 | ✅ 33-hh-rate-lista.png |
| 14 | KINTO Vendor Labor Rate Card | 60002 | ✅ 34-hh-rate-card.png |
| 15 | KINTO Telematic Event List | 60001 | ✅ 35-eventos-telematicos.png |
| 16 | KINTO Contract Expiry Log List | 60007 | ⬜ falta |

> **Atenção:** a numeração de páginas mudou na 1.2.0.2. O Service Level Card saiu de
> 60010 para **60016** (eliminando a colisão com a tabela 60010) e foi criada a
> **60017 KINTO SLA Violation Card**. Use a coluna Page ID acima, que já está atualizada.

## As duas que faltam

### 5 — KINTO SLA Violation List (60012)

Ficou de fora porque a página quebrava ao abrir o registro. **Corrigida na 1.2.0.2** (card próprio 60017 e fim da colisão de número com a 60010). Publique a 1.2.0.2 ou superior e capture:

`.../Dev?company=CoreSetup&page=60012` → salvar como `25-sla-violacoes.png`

Se a lista estiver vazia, rode **Run D1-D5 Seed** antes.

### 16 — KINTO Contract Expiry Log List (60007)

`.../Dev?company=CoreSetup&page=60007` → salvar como `36-log-expiracao.png`

A lista só tem conteúdo depois que a rotina de ciclo de vida roda com contratos perto do vencimento. Se sair vazia, capture mesmo assim com os filtros visíveis — serve de referência da tela.

## Depois das duas capturas

O script `docs/build-manual-v7.py` já tem todos os blocos `img()` posicionados. Solte os dois arquivos com os nomes acima em `artifacts/kiadyn-manual-v2-imgs/`, adicione as duas linhas `img()` nos capítulos 17.2 e 22.3, e regenere. Se preferir, me mande as duas imagens que eu faço a inserção.

## Correção que afeta uma captura já feita

A tela de **Indisponibilidade** (`26-downtime-lista.png`) foi capturada **antes** da 1.2.0.3. Nela, "Dias Perdidos" aparece inflado 1.000×: uma parada de 7 minutos está marcada como **5 dias**. Recapture depois de publicar a 1.2.0.3 e rodar o seed. A legenda no manual já está correta; a imagem é que mostra o valor antigo.
