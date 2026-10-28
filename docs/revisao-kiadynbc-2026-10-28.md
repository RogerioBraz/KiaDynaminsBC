# Revisão KiaDynBC 1.2.0.5 — lacunas de escopo, setup e fórmulas

**Data:** 28/10/2026 · **Base:** 1.2.0.5 (Dev / CoreSetup) · **Método:** análise estática do código publicado + revalidação numérica das fórmulas

---

## Resumo executivo

| Frente | Resultado |
|---|---|
| Campos de setup | **1** sem tela (corrigido na 1.2.0.6) |
| Rotinas de negócio inalcançáveis | **7** — três delas de cobrança/ciclo de vida |
| Campos de precificação fora de tela | **5** no contrato |
| Tabelas sem página | **7** (2 legítimas como filhas, 5 sem uso) |
| Fórmulas | **13 conferidas, 0 divergências** |

O sistema calcula corretamente o que está ligado. O problema não é a conta — é o que **não chega a ser cobrado** porque nenhuma rotina chama o cálculo.

---

## 1. Rotinas implementadas que nunca rodam

Nenhuma destas tem chamada de página, de Job Queue ou de outro codeunit. O código existe, está testado no E2E — e é inalcançável em produção.

| Rotina | Onde | O que deveria fazer | Impacto |
|---|---|---|---|
| `RunContractLifecycle` | Codeunit 60001 | Varre contratos por vencimento: aviso prévio, expiração, renovação, log | **Alto** — sem aviso e sem renovação automática. O Log de Expiração só tem o que o seed criou |
| `GeneratePreventiveTickets` | Codeunit 60000 | Abre tickets preventivos por km e por tempo | **Alto** — manutenção preventiva nunca dispara |
| `GenerateRetentionFee` | Codeunit 50201 | Cobra a taxa de retenção mensal | **Alto** — receita não faturada |
| `GenerateRescissionFee` | Codeunit 50201 | Cobra a rescisória no cancelamento antecipado | **Alto** — receita não faturada |
| `CheckErpRegistration` | Codeunit | Valida cadastro no ERP e aplica bloqueio (PEN-01) | Médio |
| `GenerateAgingCharges` | Codeunit | Existe ação na tela — **ok** | — |
| `ProcessTelematicEvents` | Codeunit | Existe ação na tela — **ok** | — |

### As três primeiras são as que mais pesam

`RunContractLifecycle` e `GeneratePreventiveTickets` estão descritas no manual (capítulos 16.1 e 22.3) como rodando "pelo Job Queue". **Não existe entrada de Job Queue para elas.** O manual descreve um comportamento que não acontece.

`GenerateRetentionFee` e `GenerateRescissionFee` são piores: o **toggle "Retention Fee Indicated" está na tela do contrato**, o usuário marca, e nada é cobrado. A rescisória tem `%`, dias de isenção, tudo configurável — e nunca apura.

---

## 2. Campos de precificação sem tela no contrato

Existem na tabela, são usados no cálculo, e não aparecem em nenhuma página:

| Campo | Usado em | Consequência |
|---|---|---|
| `Excess Km Price (up to 10%)` | Cálculo do excesso de km | Não dá para definir a tarifa pela tela |
| `Excess Km Price (above 10%)` | Cálculo do excesso de km | idem |
| `Retention Fee Amount` | `GenerateRetentionFee` | Toggle visível, valor invisível |
| `Rescission Fee %` | `GenerateRescissionFee` | Percentual invisível |
| `Rescission Waiver Days` | `GenerateRescissionFee` | Isenção invisível |

Como o cap de km depende desses dois preços e eles não têm tela, na prática o excesso de quilometragem fica sempre limitado ao FIPE (ou zero, se o preço estiver em branco).

---

## 3. Campos de setup

Analisados 5 tabelas de setup/config, 126 campos:

| Tabela | Campos | Situação |
|---|---|---|
| KINTO Country Setup | 92 | `Prospect No. Series` sem tela → **corrigido** |
| KINTO Fine Fee Setup | 5 | `Fee Type` sem tela **e sem página para a tabela** |
| KINTO Termination Setup | 11 | ok |
| KINTO Remarketing Setup | 12 | ok |
| KINTO Portal Config | 6 | ok |

