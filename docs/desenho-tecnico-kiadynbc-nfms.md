# KiaDynBC / NFMS — Desenho Técnico da Solução em Business Central
**Complemento do escopo (artifacts/escopo-kiadynbc-nfms.md) · 24/10/2026 · premissas corrigidas 25/10**
*Base: D1–D8 + DX1 (lidos) + código atual do app. Domínios DX0, DX2–DX6 e D9 (bloqueados por IRM) são cobertos por **premissas explícitas**, marcadas como ⚠️ PREMISSA.*

> **Correções de premissa (25/10, Rogerio):** projeto de **cliente** (não RSBTech/AppSource) → **range 50000–75149 do cliente MANTIDO** (sem migração; sem coexistência com RSBAtivo), **prefixo KINTO mantido**, ambiente de desenvolvimento = **Dev / company CoreSetup**, **base já na versão 29** (bump de runtime/dependency no app.json).

---

## 1. Princípios de arquitetura

1. **Um app AL, domínios em namespaces.** App único `KiaDynBC` com namespaces por domínio (`KINTO.Contract`, `KINTO.Billing`, `KINTO.Maintenance`…). Evita fragmentação de dependências.
2. **Configuração por país, nunca modelo por país.** Toda tabela transacional tem `Country/Region Code`; toda regra divergente BR/AR vira campo/enum em tabela de Setup (padrão já usado no `KINTO Country Setup` — estender, não duplicar).
3. **Workflows nativos do BC** para aprovações (approval authority, alçadas de desconto/preço/baixa) — substitui a aprovação própria do código atual (tabela 50117), que fica só para a pré-aprovação automática de pricing.
4. **Job Queue** para todos os jobs recorrentes (medição mensal, reajuste, varredura de vencimentos, cascata de canais, aging de dispositivos, fechamento AR).
5. **Integrações sempre via middleware/Data Lake** (padrão das specs): BC expõe **API pages**; entrada assíncrona via fila/webhook com tela de erros de integração (REQ-003 do D2); saída via Job Queue + `HttpClient`. Nunca integração direta ponto a ponto com fornecedor.
6. **Trilha de auditoria sem deleção** (RN-014 do DX1): registros se inativam/cancelam; Change Log nativo + campos `Inserted By/At`, `Modified By/At` nos masters.
7. **Saldos/pools como ledger**, não como campo: tabela de entries com consumo/restauração (EXC-16 do D1, RN-043 do D3) — permite auditoria e reconstrução.
8. **Moeda e indexação**: contrato em BRL/ARS com índice configurável (IPCA/IPC/misto); reajuste recalcula condição, nunca edita histórico (Condition ID versionado).

### Decisões estruturais (atualizadas 25/10 com o Rogerio)

| # | Decisão | Status |
|---|---|---|
| D-1 | **idRanges** | ✅ **DECIDIDO: manter 50000–75149 do cliente.** Projeto de cliente (não AppSource RSBTech); RSBAtivo não coexistirá neste ambiente. Novos objetos seguem alocados dentro desta faixa (mapa da seção 3 renumerado: mesmas faixas lógicas − 46700, ex. Contrato = 50000–50099 substituindo os objetos migrados) |
| D-2 | **Prefixo/affix** | ✅ **DECIDIDO: KINTO permanece** (projeto de cliente; sem exigência AppSource; KINTO é a marca do produto do cliente) |
| D-3 | **Runtime/versão** | ✅ **DECIDIDO: base já na 29** — bump do app.json p/ runtime 18.x + application/platform 29.0; remover supressões de warning após o bump |
| D-4 | **Testes** | App de teste separado (`KiaDynBC Test`), dependências "Library Assert"/"Any" só nele |
| D-5 | **Contrato como entidade própria** | ✅ **DECIDIDO (25/10)**: licença **Essential** — sem Service Management nativo (Service Order/Service Contract/Service Item do módulo Premium) e sem contrato padrão. Contrato + gestão de serviços 100% custom; faturamento pelo ciclo de **Venda com itens de serviço** (Item.Type = Service, disponível no Essential). Entidade custom orquestrando Sales/Purchase/FA nativos |
| D-6 | **Ambiente** | ✅ **DECIDIDO: Dev / company CoreSetup** (sandbox do cliente); UAT/produção do cliente a definir na implantação |

---

## 2. Modelo de dados central

