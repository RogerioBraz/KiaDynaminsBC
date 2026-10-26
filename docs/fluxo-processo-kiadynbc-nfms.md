# KiaDynBC / NFMS — Fluxo do Processo (para validação do Rogerio)

**Data:** 26/10/2026 · **Estado:** Fases 0–5 implementadas · **App:** KiaDynBC v1.1.x (BC29, Essential, company CoreSetup/Dev)

Este documento descreve a **sequência de processos** implementada no app, do comercial ao pós-contrato, com os objetos BC de cada etapa e os pontos de decisão. Use as seções numeradas para validar a ordem; cada etapa indica o que já está funcional e o que depende de dados de setup.

---

## Visão geral (mapa de ponta a ponta)

```
[1] COTAÇÃO/PRICING ──► [2] APROVAÇÃO ──► [3] CONTRATO ──► [4] ATIVAÇÃO
        │                                                    │
        │                                                    ▼
        │                                          [5] BILLING MENSAL ──► [6] FATURA (Sales Invoice)
        │                                                    │
        ├──► [2b] CRÉDITOS RETROATIVOS ◄─────────────────────┤
        │                                                    │
        ▼                                                    ▼
[7] MANUTENÇÃO OPERACIONAL ──► [7b] COBRANÇA ADICIONAL      [8] MULTAS ──► [8b] COBRANÇA/RECONCILIAÇÃO
        │                                                    │
        ▼                                                    ▼
[9] TERMINAÇÃO ──► [9b] DEVOLUÇÃO/CHECKLIST ──► [9c] DANOS ──► [9d] COBRANÇA DANOS
        │
        ▼
[10] RECOVERY ──► (veículo devolvido ao estoque) ──► [11] REMARKETING (fase futura)
```

---

## 1. Cotação e Pricing (Fase comercial)

**Objetos:** `KINTO Quote Header` (50110) · `KINTO Quote Item` (50111) · `KINTO Pricing Engine Mgt.` · `KINTO Goal Seek Mgt.` · `KINTO Cash Flow Calculator` · `KINTO RV Matrix` · `KINTO Simulation Snapshot`

**Sequência:**
1. Cotação criada (via API `pricingWorkflows` ou página) — header herda Country Setup (metodologia, moeda, buffer de negociação)
2. Itens do veículo: modelo, termo (meses), km/mês, allowance, target ROI, MSRP/desconto
3. **Run Pricing** (comando via API ou botão):
   - Validações obrigatórias (item, MSRP, termo)
   - Parâmetros do país (inflação, spread, juros, depreciação fiscal, IPVA, risco de crédito)
   - **RV Matrix**: valor residual pela faixa de km projetado × idade
   - Depreciação de mercado → preço de revenda final
   - **Motor**: metodologia Target ROI (goal seek por bisseção sobre o cash flow) ou KINTO Fee
   - Cash flow ~20 componentes × mês (compra, tarifa inflacionada, PIS/COFINS, IPVA, seguro, telemática, SG&A, comissões, revenda…)
   - Indicadores: IRR (bisseção), ROI, EBT, PAT, FCF
   - Snapshot da simulação
4. Classificação de pré-aprovação: **Standard** vs **Non-Standard** (ROI < IRR de referência, buffer acima do sugerido, credit score D/E/F, allowance > 30 dias)

**Estado:** funcional. ⚠️ Dependência de dados: RV Matrix com faixas realistas (a atual tem 1 faixa: item 114743, 36.000 km/24 meses, RV 5%) e Country Setup BR revisado (custos mensais implícitos ~R$ 21,7k dominados por depreciação/juros — o goal seek para ROI 3,4% não converge com esses parâmetros).

---

## 2. Aprovação

**Objetos:** `KINTO Approval Request` (50114) · página `KINTO Approval Request Card` · comando `approveTrigger`

**Sequência:**
1. Standard → pré-aprovação automática (classificação do motor)
2. Non-Standard → workflow de alçada (request criado; aprovador decide)
3. Aprovado → `Pricing Status = Approved` (condição para criar contrato)

**Estado:** funcional via comando API e páginas. Workflow nativo de alçada (approvals do BC) é melhoria futura.

