# KiaDynBC / NFMS — Escopo e Entendimento da Solução
**Fleet Management System em Dynamics 365 Business Central · KINTO Mobility (Brasil + Argentina)**
*Documento de consolidação — 24/10/2026 · elaborado a partir de 17 especificações funcionais lidas + análise do código AL do repositório `RogerioBraz/KiaDynaminsBC`*

---

## 1. Contexto do projeto

| Item | Situação |
|---|---|
| **Produto** | NFMS — New Fleet Management System (KINTO Mobility) |
| **Objetivo** | Substituir o sistema atual (2ZFleet no Brasil; planilhas + OutSystems + SIAC na Argentina), preservando funcionalidades essenciais |
| **ERP** | **Business Central no Brasil; SAP na Argentina** (definição do próprio DX1) — o NFMS *é* o BC no BR |
| **Operação** | Locação de frota B2B (KINTO One) + compartilhada (KINTO Share) + B2C Car Subscription; ciclo do veículo da compra à venda |
| **Especificações** | Série D1–D9 + DX0–DX6 da AlfaPeople (FRD013–FRD031), convenção de rastreabilidade PP/SP/AG/SIS/REQ/RN/EXC/PEN, com sufixos BR/AR |
| **Regra de ouro** | "Processos, regras ou requisitos não expressamente registrados nos documentos **não fazem parte do escopo inicialmente precificado**" |
| **Padrão transversal** | Configuração por país (nunca modelo de dados diferente); eliminação de planilhas paralelas; trilha de auditoria sem deleção; workflows de aprovação configuráveis; integrações sempre via **Data Lake/middleware** (nunca direto no fornecedor) |

### Documentos recebidos — status de leitura

| Doc | Domínio | Versão | Status |
|---|---|---|---|
| D1 | Maintenance | v1.4 Revisado | ✅ lido |
| D2 | Traffic Fines | v1.5 Revisado | ✅ lido |
| D3 | Service Management (atendimento, seguros, sinistros, documentos, downtime) | v1.5 Revisado | ✅ lido |
| D4 | Contract Management | v1.5 Revisado | ✅ lido |
| D5 | Contract Termination | v1.5 Revisado | ✅ lido |
| D6 | Billing | v1.4 Comunizado | ✅ lido |
| D7 | Fleet Control / Inventory | v1.4 Revisado | ✅ lido |
| D8 | Remarketing | v1.4 Revisado | ✅ lido |
| D9 | Financeiro | v1.4 PTBR | ⛔ **bloqueado (IRM corporativo)** |
| DX0 | General Master Data | v1.0 | ⛔ bloqueado (IRM) |
| DX1 | Customer & Prospect Registration | v1.0 | ✅ lido |
| DX2 | Opportunity to Quotation | v1.0 | ⛔ bloqueado (IRM) |
| DX3 | Price Lists | v1.0 | ⛔ bloqueado (IRM) |
| DX4 | Pricing Engine | v1.0 | ⛔ bloqueado (IRM) |
| DX5 | Contract Creation | v1.0 | ⛔ bloqueado (IRM) |
| DX6 | Vehicle Purchase, Preparation & Delivery | v1.0 | ⛔ bloqueado (IRM) |

> ⛔ = protegidos por criptografia corporativa (Purview/IRM), não por senha — precisam ser reenviados desprotegidos ou abertos pela KINTO. **Os 7 bloqueados cobrem exatamente o ciclo comercial (DX0–DX6) e o financeiro (D9)** — justamente onde o código atual está mais maduro. As duplicatas "Comunizado" vs "Revisado" foram deduplicadas (prevaleceu a Revisado; D6 só tem Comunizado).

---

## 2. Visão fim a fim da solução

O ciclo de vida do **veículo** atravessa todos os domínios; o ciclo de vida do **contrato** é o eixo integrador:

```
DX1 Cliente/Prospect → DX2 Oportunidade → DX3/DX4 Pricing → DX5 Criação do Contrato
        ↓
DX6 Compra/Preparação/Entrega do veículo
        ↓
┌────────────────── CONTRATO ATIVO (por placa) ──────────────────┐
│  D6 Billing (medição mensal, reajuste, multas, faturamento)     │
│  D1 Maintenance (tickets, planos, validação, telemática)        │
│  D2 Multas (ingestão, vinculação, ciclo legal, cobrança)        │
│  D3 Atendimento/Seguros/Sinistros/Documentos/Downtime           │
│  D7 Fleet Control (inventário, dispositivos, fechamento AR)     │
│  D4 Mudanças contratuais (extensão, renegociação, renovação)    │
└─────────────────────────────────────────────────────────────────┘
        ↓
D5 Terminação (devolução, recuperação, substituição, settlement)
        ↓
D8 Remarketing (preparação, precificação, canais, venda, baixa)
        ↓
D9 Financeiro / contabilidade (BR no BC; AR no SAP)
```

**Modelo de dados central (o "espinha"):**
- **Customer/Prospect** (DX1) → hierarquia **master → sub-contrato (cost center/BU) → vehicle contract por placa** (D4 RN-033)
- **Vehicle Contract** (por placa, com data fim, status, saldos) — dono do vínculo cliente-veículo
- **Contract Line / Condition** com **Condition ID** versionado (D6 RN-013) — toda mudança comercial cria linha nova preservando a data de alta
- **Unidade/Veículo** (D7) com ownership, estados, histórico integral e por contrato
- **Pool/Saldo contratual** (dias de carro reserva, pneus, km, monetário) — consumido por D1/D3, restaurado em cancelamento (EXC-16/RN-043)
- **Billing Line** mensal por veículo×condição×cost center×produto financeiro (D6)

---

## 3. Resumo por domínio

### D1 — Maintenance (v1.4)
Ciclo do ticket de manutenção preventiva/corretiva: agendamento via SAC, quote review, execução (rede Toyota BR / certificação pós-fato AR), validação automatizada nativa (duplicidade, já-executado, valor por modelo/mês/km), pagamento ao dealer, cobrança de adicionais ao cliente, telemática como gatilho de ticket (km **ou** horas de motor), garantia por serviços executados.
- **3 configurações contratuais** (RN-002): rede Toyota / fora da rede / sem manutenção precificada
- **Plano corretivo por contrato com pool compartilhável** entre veículos (RN-036)
- BR: aprovação por quote review + matriz; AR: sem pré-aprovação — certificação pós-fato com repair order assinada, upload semanal (limite configurável), sequência de revisões por placa
- Integrações: HSV Toyota (histórico DMS), telemática (Geotab), OutSystems/CUP (AR), SAP PO+HES (AR), Vendor Portal
- **Objetos BC**: Ticket/Ordem de Manutenção, Plano + Pool contratual, Preço Padrão, HH rate por fornecedor, motor de validação, gatilho telemático, workflow de exceção

### D2 — Traffic Fines (v1.5)
Ciclo completo de multas: ingestão via fornecedor consolidador (Mônaco BR via API / Geodefender AR via e-mail+Excel), vinculação ao **cliente com custódia na data da infração** (não da captura), ciclo legal BR (Autuação → NIC → Penalidade, indicação de condutor), notificações configuráveis, recurso/cancelamento/restituição, apreensão e restrição de registro (BR), taxas administrativas, reconciliação com pagamento ao fornecedor, **ajuste SNE** (60% vs 80%).
- **3 valores por multa**: faturado ao cliente, pago ao fornecedor, valor cheio (RN-016)
- AR: segmentação A/B (janela 90 dias vs faturamento direto), janela de cobrança por contrato (12 meses, nunca hard-code), taxa 15% só quando KINTO fatura
- Histórico ≥ 5 anos; frota ativa por unidade/mês reconstruível em qualquer data
- **Objetos BC**: Multa (header com 3 valores + evidência), vínculo contrato-infração por data, cadastro de condutor/NIC, órgão autuador com descontos datados, motor de análise AR, reconciliação + SNE