```
Prospect (DX1) ──conversão──> Customer (BC nativo + tableext)
                                  │
                    Contract Master (framework, BR) / Carta Oferta (AR)
                                  │ 1:N
                          Sub-Contract (cost center/BU)
                                  │ 1:N
                    ┌──> Vehicle Contract (POR PLACA) <──┐
                    │        │ status, data fim, saldos   │
        Quote Header (existente)            Condition/Contract Line
        (pricing → vira contrato)           (Condition ID, revision, vigência)
                                                  │
              ┌───────────────┼───────────────┬──────────────┐
        Billing Line     Pool Ledger      Ticket (D1/D3)   Fine (D2)
        (medição mensal) (consumo/rest.)  (manutenção/     (3 valores,
        por produto      por item         atendimento/     vínculo por
        financeiro       de saldo         sinistro)        data de infração)
                                                  │
        Vehicle/Unit (D7) ── Device (telemático) ── Policy (seguro)
        (ownership, estados, histórico)            ── Document (versionado)
                    │
        Termination (D5) ── Return/Checklist ── Settlement
                    │
        Remarketing (D8) ── Cascade Offer ── Asset Sale ── baixa FA
```

**Entidades-eixo (definição precisa):**

- **Vehicle Contract** — 1 registro por placa sob um sub-contrato. Campos: nº, placa/VIN (TDoc: vincula `Inventory Vehicle`/Fixed Asset), datas início/fim (mudáveis por extensão), status (Ativo, Estendido c/ sem multa, Em renovação, Expirado, Terminado, Rescindido), tipo de terminação, flags (high risk, não-operacional, judicial).
- **Contract Condition Line** — a unidade de verdade comercial: `Condition ID` (novo ID a cada mudança comercial — RN-013 do D6), nº de revisão (0/1…), produto financeiro, valor mensal/diário (mensal/30), índice + frequência + cap, vigência da condição, cost center, status ativa/inativa. **Toda a medição do D6 lê da condição vigente na data.**
- **Pool Ledger Entry** — tipo (dias carro reserva, pneus, km, monetário, revisões), contrato, veículo (quando o pool é por veículo) ou compartilhado (RN-036 do D1), entrada (contratação), saída (consumo por ticket), reversão (cancelamento). Saldo = FlowField.
- **Unit (Vehicle)** — evolução do `KINTO Inventory Vehicle` (50102): ownership (próprio/sublocado/terceiro/TASA), status + motivo (setup), locação de estoque, identifiers order number/VIN/placa/ativo fixo (RN-038 do D7), histórico integral + por contrato (entries, não campos).

---

## 3. Mapa de objetos (range do cliente 50000–75149, mantido)

Objetos existentes já ocupam 50100–50167. Alocação sugerida para os novos, em faixas lógicas dentro da faixa do cliente (livres a partir de 50200):

| Faixa | Uso |
|---|---|
| 50100–50199 | Setup e master data (Country Setup existente + Financial Product, Channel Setup, Clause Library, Órgão autuador, Vehicle Model…) |
| 50200–50299 | Contrato (Master, Sub, Vehicle Contract, Condition, Amendment, Evaluation, Change Log) |
| 50300–50399 | Billing (Billing Line, Measurement, Penalty, Credit/Discount, Commission, Cancellation) |
| 50400–50499 | Manutenção operacional (Ticket, validação, integração com planos existentes 50115–50132) |
| 50500–50599 | Multas (Fine, Driver/NIC, Notificação, Ajuste SNE, Apreensão) |
| 50600–50699 | Atendimento/Seguros/Sinistros/Documentos/Downtime |
| 50700–50799 | Terminação (Return, Checklist, Damage, Recovery, Substitution, Settlement) |
| 50800–50899 | Fleet Control (Unit/movimentos, Device, Policy, Snapshot fechamento) |
| 50900–50949 | Remarketing (Channel, Cascade, Sale, Cost, Buyer) |
| 50950–50999 | CRM (Prospect, Dealer, Salesperson, Portfolio Transfer, Block) |
| 51000–51099 | Codeunits de integração, API pages novas, permission sets, enums extras |

*(Sem migração de IDs: objetos existentes 50100–50167 permanecem como estão; apenas novos objetos entram nas faixas acima.)*

---

## 4. Desenho por domínio