---

## 3. Contrato

**Objetos:** `KINTO Vehicle Contract` (50200) · `KINTO Contract Condition` · `KINTO Contract Amendment` · `KINTO Contract Change Log` · `KINTO Contract Billing Mgt.`

**Sequência:**
1. **Create Contract** (comando API ou action na cotação) — exige `Pricing Status = Approved`
2. Cria `Vehicle Contract` por placa + `Contract Condition` (Condition ID versionado) a partir dos itens aprovados
3. Veículo: `Inventory Vehicle` → In Contract; Fixed Asset atualizado (Booking/Residual/Last Contract)
4. Séries: C-00001 (contrato), CD-00001 (condição)

**Estado:** funcional.

## 4. Ativação

- `Activate` no contrato → Status = Active (com data de início)
- Extensão (`Extend`), renegociação e aditivos (`Amendment`) com versionamento de condição

**Estado:** funcional.

---

## 5. Billing mensal

**Objetos:** `KINTO Billing Line` (50300-range) · `KINTO Billing Job Queue` (50202) · `KINTO Financial Product` · `KINTO Price Index`

**Sequência:**
1. **Job Queue mensal** (ou comando `generateBilling`): varre contratos Active/Extended elegíveis no mês
2. Medição por **condição vigente na data** (Condition ID versionado): mês cheio = 30 dias; prorrata só na terminação
3. Gera `Billing Line` por condição × produto financeiro (RENT, pacotes, ADMIN-FEE…)
4. Idempotente por contrato/mês (não duplica)
5. Reajuste por índice (IPCA/IPC) na frequência da condição, com cap

**Estado:** funcional (job queue pronto para registrar no Job Queue Entry; comando API disponível).

## 6. Faturação

**Objetos:** `Sales Header`/`Sales Line` (item Type = Service) · `KINTO Financial Product` (Service Item No. por produto)

**Sequência:**
1. Aprovação das Billing Lines (`ApproveContractLines`)
2. **Invoice Approved Lines** → Sales Invoice agrupada por produto (RN-007: produto com `Separate Invoice` gera fatura própria)
3. Posting nativo da fatura

**Estado:** funcional (fatura individual testada em 25/10: invoice 102310 postada via API).

## 2b. Créditos retroativos

- `CreateCreditFromBillingLine` → Sales Credit Memo espelhando a fatura (status da linha → Credited, com motivo)
- Multas contratuais: `GenerateRetentionFee` (recorrente, indicação por placa) e `GenerateRescissionFee` (% sobre meses restantes, waiver de N dias)

---

## 7. Manutenção operacional

**Objetos:** `KINTO Maintenance Ticket` (50210) · `KINTO Maint Ticket Line` (50211) · `KINTO Pool Management` (50203) · `KINTO Maintenance Management` (50204) · Planos existentes 50115–50132

**Sequência:**
1. Ticket criado a partir do contrato (tipo preventivo/corretivo, placa, km/horas)
2. Ciclo: **Open → In Analysis → Pending Approval → Approved → In Execution → Pending Invoice → Closed** (Reject/Cancel restaura pool consumido — EXC-16)
3. **Validação nativa**: sequência de odômetro por placa (RN-013), linhas com valor, desvio vs preço padrão
4. **Pool Ledger**: consumo (dias carro reserva, pneus, km, monetário) com saldo compartilhável (RN-036); restauração em cancelamento
5. Pagamento ao dealer = Purchase nativo; **adicional ao cliente** = `BillTicketToCustomer` → Billing Line ADD-SERVICE → fatura separada

**Estado:** funcional (ciclo e cobrança; gatilho por telemática é integração futura).

---

## 8. Multas de trânsito

**Objetos:** `KINTO Traffic Fine` (50300) · `KINTO Fine Driver` (50301) · `KINTO Issuing Authority` (50302) · `KINTO Fine Fee Setup` (50303) · `KINTO Fine Provider` (50304) · `KINTO Fine Management` (50205)