### D3 — Service Management (v1.5)
4 domínios: **(a)** ticket de atendimento com consolidação de 7 canais e fonte única de histórico (hoje 3–5h para entender um caso); **(b)** modelo de atendimento dedicado por conta (BR, SLA com penalidade); **(c)** produto de seguro (tabelas, faixas de prêmio, franquias, risco por CNAE, vidro, Carta Verde) + ciclo do sinistro com 5 trilhas de classificação (destruição total ≥70% do valor de mercado → baixa de ativo fixo); **(d)** documentos do veículo (regulamentares + exigidos pelo cliente, vencimento por tempo/km/**último dígito da placa**, renovação versionada) + downtime com regras de crédito (AR: SLAs por tipo de reparo).
- **Pool/saldo contratual** com flag do que consome (RN-011); débito e restauração automáticos
- 19 tabelas de seguro legadas → normalizar em ~3
- **Objetos BC**: Ticket + subtasks, Pool/Saldo, Produto de Seguro/Apólice, Sinistro com log, Documento do Veículo versionado, Downtime, SLA por contrato

### D4 — Contract Management (v1.5)
Mudanças no contrato em vigor: **extensão** (mantém condições, muda data por placa; multa de retenção por placa com workflow; aditivo só acima de X dias), **renegociação** (limitada por % de consumo; mudança de mensalidade sempre via pricing; cotação pelo prazo restante), **renovação** (BR: nova minuta/aditivo com numeração por versão; AR: troca por 0 km no mesmo dia — não existe renovação com usado), **avaliação cliente/contrato** (só rejeição de Legal/Credit/Collections bloqueia), **estrutura cascata** master→sub→por placa, cesión, REKINTO, contratos expirados com comitê quinzenal e criticalidade.
- Instrumento: BR = master + aditivos; AR = carta oferta única + anexos por evento
- **Objetos BC**: Vehicle Contract + Amendment + Clause Library + Customer Evaluation + Change Log; jobs de vencimento e avaliação; workflows de approval authority

### D5 — Contract Termination (v1.5)
Terminação por tipo (incl. perda total com data retroativa do segurador → status **salvage**; roubo com prazo → encerramento com franquia automática), **devolução** com checklist + laudo cautelar (pré-baixa gerada automaticamente do checklist via Data Lake), retorno com pendências (cobrado do dealer), recuperação de inadimplentes (só high risk; cadeias de tarefas por template), **substituição definitiva na linha** (saldos e cost center pertencem à **linha do contrato**, não ao chassi), veículo sustituto AR (não conta como UIO), **liquidación final** por destruição total (AR, aprovação Finance).
- Qualquer waiver financeiro exige approval authority (BR/AR)
- **Objetos BC**: Termination/Pre-closure, Return + Damage Lines classificadas, Risk Classification, cadeias de tarefas, Substitution, Settlement, Mileage Closing com cap FIPE

### D6 — Billing (v1.4)
Medição mensal por contrato (aluguel + itens de serviço certificados), aprovação (batch/item/parcial), **reajuste por índice** (IPCA BR / IPC AR; frequência por veículo; cap % configurável; exceção com carta prévia e retroativo), **multas contratuais** (retenção recorrente por indicação do D4; rescisória por faixas de utilização), emissão (BR: documento+boleto por produto financeiro, NFS-e, CNAB Itaú; AR: invoice por conceito no SAP, subtotais do BC), créditos retroativos no mesmo contrato, descontos com alçada, **créditos de dias sem serviço limitados a 2% do faturamento**, cancelamento com rastreabilidade, cobranças fora do contrato de aluguel, **comissões de dealer AR** (policy DKIN-003), relatórios de integridade operação×faturamento.
- **Preço diário = mensal/30; mês cheio = 30 dias**; sustituto herda condições do substituído
- BC envia só **subtotais** ao SAP (impostos são do SAP) — PEN-06/07/08 em aberto
- **Objetos BC**: Contract Billing Setup, Billing/Measurement Line com Condition ID, Financial Product, Penalty, Credit/Discount com alçada, Commission, jobs mensais, integração CNAB/NFS-e/SAP

### D7 — Fleet Control (v1.4)
Ciclo de vida do ativo no inventário. **Divergência estrutural BR/AR**: BR = guardião do ativo **fora de contrato** (desmobilização com SLA por etapa, salvado, veículos de terceiros); AR = controle da **frota em operação** (fechamento mensal com aritmética e reconciliação por VIN **e** placa, sanitização One/Share, seguro por unidade, ciclo completo do **dispositivo telemático** — estoque, reuso por fornecedor/duração, aging >60 dias cobra do dealer, plano pago por dispositivo).
- Histórico integral do veículo + por contrato ("qual contrato/placa/motorista em qualquer data")
- Troca de placa para mesmo chassi não duplica registro (special changes com aprovação)
- **Objetos BC**: Unidade/Veículo master, status+motivo configuráveis, Movement Ledger, Dispositivo Telemático + histórico, Apólice por unidade, snapshot de fechamento, workflow de movimentação

### D8 — Remarketing (v1.4)
Venda do usado. BR: portal de seminovos **fora do NFMS** com exatamente 3 touchpoints (envio de disponíveis com preço; lançamento da venda+boleto; baixa após pagamento); precificação mínimo+alvo com fórmula configurável sem código (FIPE/Webmotors/KBB), alçada 4-olhos, venda ao motorista fecha o contrato na data do pagamento, NF-e ativável. AR: preparação da unidade devolvida (herda Anexo 5/chequeo do D5), preço por fontes ponderadas (Infoauto/ACARA/CCA − depreciação por km), **cascata de canais** com prazos configuráveis (cliente → dealer comercial → dealer devolução → subasta → consignação/Mercado Libre; alvo 60 dias), baixa do ativo antes do pagamento, estoque até a transferência de domínio.
- **Objetos BC**: Setup de canais, Oferta em cascata, Pricing Engine com fórmula editável, Lançamento de Venda, Custos com 3 valores, Comissão, workflow de alçada

### DX1 — Customer & Prospect (v1.0)
Leads de todos os canais centralizados no NFMS, qualificação/roteamento (pedido completo do site → direto ao dealer), **Tax ID único e imutável**, conversão prospect→cliente só na virada cotação→contrato (com tarefa de registro no ERP; AR bloqueia billing até confirmação no SAP), dealers com duplo papel cliente+fornecedor, vendedores, transferência de portfólio com auditoria, B2C Car Subscription, bloqueio com motivo.
- Modelo único BR/AR; diferenças por configuração
- **Objetos BC**: Prospect (Contact ou tabela custom), Dealer/Vendedor, Interaction Log, Tarefa de ERP, API pages para middleware

### DX0–DX6, D9 — bloqueados (IRM)
Cobrem master data, oportunidade→cotação, tabelas de preço, **pricing engine**, criação do contrato, compra/preparação/entrega e financeiro. São o complemento exato do que o código atual já implementa parcialmente — **prioridade máxima obter as versões desprotegidas**.

---

## 4. Estado atual do código (KiaDynBC v1.0.0.5)

App AL: 154 arquivos, ~10,5k linhas, runtime 17.0, dependência application 28.3 (BC28.3), idRanges 50000–75149, prefixo **KINTO**, tradução pt-BR presente, 44 testes no núcleo.

### O que já existe e funciona (≈60–65% do valor)
- **Pricing engine ponta a ponta**: cotação multi-item → preço de compra → impostos → comissão → RV lookup → depreciação → metodologia (Target ROI via goal-seek ou KINTO Fee) → **cash flow mensal inflacionado com ~20 componentes** → IRR/ROI/EBT/PAT/FCF → snapshot → **classificação de pré-aprovação** (buffer, credit score, ROI vs IRR, allowance)
- **RV Matrix** com lookup por km/idade projetados + import Excel + template
- **Pacotes** (6 tipos: vidro, 24h, pickup&delivery, reposição, pneus, serviço) integrados ao CF
- **Manutenção como custo de pricing**: planos com faixas por km/idade, itens com markup, custo mensal por contrato (import Excel funcional)
- **Seguro-pricing**: insurer, quote group com loading, coverage limits com cálculo de prêmio
- **Cadastros**: Country Setup completo (seeds BR e AR), Vehicle Model, Inventory Vehicle com booking value + odômetro + soft reserve, Vendor/Supplier groups
- **6 API pages** (publisher kinto, group pricing) — prontas para portal/middleware
- **Aprovação própria** (tabela + API de submissão + pages) — sem workflow nativo BC
- 44 testes cobrindo o núcleo; install/upgrade com number series e seeds

### Stubs e bugs confirmados
| Item | Detalhe |
|---|---|
| Depreciação de mercado | **hardcoded** em faixas (comentário "Simplified") — contornada no fluxo principal pelo engine (100−RV%) |
| Filtro de implementos no RV lookup | fixo em false |
| `Snapshot.Get(Snapshot ID)` | **quebra** — PK da snapshot é Entry No. |
| Snapshot ID Code[20] | no limite exato de caracteres |
| IRR | varredura bruta (não bisseção/Newton), array limitado a 200 meses |
| Goal seek | usa cálculo analítico, não o CF gerado (chamada comentada) |
| Catálogo CF Component | existe como metadado mas **não é usado** pelo gerador (CF hardcoded) |
| Inconsistência AR | TestSetup usa 0,35 (0,35%) onde o design é 35% |
| `SubmitForApproval` | monta Request ID manual, bypassando number series |
| RV import diálogo | corpo comentado (só variante por stream funciona) |

### O que NÃO existe (confirmado por busca no código)
**Contrato** (nenhuma entidade; quote→contrato inexistente), **Billing recorrente** (enum existe, nenhuma rotina), **Manutenção operacional** (só pricing; nada de ordens/agendamento/execução), **Multas por evento** (só custo mensal no CF), **Fleet control operacional**, **Remarketing**, **Sinistros**, **Atendimento/tickets**. Os campos existem como estrutura (especialmente os ~118 campos do Quote Item e a extensão de Fixed Asset) mas sem lógica — a extensão do FA (Booking/Residual/Last Contract No./Asset Status) é a interface pronta e nunca populada para o ciclo contrato→ativo.

---

## 5. Gap analysis — especificação × código

| Domínio | Espec. | Código | Gap |
|---|---|---|---|
| Pricing/Cotação | DX3/DX4 (bloqueados) | ✅ maduro | Confirmar conformidade com DX4 quando desbloquear |
| Cliente/Prospect | DX1 | parcial (extensões Customer/Item/Vendor) | Prospect, dealers, portfólio, bloqueio |
| Contrato | D4 + DX5 | ❌ nenhum | **Construção do zero — o eixo de tudo** |
| Billing | D6 | ❌ nenhum | Construção do zero (medição, reajuste, multas, emissão) |
| Manutenção | D1 | só pricing de manutenção | Operacional completo (tickets, validação, telemática) |
| Multas | D2 | ❌ nenhum | Construção do zero |
| Atendimento/Seguros/Sinistros | D3 | só pricing de seguro | Tickets, sinistros, documentos, downtime |
| Terminação | D5 | ❌ nenhum | Devolução, recuperação, substituição, settlement |
| Fleet Control | D7 | cadastro + odômetro + reserva | Desmobilização, dispositivos, fechamento AR |
| Remarketing | D8 | ❌ nenhum | Preparação, precificação, canais, venda |
| Financeiro | D9 (bloqueado) | ❌ | A definir |

---

## 6. Riscos técnicos e bloqueadores

1. **idRanges 50000–75149 — risco mais grave.** Colide com o **RSBAtivo (64000–64999)** da própria RSBTech — os dois apps não coexistem no mesmo ambiente. E a faixa 50.000–99.999 não é atribuível a ISV/AppSource. **Migrar para o range de identidade Marketplace da RSBTech (71764575–71765574)** ou solicitar range próprio antes de qualquer evolução.
2. **Runtime 17.0 vs application 28.3** — incoerente; BC29 exige AL 18.x. As 6 warnings suprimidas (AL0432, AL0600/0603/0604/0606…) escondem exatamente o que o bump vai revelar.
3. **Bibliotecas de teste ("Library Assert", "Any") como dependência de produção** + testes dentro do app comercial — bloqueador para AppSource; separar em test app.
4. **Prefixo/affix "KINTO"** — marca de terceiros (Kia); AppSourceCop exigirá affix próprio (RTH é o affix registrado da RSBTech).
5. **7 documentos bloqueados por IRM** — o ciclo comercial (DX0–DX6) e o financeiro (D9) não podem ser especificados em detalhe sem eles.
6. Bugs pontuais listados na seção 4 (Snapshot.Get, IRR, 0,35 vs 35, number series de aprovação).

---

## 7. Roadmap sugerido (fases)

| Fase | Conteúdo | Esforço estimado |
|---|---|---|
| **0 — Sanidade** | Corrigir bugs (Snapshot.Get, IRR, AR 0,35), migrar idRanges, bump runtime p/ 18.x, separar test app, remover dependências de teste, resolver affix | ~1–2 semanas |
| **1 — Núcleo contratual** | Entidade Vehicle Contract + estrutura cascata + quote→contrato + populating do FA ext + Condition ID/versionamento (D4/DX5 + base do D6) | 3–5 semanas |
| **2 — Billing** | Medição mensal, reajuste por índice, multas contratuais, créditos, emissão BR (NF-e/CNAB) — D6 | 3–5 semanas |
| **3 — Manutenção operacional** | Tickets, planos→execução, validação nativa, telemática como gatilho, pool de manutenção — D1 | 4–6 semanas |
| **4 — Multas** | Ingestão, vinculação por data, ciclo legal BR, análise AR, cobrança — D2 | 2–4 semanas |
| **5 — Atendimento/Seguros/Sinistros** | Tickets consolidados, pool de saldos, sinistros, documentos — D3 | 4–6 semanas |
| **6 — Terminação + Fleet Control** | Devolução, recuperação, substituição, settlement, desmobilização, dispositivos — D5+D7 | 4–6 semanas |
| **7 — Remarketing** | Preparação, precificação, canais, venda, baixa — D8 | 2–4 semanas |

*Estimativas de desenvolvimento bruto, sem integrações externas (Data Lake, SAP AR, portals, CNAB) — cada integração adiciona 1–2 semanas. Sequência assumindo 1–2 desenvolvedores AL.*

---

## 8. O que não está claro (pendências abertas)

1. **Os 7 docs IRM** (DX0, DX2–DX6, D9) — sem eles o escopo comercial/financeiro fica incompleto. Reenviar desprotegidos.
2. **PEN-06/07/08 do D6**: fronteira fiscal BC×SAP (BC envia só subtotal? múltiplos materials num invoice?) — impacta diretamente o desenho do billing.
3. **PEN-01 do DX1**: campos mínimos da tarefa de criação do Business Partner no SAP (AR).
4. **Seções "6.2 Open points" ausentes** em D7 e D8 (anunciadas no changelog v1.4, não constam do arquivo) — confirmar com a AlfaPeople se foram perdidas.
5. **PEN-15 do D5**: regras detalhadas do veículo provisório BR.
6. **Conformidade do pricing atual com o DX4** — o engine implementado segue o desenho da especificação? (impossível confirmar sem o doc).
7. **Governança do repositório**: quem mantém (commits "BS"/"rb"), se o app já roda em algum ambiente KINTO, e se existe spec de integração do middleware/Data Lake.
8. **D9 Financeiro** — contabilidade, ativo fixo, tax structure BR/AR: domínio inteiro pendente.

---

*Fontes: especificações ESP-NFMS-D1-001 a DX1-001 (v1.0–v1.5, "Final version for signature", 22–24/10/2026, AlfaPeople/KINTO) e código-fonte do app KiaDynBC (github.com/RogerioBraz/KiaDynaminsBC, commit 7f2d04a).*