### 4.1 CRM — Prospect/Cliente/Dealer (DX1)
- **Prospect** (tabela custom, não Contact): tipo B2C/B2B, Tax ID com validação CPF/CNPJ/CUIT + unicidade cross-table Prospect/Customer e imutabilidade (erro "TAX ID already exists" — EXC-01), canal de origem (enum configurável), IBGE (BR), flag Rural Producer, campos B2C por configuração.
- **Conversão**: action `Convert to Customer` só habilitada com cotação→contrato; cria Customer + preserva prospect inativo (RN-006); gera **ERP Registration Task** (status Pending/OK/Missing info) — no BR só disponibiliza o cliente; ⚠️ PREMISSA (DX1 PEN-01): na AR a tarefa alimenta criação manual/integrada do BP no SAP e **bloqueia billing** até confirmação (campo no Customer).
- **Dealer** = Customer + Vendor ligados (duplo papel), com comissões mín/máx; **Salesperson** estendida com dealer/portfólio; **Portfolio Transfer Request** com workflow Backoffice (RN-009).
- **Bloqueio**: campo Blocked + motivo; validação em Quote/Opportunity impede novo processo (REQ-023).
- API pages: prospects, contatos, interações, API de Tax ID do B2C (devolve existente ou cria).

### 4.2 Pricing/Cotação (DX2–DX4) — ⚠️ PREMISSA + reaproveitamento
- **Manter o engine atual** (Quote Header/Item, Pricing Engine Mgt, Cash Flow, RV Matrix, Goal Seek, pacotes, seguro-pricing) como núcleo da fase comercial.
- ⚠️ PREMISSA: DX3 (Price Lists) e DX4 (Pricing Engine) definirão tabelas de preço e regras que hoje estão no Country Setup/Item — desenho prevê **Price List Header/Line** (por modelo, uso, prazo, canal) como camada acima do engine, de modo que o engine leia de tabelas de preço em vez de campos fixados.
- Correções obrigatórias antes (fase 0): Snapshot.Get, IRR (bisseção), goal-seek sobre o CF gerado, catálogo CF Component tornar funcional ou remover, AR 0,35→35.
- Aprovação: manter pré-aprovação automática própria (classificação) + encaminhar Non-Standard ao **workflow nativo**.

### 4.3 Contrato (D4 + DX5) — construção nova, eixo do sistema
> **Licença Essential**: sem Service Contract/Order nativo e sem contrato padrão — tudo abaixo é custom, com faturamento via **Sales Order/Invoice com itens do tipo Service** (seção 4.4).
- **Contract Master** (framework BR / carta oferta AR como tipo do mesmo header), **Sub-Contract**, **Vehicle Contract**, **Condition Line**, **Amendment** (numeração automática por master), **Clause Library** (cláusulas com parâmetros editáveis), **Customer Evaluation** (área, resultado, nota; só Legal/Credit/Collections bloqueia — RN-032), **Contract Change Log**.
- Processos: Extensão (por placa, multa de retenção com workflow, aditivo acima de X dias), Renegociação (cotação pelo prazo restante — reusa o engine com termo parcial), Renovação (BR: minuta/aditivo versionado; AR: troca 0 km com coexistência faturada — RN-038), Expirados (job de varredura + criticalidade + tarefas SLA + comitê).
- Quote→Contrato: action no Quote Card aprovado cria Vehicle Contract + Conditions a partir das linhas (populando a FA ext existente: Booking/Residual/Last Contract No./Asset Status).
- ⚠️ PREMISSA (DX5): detalhes de templates, assinatura digital e numeração seguem o desenho acima até o doc chegar.