**Sequência:**
1. **Ingestão** (provider pluggable: API BR / Excel AR) — multa com placa, órgão, AIIP, **data-hora da infração ≠ captura**, 3 valores (cliente/fornecedor/cheio)
2. **Vinculação** (`LinkFine` / lote): cruza pela **data da infração** com os contratos da placa; o mais recente que cobre a data vence; janela pós-contrato configurável por órgão (60d BR); herda SNE Adjustment % do órgão
3. **Ciclo legal BR**: Registered → Driver Indicated (NIC) → NIC Sent → Penalty Issued → Appealed/Paid
4. **Cobrança** (`BillFineToCustomer`): Billing Line FINE (valor cliente) + taxas por evento (boleto/envio/indicação do Fee Setup) → fatura separada
5. **Reconciliação**: `MarkVendorPaid` + status 4-estados (pendente/pago ao fornecedor/cobrado/reconciliado)
6. Cancelamento de multa faturada → crédito automático; apreensão + restrição de registro

**Estado:** funcional (ingestão manual/API; conector Mônaco/Geodefender é integração futura).

---

## 9. Terminação

**Objetos:** `KINTO Termination Management` (50206) · `KINTO Vehicle Return` (50400) · `KINTO Damage Line` (50401) · `KINTO Recovery Case` (50402) · `KINTO Termination Setup` (50403)

**Sequência:**
1. **Terminate** no contrato (tipo: End of Term, Early Cancellation, Total Loss, Theft, Vehicle Substitution, Sale to Driver) — inativa condições, veículo → Returned
2. **Total Loss/Theft**: veículo → Inactive (salvage) + recovery case automático
3. **Create Return** (exige contrato terminado; 1 return por contrato): data/local lat-long, odômetro/horas/combustível
4. **Checklist** + **laudo cautelar** + **Damage Lines** (classe garantia/má uso/desgaste/acidente; payer cliente/seguro/dealer/empresa; aprovação)
5. Finish Return → veículo ao estoque; pendências → status "With Pending Items"
6. **Cobranças**: danos do cliente → Billing Line DAMAGE (só aprovadas); pendências do dealer → Purchase Invoice

**Estado:** funcional.

## 10. Recovery

- Caso com **risco por aging** (15/45/90d configuráveis), bloqueio automático de alto risco com liberação explícita
- Job `ReclassifyOpenRecoveryCases` para reclassificar (pronto p/ Job Queue)
- Recovered → veículo volta ao estoque com odômetro/condição

---

## 11. Remarketing (Fase futura — D8)

Venda do usado: portal BR com 3 touchpoints, precificação mínimo+alvo, cascata de canais AR. **Não implementado** (Fase 6-8 do roadmap).

---

## Integração REST (o que existe hoje)

| Endpoint (api/kinto/pricing/v1.1) | Uso |
|---|---|
| `pricingCalculations` | CRUD de cotações (header) |
| `quoteItems` | Itens da cotação |
| `pricingWorkflows` | **Comandos**: `runPricingTrigger` / `approveTrigger` / `createContractTrigger` / `generateBillingTrigger` (PATCH true) + resultado espelhado |
| `cashFlowEntries` / `rvMatrixEntries` / `pricingValidations` / `approvalRequests` | Leitura |

**Padrão command:** PATCH `{"runPricingTrigger": true}` em `pricingWorkflows('00001')` → executa → resultado em `pricingStatus`/`calculatedMonthlyFee`/`createdContractNo`/`resultMessage` na mesma entidade.

---

## Pontos abertos para sua validação

1. **Ordem dos processos** — a sequência 1→10 reflete o desenho? Algo deveria ser paralelo?
2. **Aprovação** — Non-Standard deve usar workflow nativo do BC (approvals) ou manter o Approval Request custom?
3. **Billing** — job queue mensal roda no dia X? Quem aprova as linhas antes de faturar?
4. **Multas** — a janela pós-contrato de 60 dias e o SNE 60/80% por órgão batem com a operação?
5. **Terminação** — o laudo cautelar é obrigatório sempre (Setup controla) ou só em casos específicos?
6. **Setup pendente de dados**: RV Matrix (faixas realistas), Country Setup BR (custos), Fee Setup (valores das taxas), Damage Charge Account, Default Dealer Vendor.