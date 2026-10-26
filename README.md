# KiaDynBC — NFMS

App AL para Dynamics 365 Business Central: gestão completa de frota e leasing veicular (KINTO) — da cotação à venda do usado, com comportamento por país (BR/AR) configurável.

## Estado (26/10/2026 — v1.1.0.7)

| Domínio | Escopo | Estado |
|---|---|---|
| D1 Manutenção | tickets, planos, pool, validação | ✅ |
| D2 Multas | ingestão, vínculo por data, 3 valores, SNE | ✅ |
| D3 Serviço + Seguro | tickets, apólices, sinistro 5 trilhas | ✅ |
| D4 Contratos | aditivos, renegociação, change log | ✅ |
| D5 Terminação | devolução, recovery, substituição, settlement, mileage closing | ✅ |
| D6 Billing | medição mensal, reajuste por índice, créditos (cap 2%) | ✅ |
| D7 Fleet Control | ledger, telemática, apólices, fechamento | ✅ |
| D8 Remarketing | precificação, cascata, 4-olhos, portal seminovos (3 TP) | ✅ |
| D9 Financeiro | contabilidade/ativo fixo | ⏳ aguardando IRM |
| NF-e | emissão BR | ⏳ com parceiro da localização |
| CNAB Itaú | integração bancária | ⏳ projeto separado |

**Testes:** 31 cenários E2E (app KiaDynBC-Test) + Demo Load 6 cenários.

## Estrutura

```
src/                  — app principal (AL)
Translations/         — XLIFF pt-BR (regenerar .g.xlf no build)
docs/                 — documentação do projeto (abaixo)
```

## Documentação (docs/)

| Arquivo | Conteúdo |
|---|---|
| `kiadynbc-manual-usuario-v1.docx` | **Manual de uso** — 12 seções: operação (cotação→remarketing), administração (config, jobs, integrações, permissões) e troubleshooting |
| `kiadynbc-apresentacao-v1.pptx` | **Apresentação** — 7 slides: problema, domínios, arquitetura, qualidade, roadmap |
| `escopo-kiadynbc-nfms.md` | Escopo completo D1-D8+DX1 vs. código (auditoria AlfaPeople/KINTO) |
| `desenho-tecnico-kiadynbc-nfms.md` | Desenho técnico: modelo de dados, engines, integrações |
| `fluxo-processo-kiadynbc-nfms.md` | Fluxo de processo ponta a ponta (quote→contract→billing→termination) |
| `guia-capturas-manual-v2.md` | URLs diretas das telas p/ capturar prints do manual v2 |

## Repositórios relacionados

- **KiaDynBC-Test** (github.com/RogerioBraz/KiaDynBC-Test) — app de testes E2E: Harness (31 cenários), Test Management page, Demo Data Seed/Load

## Convenções de desenvolvimento

- **Ranges de ID**: novos objetos do main **nunca** em 50150-50190 nem 50420-50430 (território do test app). Fases novas: codeunits ≥ 50208, tables/pages ≥ 50477.
- **Varredura de IDs**: sempre intra-app completa (todos os tipos), além de main↔test.
- **No. Series**: setar antes do Insert (OnInsert só atribui se série <> '').
- **TryFunction**: sem valor de retorno (sucesso implícito no `if Try...`).
- **Captions**: obrigatórios em todos os fields/enum values (TranslationFile ativo).
- **Traduções**: XLIFF pt-BR desatualizado (02/09) — regenerar .g.xlf no build antes de traduzir.

## Build & Deploy

1. Abrir a pasta do app no VS Code (compilador pega todos os .al sob o app.json)
2. Compilar (F5) — regenera o .g.xlf (feature TranslationFile)
3. Publicar no ambiente (Dev/CoreSetup)
4. Testes: página "KINTO Test Management" → Run All Tests (esperado 31/31)