### 4.4 Billing (D6) — faturamento via Venda com item de serviço
> **Licença Essential**: sem Service Contract nem Job recorrente premium — a medição gera **Sales Order/Invoice** com linhas de **Item.Type = Service** (um item de serviço por Financial Product: aluguel, pacote, multa, taxa…), com preço da Condition vigente. Contratos de venda nativos (Blanket Order) NÃO substituem o Vehicle Contract custom — servem só como documento de faturamento.
- **Financial Product** (tipos de receita: aluguel, pacotes, adicionais, multas, taxas — cada um com: Item de serviço vinculado (Type=Service), gera documento próprio?, impostos/conta, flag regular/adicional, uso por país).
- **Measurement/Billing Line** por veículo×condição×cost center×produto; worksheet mensal com aprovação batch/item/parcial, comparação vs contrato e variação vs mês anterior (REQ-010).
- Jobs: reajuste (1ª semana), retenção (2×/mês), medição, emissão. Créditos retroativos no mesmo contrato (offset configurável); teto de 2% para créditos de dias sem serviço com workflow acima.
- Emissão BR: **Sales Invoice nativa por produto financeiro (Item Type=Service)** + NFS-e + CNAB Itaú (remessa/retorno por filial). AR: ⚠️ PREMISSA (PEN-06/07/08) — BC envia subtotais ao SAP; desenho com **interface de exportação de medição aprovada** (JSON/CSV via middleware) que pode evoluir para invoice completa sem retrabalho do modelo.
- Comissões AR (DKIN-003): tabela Commission com regra por proprietário/base, Anexo 4 como pré-requisito, provisão para o SAP.
- Relatórios de integridade operação×faturamento (REQ-053).

### 4.5 Manutenção operacional (D1)
> **Licença Essential**: sem Service Order/Service Item nativos (Premium) — tickets, ordens e consumo de peças/serviços são 100% custom; pagamento ao dealer continua via Purchase nativo.
- **Maintenance Ticket** (header + linhas de serviço): tipo preventivo/corretivo, placa/VIN, km/horas, status ciclo (Aberto→Análise→Aprovação→Execução→Liberação→Fechado), evidências (anexos), contrato vigente na data (SP-01.14 genérica).
- **Plano**: reusar Maintenance Plan/Range/Number existentes (50115–50132) + **Pool Ledger** para o saldo compartilhável; gatilho automático por telemática (km OU horas — o que primeiro) via job de leitura do middleware.
- **Validação nativa** (substitui bot Blue Prism): duplicidade, já-executado, valor vs Preço Padrão por modelo/mês/km; pré-aprovação automática (HH rate × horas).
- AR: certificação pós-fato, upload em lote com limite configurável, sequência de revisões por placa (bloqueio de salto/re-upload), adicionais → relatório mensal consolidado.
- Pagamento ao dealer = Purchase Order/Purchase Invoice nativos; cobrança ao cliente = Billing Line adicional → Sales Invoice (item de serviço).
- Garantia: cálculo por serviços executados + odômetro (critério configurável).

### 4.6 Multas (D2)
- **Traffic Fine**: placa, órgão/jurisdição, acta, data/hora da infração (≠ data de captura), tipo/código, **3 valores** (cliente/fornecedor/cheio), status configurável por país, evidência PDF, payment link.
- **Vinculação**: job cru multa×histórico de alocação por **data de infração** + janela pós-contrato configurável (60d BR); **Fleet Allocation History** (unidade/mês/cliente) alimentado por D7 — responde "quem tinha o carro em dd/mm".
- BR: Driver Indication + NIC (3 notificações configuráveis), taxas por evento (3 linhas), recurso/cancelamento/restituição, apreensão + restrição, **Ajuste SNE** (60/80% configurável por órgão).
- AR: motor de análise (padronização→cruzamento→segmentação A/B→janela→dedup→custódia), lote Toyota, desconocimiento.
- Ingestão: fornecedor pluggable (interface `IFineProvider`) — API BR / Excel AR via Data Lake; tela de erros de integração.
- Cobrança: gera Billing Lines (produto "Multa", "Taxa administrativa", "Taxa de envio"); reconciliação com pagamento ao fornecedor.

### 4.7 Atendimento/Seguros/Sinistros/Documentos/Downtime (D3)
- **Service Ticket** (mesma engine de ticket do D1, tipos: geral/manutenção/sinistro/documentação) + subtasks + árvore de assuntos configurável + trigger de pesquisa de satisfação no fechamento.
- **Pool/Saldo** consultável no ticket (débito/restauração via Pool Ledger).
- **Insurance Product / Policy / Coverage**: normalizar as 19 tabelas legadas em ~3 (produto, faixa de prêmio, franquia); risco por CNAE; vidro e Carta Verde separados.
- **Claim (Sinistro)**: notificação → classificação em 5 trilhas → log cronológico único → franquia por evidência; destruição total ≥70% (configurável) dispara terminação D5 + baixa de FA.
- **Vehicle Document**: tipos configuráveis, vencimento por tempo/km/dígito da placa, renovação versionada (não sobrescreve), associação unidade/frota, semáforo por prazo de auditoria do cliente.
- **Downtime**: entries com motivo, SLA por tipo de reparo (AR), dias creditáveis = downtime − SLA − atrasos do cliente; reconciliação com billing.