### `KINTO Fine Fee Setup` é o caso mais sério

A tabela não tem página nenhuma — e o `LookupPageId` dela aponta para `KINTO Issuing Authority List`, que é de **outra tabela**. É exatamente o mesmo defeito da página 60012 que quebrou na semana passada.

Na prática: a configuração de valores de multa por tipo (a base para calcular quanto cobrar do cliente) só existe via seed. Não há como manter.

---

## 4. Cláusulas contratuais — D4 incompleto

`KINTO Contract Clause Link` (tabela 60003) tem:
- snapshot do texto no `OnInsert`
- aceite do cliente com data e responsável
- permissão no permission set
- **descrição no manual, capítulo 19.2**

E não tem: página, nem uma única chamada no código. **Nenhum contrato consegue receber uma cláusula.** O capítulo 19.2 do manual descreve um vínculo que não existe.

A biblioteca de cláusulas (60003/60004) funciona — cadastra texto, categoria, país. Só o vínculo com o contrato que não.

---

## 5. Fórmulas — revalidadas, todas conferem

| # | Fórmula | Exemplo | Resultado |
|---|---|---|---|
| A.1 | Precificação (ROI, depreciação, custos) | — | ok |
| A.2 | Faturamento mensal | — | ok |
| A.3 | Excesso de km, 2 faixas + cap FIPE | franquia 24.000, excesso 5.000 → 2.400×1 + 2.600×2 | **7.600,00** ✓ |
| A.3b | idem, franquia 18.000 | 1.800×1 + 3.200×2 = 8.200, cap 5.000 | **5.000,00** ✓ |
| A.4 | Crédito de serviço, cap 2% | 30d × (15.858,60/30) = 15.858,60 → cap 317,17 | **317,17** ✓ |
| A.5 | Penalidade SLA, cap 1% | (48−24)×10 = 240 → cap 158,59 | **158,59** ✓ |
| A.5b | Acumulado no mês | 3 × 240,30 com cap 158,59 | **158,59** ✓ |
| A.6 | Reajuste com cap | IPCA 8% com cap 5% sobre 15.858,60 | **16.651,53** ✓ |
| A.9 | Encerramento | — | ok |
| A.10 | Avaliação (score) | — | ok |
| A.11 | Preventiva (intervalo) | — | ok |
| A.12 | HH rate | — | ok |
| A.13 | Resumo dos caps | — | ok |

**Nenhuma divergência.** As duas correções de unidade da semana (dias e horas) estão efetivas nos valores.

Observação: a fórmula A.3 está correta, mas **depende de dois campos sem tela** (§2). O cálculo certo sobre um preço que ninguém consegue digitar.

---

## 6. Recomendação de prioridade

| # | Ação | Esforço | Impacto |
|---|---|---|---|
| 1 | Job Queue para `RunContractLifecycle` | Baixo (1 wrapper) | Alto |
| 2 | Job Queue para `GeneratePreventiveTickets` | Baixo (1 wrapper) | Alto |
| 3 | Expor os 5 campos de precificação no contrato | Baixo (5 fields) | Alto |
| 4 | Ligar `GenerateRetentionFee` / `GenerateRescissionFee` ao faturamento | Médio | Alto (receita) |
| 5 | Página para `Fine Fee Setup` + corrigir LookupPageId | Baixo | Médio |
| 6 | Página e vínculo do `Contract Clause Link` | Médio | Médio |
| 7 | `CheckErpRegistration` no fluxo de prospect | Baixo | Médio |
| 8 | Remover tabelas mortas (`Supplier Group Assign`, `Item Supplier Group`) ou usá-las | Baixo | Baixo |

---

## O que não está claro

- **Se a KINTO pretende usar retenção e rescisória.** As duas têm regra de negócio escrita (RN-003/RN-004 do D6) e estão implementadas. Se a decisão for não usar, o certo é remover o toggle da tela — deixar um botão que não faz nada é pior que não ter.
- **Se o ciclo de vida deve rodar por Job Queue ou por ação manual.** O manual diz Job Queue; não há nenhuma das duas.
- **Se `Contract Clause Link` é escopo ativo ou foi abandonado.** A tabela tem lógica elaborada (snapshot, aceite) e zero uso — parece trabalho interrompido.
