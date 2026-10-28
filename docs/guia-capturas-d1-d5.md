# Guia de captura — telas D1–D5 (manual v7)

**Status em 28/10 10:05: 14 de 16 capturadas. Faltam 2, e 1 precisa ser refeita.**

## O que falta

| # | Tela | Page ID | Arquivo esperado | Situação |
|---|---|---|---|---|
| 5 | KINTO SLA Violation List | **60012** | `25-sla-violacoes.png` | ⬜ **falta** |
| 16 | KINTO Contract Expiry Log List | **60007** | `36-log-expiracao.png` | ⬜ **falta** |
| 6 | KINTO Vehicle Downtime List | 60009 | `26-downtime-lista.png` | ⚠️ **refazer** |

## O que já está pronto (14)

| # | Tela | Page ID | Arquivo |
|---|---|---|---|
| 1 | KINTO Contract Clause List | 60003 | `21-clausulas-lista.png` ✅ |
| 2 | KINTO Contract Clause Card | 60004 | `22-clausula-card.png` ✅ |
| 3 | KINTO Service Level List | 60015 | `23-sla-lista.png` ✅ |
| 4 | KINTO Service Level Card | **60016** | `24-sla-card.png` ✅ |
| 6 | KINTO Vehicle Downtime List | 60009 | `26-downtime-lista.png` ⚠️ refazer |
| 7 | KINTO Ticket Subtask List | 60011 | `27-subtarefas.png` ✅ |
| 8 | KINTO Vehicle Document List | 60008 | `28-documentos-veiculo.png` ✅ |
| 9 | KINTO Contract Evaluation List | 60005 | `29-avaliacao-lista.png` ✅ |
| 10 | KINTO Contract Evaluation Card | 60006 | `30-avaliacao-card.png` ✅ |
| 11 | KINTO Pre-Closure List | 60013 | `31-prefechamento-lista.png` ✅ |
| 12 | KINTO Pre-Closure Card | 60014 | `32-prefechamento-card.png` ✅ |
| 13 | KINTO Vendor Labor Rate List | 60000 | `33-hh-rate-lista.png` ✅ |
| 14 | KINTO Vendor Labor Rate Card | 60002 | `34-hh-rate-card.png` ✅ |
| 15 | KINTO Telematic Event List | 60001 | `35-eventos-telematicos.png` ✅ |

## Instruções para as três pendências

Publique **KiaDynBC 1.2.0.4** ou superior antes de capturar (a 1.2.0.4 adicionou a
ação que gera as violações e o seed que cria uma).

### 25 — SLA Violations (60012)

1. Publicar 1.2.0.4+
2. Página de testes → **Run D1-D5 Seed** (agora cria uma violação)
3. Abrir `.../Dev?company=CoreSetup&page=60012`
4. Se quiser mais linhas na tela, clicar em **Check SLA Violations** (ação nova)
5. Salvar como `25-sla-violacoes.png`

### 36 — Contract Expiry Log (60007)

O seed já grava duas entradas (Aviso Enviado e Avaliação Devida).

`.../Dev?company=CoreSetup&page=60007` → salvar como `36-log-expiracao.png`

### 26 — Downtime (60009) — refazer

A versão atual foi capturada com a 1.2.0.2, **antes** da correção dos dias perdidos.
Nela, uma parada de 27/07 08:00→08:07 aparece como "5 dias". Com a 1.2.0.4 o mesmo
registro fica correto (a parada em si é de minutos, então o valor será 0,00 — o que é
o resultado certo).

Para a captura ficar didática, o ideal é ter uma parada de alguns dias: o seed cria
duas — a encerrada (12 dias atrás, 08:00→17:00) e a aberta (ontem 14:00). Depois de
rodar o seed com a 1.2.0.4, os "Dias Perdidos" saem em 0,38 e 0 — números pequenos
porque as paradas do seed são curtas.

`.../Dev?company=CoreSetup&page=60009` → sobrescrever `26-downtime-lista.png`

## Depois de capturar

Soltar os arquivos em `artifacts/kiadyn-manual-v2-imgs/` e me avisar — eu insiro os
três `img()` que faltam no `docs/build-manual-v7.py` (capítulos 17.2, 22.3 e 18.1) e
regero o manual. Ou mande as três imagens aqui que eu faço tudo.