### 4.8 Terminação (D5)
- **Termination** no Vehicle Contract (tipo + data retroativa configurável); total loss → status salvage na Unit + tarefa de nova cotação (BR) / settlement (AR).
- **Return** (data, local lat/long, checklist, laudo cautelar) + **Damage Line** (classificação garantia/má uso/desgaste, quem paga, aprovação); pré-baixa gerada do checklist (INT-06); retorno com pendências → cobrança ao dealer.
- **Recovery**: classificação de risco (low/medium/high + aging), bloqueio/liberação por permissão, **cadeias de tarefas por template** (motor genérico de task chain).
- **Substitution**: troca de placa na linha; saldos e cost center pertencem à linha (RN-010); reversa.
- **Settlement** (AR): componentes (faturamento pós-comunicado, patente, seguro, patentamento, frete, acessórios, Geotab) → aprovação Finance → Billing.
- Km/engine hours no fechamento com pro-rata e cap FIPE (20% configurável, campo de nome neutro).

### 4.9 Fleet Control (D7)
- **Unit** (evolução do Inventory Vehicle): ownership, estados operacional/não-operacional, categorias por idade/condição, locação de estoque múltipla, veículos sob gestão (sem FA), salvado.
- **Desmobilização** (BR): sequência de etapas configurável com SLA por etapa + permissões por área + KPI.
- **Fechamento AR**: job mensal (estoque anterior + entregas − devoluções), reconciliação VIN+placa, snapshot por estado/dono, sanitização One/Share (tabela de consistência).
- **Device (telemático)**: master por serial, reuso por fornecedor/duração (setup), ledger mensal, aging >60d → cobrança dealer, plano pago por dispositivo, projeção de estoque (lote 500/repo 300).
- **Policy por unidade** com vigências e reconciliação com o corretor.
- Movimentação interna AR com **workflow nativo** e tarefas para seguro/documentação/telemática.

### 4.10 Remarketing (D8)
- **Channel Setup** (canais com base de desconto, %, prazo em dias úteis, máximo de política), **Cascade Offer Entry** (timer avança canal), **Market Value** (upload em lote ou Data Lake), **Pricing Engine de venda** (fórmula editável sem código — parâmetros em setup), **Asset Sale** (recebível por chassi+comprador, boleto/Pix, baixa automática no pagamento, Sold-Active/Inactive), **Sale Cost** (3 valores), **Commission** (portal BR / consignação AR).
- BR: 3 touchpoints com o portal via API pages (envio de disponíveis; venda fechada in; baixa out). AR: fluxo completo interno (cascata, gestoría, transferência).
- Venda ao motorista (BR): fecha o contrato na data do pagamento (RN-008).
- NF-e ativável (setup por empresa).

### 4.11 Financeiro (D9) — ⚠️ PREMISSA total
Sem o documento, o desenho assume: contabilidade no BC nativo (BR) com plano de contas/livros da KINTO; integração SAP (AR) apenas como exportação de subtotais/provisões; ativo fixo nativo do BC integrado à Unit (a FA ext atual já prepara essa ponta). **Todo este domínio será redesenhado quando o D9 chegar.**

---

## 5. Integrações (visão única)

| Integração | Direção | Mecanismo | Domínios |
|---|---|---|---|
| Middleware/Data Lake | 2 vias | API pages (in) + Job Queue/HttpClient (out) | Todas |
| Telemática (Geotab etc.) | in | odômetro/horas/localização → gatilhos de ticket, km de devolução, cross-check de multas | D1, D2, D5, D7 |
| HSV/DMS Toyota | in | histórico de serviços (Data Lake) | D1 |
| Fornecedor de multas (Mônaco/Geodefender) | in | API BR / Excel AR | D2 |
| Portal de seminovos (BR) | 2 vias | API pages: disponíveis / venda / baixa | D8 |
| Customer Portal / Vendor Portal | 2 vias | API pages (status, evidências, payment link, Anexo 5, tarefas) | D2, D3, D5, D7 |
| SAP (AR) | out | subtotais de medição, BP task, provisão de comissões, PO+HES | D6, D9, D1 |
| Banco Itaú (BR) | 2 vias | CNAB remessa/retorno | D6, D8 |
| NFS-e/NF-e (BR) | out | emissão por unidade emitente | D6, D8 |
| Assinatura digital (BR/AR) | out | minutas/aditivos/anexos | D4 |
| OutSystems/SIAC (AR legado) | transição | pontes até desativação | D1, D5, D8 |

Padrão comum: **tabela de fila de integração** (payload, status, erro, retry) + tela de erros + idempotência por chave externa.

---

## 6. Plano de implementação (fases com critérios de saída)

| Fase | Entregas | Critério de saída |
|---|---|---|
| **0 — Sanidade** (1 sem) | Bump runtime 18.x/application 29.0 no app.json, remover warnings suprimidas, bugs (Snapshot, IRR, AR 35%), test app separado | App compila limpo na base 29 (Dev/CoreSetup) sem warnings suprimidas; testes verdes no test app |
| **1 — CRM + Contrato** (4–6 sem) | Prospect/Dealer/bloqueio; Master/Sub/Vehicle Contract/Condition/Amendment; quote→contrato; FA ext populada; workflows de approval; **itens de serviço (Type=Service) por Financial Product** | Ciclo cotação aprovada → contrato ativo → veículo "In Contract" ponta a ponta na Dev |
| **2 — Billing** (3–5 sem) | Medição, reajuste, retenção/rescisória, créditos, **geração de Sales Order/Invoice c/ linhas de serviço**, emissão BR (NFS-e/CNAB stub) | 1 mês fechado de medição→faturamento (Sales Invoice c/ item de serviço) em sandbox com dados de teste |
| **3 — Manutenção** (4–6 sem) | Tickets, planos→execução, pool ledger, validação nativa, gatilho telemático (stub de integração) | Ticket preventivo automático por km + corretivo com quote review + pool consumido/restaurado |
| **4 — Multas** (2–4 sem) | Fine, vinculação por data, ciclo BR, análise AR, cobrança via Billing | Multa ingerida → vinculada → faturada → reconciliada |
| **5 — Atendimento/Seguros** (4–6 sem) | Tickets consolidados, sinistros, documentos, downtime | Sinistro com destruição total dispara terminação + baixa FA |
| **6 — Terminação + Fleet Control** (4–6 sem) | Return/checklist, recuperação, substituição, settlement, desmobilização, dispositivos | Devolução completa → Unit em estoque → desmobilizada → disponível p/ venda |
| **7 — Remarketing** (2–4 sem) | Canais, cascata, venda, baixa, resultado por unidade | Venda BR via mock de portal + venda AR via cascata, margem por unidade |

Dependência crítica: **fases 1→2 são o caminho crítico** (todo o resto consome Vehicle Contract + Billing Line). Fases 3–5 podem parcialmente paralelizar após a 2.

---

## 7. Premissas registradas (a validar quando os docs chegarem)

1. ⚠️ DX3/DX4: price lists como camada de tabelas acima do engine atual; engine mantém a matemática.
2. ⚠️ DX5: templates de contrato e assinatura digital conforme seção 4.3.
3. ⚠️ DX0: master data (veículo, modelo, fornecedor) mapeado nas tabelas propostas; agrupamento de faturamento por cost center do cliente (já afirmado no DX1).
4. ⚠️ DX2: oportunidade→cotação segue o fluxo natural BC (Opportunity/Sales Quote) com campos KINTO.
5. ⚠️ DX6: compra/preparação/entrega via Purchase Order + processo de preparação na Unit (etapas tipo desmobilização).
6. ⚠️ D9: contabilidade BC nativa no BR; SAP AR só recebe subtotais.
7. ⚠️ PEN-06/07/08 (D6): fronteira fiscal BC×SAP resolvida com exportação de medição aprovada.

---

## 8. Decisões — status

1. ✅ **Range**: manter 50000–75149 do cliente (decidido 25/10)
2. ✅ **Prefixo**: KINTO permanece (decidido 25/10)
3. ✅ **Ambiente**: Dev / company CoreSetup; base 29 (decidido 25/10)
4. ✅ **Contrato**: entidade custom — licença **Essential** (decidido 25/10): sem Service Management nativo (Premium) e sem contrato padrão; serviços 100% custom; faturamento via **Venda com item de serviço** (Item.Type=Service)
5. **Começo**: fase 0 (sanidade: bump 29 + bugs) ou protótipo do Vehicle Contract primeiro?
