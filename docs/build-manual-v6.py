# -*- coding: utf-8 -*-
"""Manual de usuário KiaDynBC v2 — com capturas de tela reais (27/10)."""
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
import os

IMG = "artifacts/kiadyn-manual-v2-imgs"
NAVY = RGBColor(0x0D, 0x1B, 0x3A)
TEAL = RGBColor(0x0E, 0x7C, 0x86)

doc = Document()
# Estilos base
st = doc.styles['Normal']
st.font.name = 'Calibri'
st.font.size = Pt(10.5)

def h1(t):
    p = doc.add_heading(t, level=1)
    for r in p.runs: r.font.color.rgb = NAVY; r.font.size = Pt(16)
def h2(t):
    p = doc.add_heading(t, level=2)
    for r in p.runs: r.font.color.rgb = TEAL; r.font.size = Pt(13)
def para(t, bold=False, italic=False):
    p = doc.add_paragraph()
    r = p.add_run(t); r.bold = bold; r.italic = italic
    return p
def bullet(t):
    doc.add_paragraph(t, style='List Bullet')
def img(name, caption, width=6.3):
    path = os.path.join(IMG, name)
    if not os.path.exists(path):
        return
    doc.add_picture(path, width=Inches(width))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
    c = doc.add_paragraph()
    r = c.add_run(caption); r.italic = True; r.font.size = Pt(9)
    c.alignment = WD_ALIGN_PARAGRAPH.CENTER
def note(t):
    p = doc.add_paragraph()
    r = p.add_run("⚠ " + t); r.bold = True; r.font.color.rgb = RGBColor(0xB4, 0x50, 0x00)

# ================= CAPA =================
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run("\nKiaDynBC — NFMS\n"); r.bold = True; r.font.size = Pt(26); r.font.color.rgb = NAVY
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run("Manual de Usuário — v4 (capturas + regras + configuração)\n"); r.font.size = Pt(14); r.font.color.rgb = TEAL
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run("RSBTech · Dynamics 365 Business Central · 27/10/2026 · versão 1.2.0.0"); r.font.size = Pt(10); r.italic = True
doc.add_paragraph()
para("Novidades da v4:", bold=True)
bullet("NOVO — Apêndice A: regras de cálculo de todos os valores do sistema (fórmula, base, cap e exemplo numérico)")
bullet("NOVO — Apêndice C: guia de configuração (Country Setup por empresa, séries de numeração e limites de cálculo)")
bullet("Cenário novo: penalidade de SLA limitada ao faturamento do mês")
bullet("Correções de Entry No. duplicado nas tabelas de documento, evento, log e violação")
bullet("Capturas de tela reais de todas as páginas principais (mantidas da v2)")

# ================= 1. VISÃO GERAL =================
h1("1. Visão geral do sistema")
para("O KiaDynBC é a solução de gestão de frotas de locação (NFMS) da KINTO Brasil sobre o Dynamics 365 Business Central. Cobre o ciclo completo: precificação de cotação, contratos, faturamento, manutenção, multas, terminação (devolução/substituição/encerramento/recovery), sinistros, reajustes por índice, controle de frota (telemática/apólices) e remarketing de seminovos com portal externo.")
para("Princípio de arquitetura: o país é configuração, não código — regras BR/AR divergentes viram campos de Setup. Todas as telas seguem o padrão do BC: listas com filtros e cards com seções.")
para("Navegação: Role Centers dedicados (Precificação, Frota Control, Portal Seminovos, Claims & Price Adjustments) acessíveis pelo seletor de área no topo.")

# ================= 2. PRECIFICAÇÃO =================
h1("2. Precificação — cotações")
h2("2.1 Grupos de cotação de seguro")
para("Define seguradoras, nível de risco, franquia % e restrições por nível de cliente (NV1/NV2). Usada no cálculo do seguro da cotação.")
img("01-cotacao-quote-groups.png", "KINTO Grupos de Cotação de Seguro — grupo KINTOSEG (Kinto Seguros SP, risco Baixo, franquia 25%, válido até 31/12/2026)")
para("Como usar: Precificação → Grupos de Cotação de Seguro. Criar um grupo por seguradora/região; o campo Restrito + Nível de Cliente limita o grupo a clientes de determinado nível.")

h2("2.2 Fluxo da cotação (Quote)")
para("1. Criar cotação (país, prazo em meses, km mensal, ROI alvo) → 2. Run Pricing (motor calcula valor mensal, seguro, depreciação, ROI) → 3. Aprovar (pré-aprovação automática + revisão) → 4. Create Contract.")
para("O motor usa matriz RV (residual value) por item e faixas de tarifa; cotações fora da matriz exigem aprovação especial.")

# ================= 3. CONTRATOS =================
h1("3. Contratos")
img("02-contrato-card.png", "KINTO Vehicle Contract Card C-00001 — cliente FMA Veículos, país BR, moeda BRL, km mensal 1.500")
para("O card mostra status (Draft → Approved → Active → Terminated), cliente, cotação de origem, veículo e condições financeiras. Ações principais: gerar billing, terminar contrato, substituição de veículo, encerramento (settlement).")
img("03-contrato-condicoes.png", "KINTO Contract Conditions — linhas RENT (Vehicle Rent) com valor mensal/diário e vigência")
para("Condições: cada linha é um produto financeiro (RENT, DAMAGE, SVC-CREDIT, FINE...). Revisões de condição criam nova linha com Revision No. — o histórico nunca é perdido (reajuste por índice cria revisão com cap).")

# ================= 4. FATURAMENTO =================
h1("4. Faturamento (Billing)")
img("04-billing-lines.png", "KINTO Billing Lines — linhas DAMAGE de devoluções (R$ 4.300 e R$ 1.500), mês 01/08/2027")
para("Geração: por contrato (Generate Billing) ou em lote via Job Queue. Ciclo da linha: Open → Approved → Invoiced. Créditos de serviço aparecem como linhas negativas (SVC-CREDIT) limitadas a 2% do faturamento do mês.")

# ================= 5. MANUTENÇÃO =================
h1("5. Manutenção")
img("05-manutencao-ticket.png", "KINTO Maintenance Ticket TK-00001 — corretiva, contrato C-00003, veículo DEM4A99, odômetro 45.000")
para("Tickets corretivos e preventivos com linhas de serviço (peça/mão de obra), marcação de billable (cobre do cliente quando a culpa é dele) e integração com pool contratual e sequência de revisões.")

# ================= 6. MULTAS =================
h1("6. Multas")
img("06-multas.png", "KINTO Traffic Fines — 13 multas DETRAN-SP vinculadas a contratos (Link Status: Linked)")
para("Fluxo: registro → vinculação por placa/período de vigência → cobrança ao cliente (com valor fornecedor separado) → pagamento. Multas fora da vigência ficam Not Linkable.")

# ================= 7. TERMINAÇÃO =================
h1("7. Terminação")
h2("7.1 Devolução (Return)")
img("07-return-card.png", "KINTO Vehicle Return R-00001 — Completed, contrato C-00004, odômetro 52.000, pátio São Paulo")
para("Ciclo: Scheduled → In Progress → Checklist → Finished. Checklist inspeciona odômetro, combustível, laudo cautelar e itens pendentes; danos classificados (Misuse/Accident/Wear) geram cobrança cliente ou dealer.")
h2("7.2 Substituição de veículo")
img("08-substituicao.png", "Contrato Substituição SUB-00001 — VH-00059 → VH-00060, Completed (definitive)")
para("Substituição definitiva herda as condições do contrato e transfere o dispositivo telemático; provisional segue regras BR (PEN-15).")
h2("7.3 Encerramento (Settlement)")
img("09-settlement.png", "Encerramento STL-00001 — roubo c/ franquia: dano 1.500 + franquia 5.000 = total 6.500")
para("Consolida saldos do contrato: billing aberto, danos, multas, excesso de km, franquia da apólice e recuperação de seguro. Tipos: Final Balance, Theft (franquia), Total Loss, Damage.")
h2("7.4 Recovery (recuperação de veículo)")
img("10-recovery.png", "KINTO Recovery Case RC-00001 — aberto, contrato C-00005, risco High")
para("Casos de recuperação (veículo com cliente inadimplente/sumido) com aging em dias, nível de risco (15/45/90d configuráveis) e cadeias de tarefas para risco alto. Job Queue reclassifica casos abertos.")

# ================= 8. SINISTROS =================
h1("8. Sinistros (Claims)")
img("11-sinistro.png", "KINTO Claim — card novo (sem dados ainda; o Demo Data Load v2 cria um sinistro completo)")
note("Tela sem dados: rodar Run Demo Data Load (v2) — cria sinistro classificado (82% → destruição total), envio à seguradora, decisão, indenização e encerramento do contrato.")
para("As 5 trilhas de classificação: Total Destruction (≥70% do valor FIPE), Theft, Partial Damage, Third Party, Glass Only. Destruição total dá baixa do ativo (salvage) e termina o contrato; settlement consolida franquia e indenização.")

# ================= 9. REAJUSTES =================
h1("9. Reajustes por índice")
img("19-reajustes.png", "KINTO Adjustment Ledger — tela vazia; o Demo Data Load v2 aplica reajuste IPCA-T 8% com cap 5%")
note("Tela sem dados: rodar Run Demo Data Load (v2) — cria contrato com índice IPCA-T mensal, variação 8% e cap 5%; o ledger registra contrato, mês, variação e cap aplicado.")
para("Agendador (Price Adjustment Scheduler) roda via Job Queue: mensal/trimestral/anual, idempotente por contrato/mês, com carta prévia ao cliente e cap configurável. Toda aplicação cria revisão de condição + entrada no ledger (auditoria).")

# ================= 10. FROTA =================
h1("10. Controle de frota (Fleet)")
h2("10.1 Dispositivos telemáticos")
img("12-dispositivo.png", "Telemático Dispositivo DEV-00001 — instalado no VH-00017, serial SN-DEMO-20270801")
para("Instalação/remoção com contagem de reuso, comunicação e aging por dispositivo (bloqueio de alto aging). Histórico completo por veículo.")
h2("10.2 Apólices de seguro")
img("13-apolice.png", "Insurance Apólice POL-00001 — VH-00017, compreensiva, franquia 5.000, contrato C-00018")
para("Apólices por veículo com vigência, prêmio anual/mensal, franquia e vínculo ao contrato. Sinistros referenciam a apólice ativa na data do evento.")

# ================= 11. REMARKETING =================
h1("11. Remarketing (seminovos)")
h2("11.1 Ofertas em cascata")
img("14-remarketing-offers.png", "KINTO Remarketing Offers — cascata 3 canais (Cliente → Dealer → Auction), ofertas RMK abertas")
para("Cada veículo em remarketing recebe ofertas por canal (cascata BR: cliente do contrato → dealer comercial → leilão; AR: 5 canais). Preço por fonte ponderada (FIPE/Webmotors) com depreciação por km.")
h2("11.2 Vendas")
img("15-remarketing-sales.png", "Remarketing Sales — tela vazia; o Demo Data Load v2 cria uma venda completa (4-olhos → fatura → pagamento → baixa)")
note("Tela sem dados: rodar Run Demo Data Load (v2) — cria venda ao motorista com aprovação 4-olhos, fatura, pagamento (fecha o contrato) e baixa do ativo.")
para("Alçada 4-olhos obrigatória (Setup D8 BR). Venda ao motorista fecha o contrato na data do pagamento; baixa do ativo após pagamento (BR). Margem bruta calculada por venda.")

# ================= 12. PORTAL =================
h1("12. Portal de seminovos (3 touchpoints)")
img("16-portal-actions.png", "KINTO Portal Actions — resumo dos 3 touchpoints D8 BR")
para("TP1 — envio de disponíveis com preço (CalculatePrice → JSON); TP2 — lançamento da venda + boleto (Sale Invoiced → JSON); TP3 — baixa após pagamento (Sale Paid → JSON). Tudo em fila (Sync Entries) com retry.")
img("17-portal-sync.png", "KINTO Portal Sync Entries — tela vazia; o Demo Data Load v2 gera entries de TP1/TP2/TP3")
note("Tela sem dados: rodar Run Demo Data Load (v2) — cria entries Pending de disponibilidade, venda e baixa (o HTTP só dispara com endpoint configurado).")
h2("12.1 Configuração")
note("Correção 27/10 (commit 9b5040a): o erro \"Já existe o registro na tabela KINTO Portal Config. Primary Key='SETUP'\" ao abrir a página era bug do GetConfig() (buscava PK vazia em vez de 'SETUP'). Publicar a v1.1.0.8 — a página abrirá normal, criando o registro só se faltar.")
para("Campos: Enabled (chave geral), Endpoint URL, API Key (mascarada), Availability Batch Size (padrão 50) e Max Retry (padrão 3). Integração desligada por padrão — habilitar só com endpoint real configurado.")

# ================= 13. TESTES E DEMO =================
h1("13. Testes e carga de demonstração")
img("20-test-management.png", "KINTO Test Management — resumo de execuções (79 runs / 23 passed / 56 failed) e ações")
note("O contador acumula TODAS as execuções desde a instalação do test app — os 56 failed incluem rodadas antigas de versões anteriores (antes dos fixes de Task Scheduler, RV Matrix e portal). Recomendação: rodar Run All Tests após publicar a v1.1.0.8 e usar o resultado da última rodada como referência.")
para("Ações disponíveis: Run All Tests (31 cenários E2E), Run Demo Data Load (11 cenários de demonstração — v2), Workflow Commands (fila de integração) e Job Queue Entries.")
h2("13.1 O que o Demo Data Load v2 cria")
bullet("Contratos ativos com billing aprovada + dispositivo telemático + apólice")
bullet("Multas vinculadas e cobradas (dentro e fora da vigência)")
bullet("Ticket de manutenção com linhas billable")
bullet("Devolução com 3 danos cobrados (cliente R$ 4.300 + dealer R$ 180)")
bullet("Total loss → recovery case automático")
bullet("Reajuste IPCA-T 8% com cap 5% (ledger)")
bullet("Sinistro completo (82% → destruição total, indenização paga)")
bullet("Venda remarketing completa com TP2/TP3 no portal")
bullet("Disponibilidade TP1 enviada com preço")
bullet("Mileage closing: excesso 5.000 km → R$ 8.200 (faixas 1+2)")
bullet("Service credit: 30 dias → crédito limitado a 2% do faturamento")

# ================= 14. ADMINISTRAÇÃO =================
h1("14. Administração")
h2("14.1 Job Queue (agendamentos)")
para("Jobs recomendados: Price Adjustment Scheduler (diário), Recovery reclassification (diário), Device aging (diário), Billing generation (mensal), Portal ProcessPendingEntries (a cada 5 min quando integração ativa).")
h2("14.2 Permissões")
para("Permission sets: KINTO CONTRACT ADMIN (gestão completa), KINTO PRICING USER (cotações), KINTO FLEET USER (frota), KINTO REMARKETING USER (seminovos). Todos com tabledata RIMD nas tabelas do domínio.")
h2("14.3 Séries de numeração")
para("KINTO-QUOTE, KINTO-CONTR (contratos), KINTO-BILL, KINTO-FINE, KINTO-TKT, KINTO-RET, KINTO-SUB, KINTO-STL, KINTO-RCV, KINTO-CLM, KINTO-POL, KINTO-DEV, KINTO-RMK, KINTO-RMS — criadas no Install.")

# ================= 15. TROUBLESHOOTING =================
h1("15. Troubleshooting")
bullet("\"Já existe o registro na tabela KINTO Portal Config\" — corrigido na v1.1.0.8 (commit 9b5040a). Se persistir, verificar registro órfão com PK vazia na tabela 50473.")
bullet("Billing não gera — contrato precisa estar Active e com condições válidas (Valid From <= mês).")
bullet("Reajuste não aplica — contrato precisa de Price Index Code + Index Frequency; scheduler é idempotente por mês.")
bullet("Sinistro sem apólice — CreateClaim exige apólice Active no contrato na data do evento.")
bullet("Oferta não envia — Offer Price precisa estar calculado (CalculatePrice) e canal ativo no Setup D8.")
bullet("Portal não envia — Portal Config Enabled + Endpoint URL; entries ficam Pending até ProcessPendingEntries rodar.")
bullet("Datas em 2027 nos dados demo — WorkDate da sessão de background; rodar Demo Load pela página (sessão do usuário) para usar a data corrente.")



# ================= 16. MANUTENÇÃO PREVENTIVA E TELEMETRIA (D1) =================
h1("16. Manutenção preventiva e telemetria")
para("O plano de manutenção deixa de ser apenas custo de precificação: ele passa a gerar tickets preventivos automaticamente, por quilometragem ou por tempo, e reage a eventos do dispositivo telemático.")
h2("16.1 Agendamento preventivo")
para("A geração roda pelo Job Queue (codeunit KINTO Preventive Maint. Mgt., função Generate Preventive Tickets). Para cada contrato ativo com plano de manutenção habilitado:")
bullet("Compara o odômetro atual do veículo com o próximo odômetro previsto (intervalo de km da linha do plano).")
bullet("Compara a última data preventiva com o intervalo em meses do plano.")
bullet("Se qualquer um dos dois venceu, cria o ticket preventivo já vinculado ao contrato e ao veículo.")
bullet("Grava Última Data Preventiva e Último Odômetro Preventivo no contrato e reagenda o próximo alvo.")
bullet("Não abre um segundo ticket se já existe um preventivo em aberto para o contrato — evita fila duplicada.")
note("Se o plano tiver várias linhas de km, o sistema usa o MENOR intervalo maior que zero. Linha de plano sem intervalo é ignorada.")
h2("16.2 Gatilho telemático")
para("Eventos do dispositivo (KINTO Telematic Event) podem abrir ticket de manutenção sem intervenção manual. O mapeamento evento → tipo de serviço é configurado no KINTO Country Setup (KINTO Telematic Maintenance Trigger).")
para("Eventos tratados: alerta de desgaste de freio, nível baixo de fluidos, limite de odômetro atingido, intervalo de serviço decorrido e recall do fabricante. Cada evento guarda o payload bruto recebido, para auditoria e reprocessamento.")
note("Processar os eventos é idempotente: o mesmo evento não gera dois tickets, mesmo que a rotina rode mais de uma vez.")
h2("16.3 Taxa de hora-homem (HH rate)")
para("A mão de obra é valorizada por hora-homem, e não por um preço fixo digitado à mão. A taxa fica na KINTO Vendor Labor Rate, por fornecedor + tipo de serviço + data de vigência, com valor/hora, horas mínimas faturáveis e moeda.")
para("Na linha do ticket, marque o Tipo de Linha como Mão de Obra (HH) e escolha o Tipo de Serviço — é ele que seleciona qual taxa será buscada. A taxa não é digitada: o campo HH Rate é somente leitura e vem do cadastro do fornecedor.")
h2("16.4 Horas trabalhadas x horas faturáveis")
para("São dois números diferentes, e o sistema guarda os dois:")
bullet("Horas: o que o técnico executou de fato. Nunca é alterado pelo sistema.")
bullet("Horas Faturáveis: o que se cobra = o maior entre as horas executadas e o mínimo faturável do fornecedor.")
para("Exemplo: execução de 1h com mínimo de 2h no cadastro. As Horas continuam 1 (o serviço durou 1 hora), as Horas Faturáveis ficam 2 e a linha é marcada com Mínimo de Horas Aplicado. O valor cobrado é 2 × taxa.")
note("O mínimo nunca apaga as horas executadas. Se as horas trabalhadas fossem sobrescritas pelo mínimo, o histórico perderia o registro do que realmente aconteceu — e não haveria como auditar depois se o serviço foi rápido ou demorado.")
h2("16.5 Quando a taxa é aplicada")
bullet("Na ação Apply Labor Rates, dentro do ticket, para aplicar na hora e ver o resultado.")
bullet("Ao validar o ticket (Validate), que garante a taxa preenchida antes de aprovar.")
bullet("Antes de faturar, ao cobrar do cliente: a taxa vigente é reaplicada, para o cliente ser cobrado pelo valor certo mesmo que a tabela tenha sido corrigida depois da execução.")
para("A data usada é a Data de Serviço do ticket, não a data de hoje. Assim, reprocessar um ticket antigo traz a taxa que valia na época do serviço.")

# ================= 17. ACORDO DE NÍVEL DE SERVIÇO (D3) =================
h1("17. Acordo de nível de serviço (SLA)")
para("O SLA é por contrato (KINTO Service Level), com tempos distintos para resposta e para resolução, além do prazo de substituição de veículo e do limite de indisponibilidade no ano.")
h2("17.1 O que o SLA controla")
bullet("Tempo de Resposta (horas): prazo para o primeiro atendimento ao chamado.")
bullet("Tempo de Resolução (horas): prazo para encerrar o chamado.")
bullet("Veículo Substituto em até (horas): prazo para disponibilizar substituto.")
bullet("Indisponibilidade Máxima (dias/ano): teto anual de dias parado.")
bullet("Penalidade por Hora Violada e Teto de Penalidade (% do mensal).")
bullet("Meta de Disponibilidade da Frota (%), padrão 95%.")
h2("17.2 Como a violação é apurada")
para("A rotina Check SLA Violations varre os tickets em aberto e em andamento, mede as horas decorridas desde a abertura e, quando o prazo do SLA estoura, grava uma violação com a data/hora da detecção e o valor da penalidade.")
para("A penalidade é acumulada no mês e limitada ao teto configurado. Exemplo real, com faturamento mensal de R$ 15.858,60 e teto de 1%: o máximo de penalidade no mês é R$ 158,59, ainda que ocorram três violações de R$ 240,30 — as violações seguintes a zero, e o total nunca passa do teto.")
note("O acumulado considera o que já foi gravado na tabela de violações E o que a própria varredura aplicou na mesma execução, para o teto valer mesmo quando a releitura do mês não encontra as violações recém-criadas.")

# ================= 18. INDISPONIBILIDADE E CRÉDITO (D3) =================
h1("18. Indisponibilidade do veículo (downtime)")
para("Downtime é o registro do período em que o veículo ficou parado (KINTO Vehicle Downtime): veículo, contrato, início, fim, motivo, ticket de origem e dias perdidos calculados.")
h2("18.1 Do downtime ao crédito de serviço")
para("A rotina Create Service Credits varre as indisponibilidades ainda não creditadas, com fim preenchido e marcadas como cobráveis da KINTO, e gera automaticamente o crédito de serviço no faturamento do mês.")
bullet("Só gera crédito se o contrato estiver ativo e já tiver faturamento no mês corrente — não se credita contrato sem cobrança.")
bullet("Depois de gerar, a linha de downtime é marcada como Crédito de Serviço Criado, impedindo crédito em dobro.")
bullet("O motivo da indisponibilidade entra na descrição do crédito, para rastrear a causa.")
note("Se a data de fim estiver vazia, a indisponibilidade ainda está aberta e não gera crédito.")

# ================= 19. CLÁUSULAS CONTRATUAIS (D4) =================
h1("19. Biblioteca de cláusulas contratuais")
para("A biblioteca (KINTO Contract Clause) centraliza o texto jurídico que se repete entre contratos, para não redigitar cláusula a cada negociação.")
h2("19.1 Cadastro da cláusula")
bullet("Cód. da Cláusula, Descrição e Categoria (Geral, Manutenção, Seguro, Jurídico/Foro, Licenciamento/IPVA, Restrições de Uso, Penalidades, Tributos).")
bullet("Texto da Cláusula, com até 2.048 caracteres.")
bullet("País (a cláusula pode valer só para o Brasil ou para todos).")
bullet("Obrigatória, Ativa e Ordem de Classificação.")
h2("19.2 Uso no contrato")
para("As cláusulas são vinculadas ao contrato pelo KINTO Contract Clause Link. O vínculo guarda uma CÓPIA do texto no momento da assinatura (Texto da Cláusula (histórico)).")
note("A cópia é o ponto central: editar a cláusula depois não altera contratos já assinados. O contrato continua mostrando o texto que valia quando foi fechado — que é o que tem valor jurídico.")

# ================= 20. AVALIAÇÃO DE CLIENTE (D4) =================
h1("20. Avaliação de cliente")
para("Ao final do contrato, o cliente é avaliado em três dimensões e recebe uma classificação de risco que orienta a renovação (KINTO Contract Evaluation).")
h2("20.1 Notas e cálculo")
bullet("Comportamento de Pagamento (1-5): pontualidade e inadimplência.")
bullet("Cuidado com o Veículo (1-5): estado na devolução, danos e vistorias.")
bullet("Contagem de Violações / Multas: volume de multas e infrações no período.")
bullet("Valor dos Danos: soma dos danos cobrados do cliente.")
para("A Pontuação Geral combina as notas e o histórico; a Classificação de Risco (Baixo, Médio, Alto) é derivada da pontuação e não é editável. A Recomendação de Renovação aponta o caminho: Renovar, Renovar com Condições ou Não Renovar.")
note("A classificação de risco alimenta a cadeia de tarefas da recuperação: casos de risco Alto acionam o fluxo completo de recuperação de veículo.")

# ================= 21. PRÉ-FECHAMENTO (D5) =================
h1("21. Pré-fechamento de contrato")
para("O pré-fechamento antecipa o encerramento: começa antes da devolução do veículo e reúne tudo que pode gerar cobrança no fim do contrato, para o cliente não ser surpreendido.")
h2("21.1 O que o pré-fechamento apura")
bullet("Data prevista de devolução e data de envio do aviso ao cliente.")
bullet("Previsão de odômetro e previsão de excesso de quilometragem (km).")
bullet("Cobrança estimada do excesso, calculada pela mesma regra da quilometragem final.")
bullet("Multas em aberto e valor de faturamento em aberto.")
h2("21.2 Estágios e efeito")
para("Os estágios vão de Rascunho a Pronto para Devolução e Concluído. O aviso ao cliente é registrado com data (Aviso Enviado / Data de Envio do Aviso). A previsão pode ser recalculada a qualquer momento antes do fechamento.")
note("Quando o contrato é convertido em devolução, o pré-fechamento correspondente passa a Convertido em Devolução — o estorno do que foi apurado fica no fechamento definitivo.")

# ================= 22. SUBTAREFAS, DOCUMENTOS E VENCIMENTO (D3/D4) =================
h1("22. Subtarefas, documentos do veículo e vencimento de contrato")
h2("22.1 Subtarefas do ticket")
para("Um ticket pode ser detalhado em subtarefas (KINTO Ticket Subtask), com responsável, prazo, sequência e dependência entre elas. Uma subtarefa só avança quando a que ela depende estiver concluída.")
h2("22.2 Documentos do veículo versionados")
para("Documentos do veículo (KINTO Vehicle Document) guardam tipo, número, emissor, validade e arquivo. O histórico de versões preserva as versões anteriores: ao substituir um CRLV ou laudo, a versão antiga é marcada como substituída, com a data e o número do movimento que a substituiu, e continua consultável.")
h2("22.3 Vencimento e renovação de contrato")
para("A rotina de ciclo de vida varre os contratos por data de expiração e registra as ações no Log de Expiração de Contrato: aviso prévio enviado, contrato expirado e renovação.")
bullet("Aviso com Dias de Antecedência configurável (pré-expiração).")
bullet("Prorrogação automática opcional para contratos expirados.")
bullet("Recomendação de renovação vinda da avaliação de cliente.")
note("Contrato encerrado não pode ser prorrogado: o sistema rejeita a extensão e pede a renovação como contrato novo.")


# ================= 23. PROSPECT E CLIENTE (DX1) =================
h1("23. Prospect e cadastro de cliente")
para("O prospect é o cliente potencial, guardado em tabela própria (e não como Contato do BC) porque carrega o Tax ID validado, o canal de origem e a conversão que preserva o histórico da negociação.")
h2("23.1 Cadastro do prospect")
bullet("Tipo: B2B (empresa) ou B2C (pessoa física).")
bullet("Tax ID (CPF/CNPJ): validado e único entre os prospects.")
bullet("Canal de origem: site, concessionária, indicação, campanha, contato direto, parceiro ou outro.")
bullet("País, cidade, UF, código IBGE e indicador de Produtor Rural.")
bullet("Contato: nome, e-mail e telefone; vendedor responsável.")
h2("23.2 Estágios do prospect")
para("Novo → Qualificado → Em Negociação → Convertido (ou Perdido / Inativo). Um prospect no estágio Novo não pode ser convertido: primeiro precisa ser qualificado e a negociação registrada.")
h2("23.3 Conversão em cliente")
para("A ação Convert to Customer cria o cliente no BC a partir do prospect. O que acontece na conversão:")
bullet("O cliente é criado com nome, país, cidade, vendedor e contato vindos do prospect.")
bullet("O prospect NÃO é apagado: fica como Convertido, apontando para o número do cliente criado — é o histórico da origem.")
bullet("Todo o histórico de interações migra de prospect para o cliente automaticamente.")
bullet("A situação de cadastro no ERP fica Pendente (ver 23.6).")
note("Prospect bloqueado ou sem Tax ID não converte. O sistema recusa e explica o motivo.")

# ================= 24. INTERAÇÕES, BLOQUEIO E CARTEIRA =================
h1("24. Interações, bloqueio e transferência de carteira")
h2("24.1 Registro de interações")
para("Cada contato com o prospect ou cliente é registrado no Log de Interações: data, tipo (ligação, reunião, e-mail, visita, proposta, reclamação), assunto, detalhes, quem atendeu e o próximo passo com data.")
note("A interação aponta para o prospect OU para o cliente — nunca para os dois. Na conversão, os registros migram sozinhos para o cliente, então o histórico da negociação não se perde.")
h2("24.2 Bloqueio de cliente")
para("Bloquear é o ato de impedir novo processo comercial com aquele cliente. O campo Bloqueado diz que está bloqueado; o registro de bloqueio guarda o resto: motivo (restrição de crédito, pagamento em atraso, quebra de contrato, suspeita de fraude, restrição jurídica ou decisão comercial), data, quem bloqueou e, na liberação, quem liberou e por quê.")
para("O histórico fica guardado mesmo depois da liberação: cada bloqueio é uma linha, com a data em que foi liberado e o motivo da liberação.")
note("Bloqueio sem motivo registrado vira discussão comercial sem prova. Por isso o motivo é obrigatório no registro.")
h2("24.3 Transferência de carteira")
para("Quando um vendedor deixa a empresa ou muda de área, a carteira dele passa para outro vendedor por requisição aprovada. A requisição guarda quem sai, quem entra, a data, o motivo e quem autorizou.")
para("Ao aprovar, o sistema move de fato: todos os clientes e os prospects ativos (não convertidos) passam a apontar para o vendedor de destino, e a requisição registra quantos foram movidos em cada categoria. Requisição recusada não move nada.")
h2("24.4 Cadastro no ERP (regra por país)")
para("Ao converter o prospect, é criada a pendência de cadastro no ERP. No Brasil o cliente já opera normalmente. Na Argentina o cadastro precisa ser confirmado no SAP antes de faturar: enquanto estiver pendente, o faturamento é bloqueado.")

# ================= APÊNDICE A — REGRAS DE CÁLCULO =================
doc.add_page_break()
h1("Apêndice A — Regras de cálculo")
para("Este apêndice descreve COMO cada valor do sistema é calculado: a fórmula, a base de dados usada, os limites (caps) e um exemplo numérico. Serve para conferir um número na tela sem precisar abrir o código.")
para("Convenção: todo arredondamento monetário é a 2 casas (R$ 0,01); percentuais são aplicados sobre a base indicada em cada regra.", italic=True)

# --- A.1 ---
h2("A.1 Precificação — valor mensal da cotação")
para("Fórmula (metodologia Target ROI):", bold=True)
para("  O motor busca, por aproximação iterativa (goal seek), a tarifa mensal que faz o ROI do negócio atingir o alvo:\n"
     "  ROI = (receita total − custo do veículo − despesas) / custo do veículo\n"
     "  Receita total = tarifa mensal × prazo (meses)", italic=True)
para("Base de dados:", bold=True)
bullet("Custo do veículo: preço de compra do item (ou valor FIPE)")
bullet("Valor residual: matriz RV do item, por prazo e km contratado")
bullet("Depreciação: valor de mercado − residual, pelo cálculo de depreciação do país")
bullet("Seguro: cotação do grupo de seguro (Corpo) somada ao pacote quando houver")
para("Limites:", bold=True)
bullet("Fora da matriz RV (prazo × km sem faixa correspondente) → pricing FALHA e exige aprovação especial")
bullet("A tarifa é limitada entre R$ 0,01 e 50% do preço de compra (bounds do goal seek)")
bullet("Tolerância de convergência: 0,0001; máximo de 100 iterações")
para("Exemplo: veículo R$ 120.000, prazo 24 meses, 1.500 km/mês, ROI alvo 3,4% → tarifa mensal ≈ R$ 15.858,60 (fee que aparece no teste Pricing: indicadores calculados).")

# --- A.2 ---
h2("A.2 Faturamento mensal (billing)")
para("Fórmula:", bold=True)
para("  Valor da linha = valor mensal da condição (Monthly Amount) × fator de prorrata\n"
     "  Fator de prorrata = dias faturados / 30", italic=True)
para("Base de dados:", bold=True)
bullet("Condições do contrato com Active = true e vigência (Valid From) dentro do mês")
bullet("Produto financeiro da condição (RENT, FINE, DAMAGE, SVC-CREDIT...)")
para("Prorrata — quando se aplica:", bold=True)
bullet("Mês cheio: 30 dias, Prorated = false")
bullet("Contrato terminado DENTRO do mês: dias = data de terminação − 1º dia do mês + 1, Prorated = true")
para("Idempotência:", bold=True)
bullet("Um contrato é faturado no máximo uma vez por mês — a geração verifica as linhas existentes antes de criar")
para("Exemplo: mensalidade R$ 15.858,60 com terminação no dia 15 → 15 dias faturados → R$ 7.929,30.")

# --- A.3 ---
h2("A.3 Excesso de quilometragem (mileage closing)")
para("Fórmula em duas faixas:", bold=True)
para("  Franquia total = km mensal contratado × prazo (meses)\n"
     "  Excesso = km na devolução − franquia total (se positivo)\n"
     "  Faixa 1 (até 10% da franquia): excesso × preço faixa 1\n"
     "  Faixa 2 (acima de 10%):  (10% da franquia × preço faixa 1) + (excedente × preço faixa 2)", italic=True)
para("Limite (cap):", bold=True)
bullet("A cobrança NUNCA excede o Booking Value do veículo (valor de referência/FIPE registrado no cadastro)")
para("Exemplo: franquia 24.000 km, devolução com 29.000 km → excesso 5.000 km\n"
     "  Faixa 1 = 2.400 km × R$ 1,00 = R$ 2.400; Faixa 2 = 2.600 km × R$ 2,00 = R$ 5.200 → total R$ 7.600\n"
     "  (o teste E2E usa 1.800 × 1,00 + 3.200 × 2,00 = R$ 8.200, limitado ao cap FIPE de R$ 5.000).")

# --- A.4 ---
h2("A.4 Crédito de serviço (service credit)")
para("Fórmula:", bold=True)
para("  Crédito = dias sem serviço × (mensalidade / 30)\n"
     "  Cap = 2% do faturamento do mês\n"
     "  Crédito aplicado = menor valor entre os dois", italic=True)
para("Base de dados:", bold=True)
bullet("Faturamento do mês = soma das linhas de billing do mês, EXCLUINDO as canceladas")
bullet("Mensalidade = Monthly Rent do contrato")
para("Regras:", bold=True)
bullet("Sem faturamento no mês não existe base de cálculo → o pedido de crédito é rejeitado com erro")
bullet("O crédito entra como linha NEGATIVA no faturamento (produto SVC-CREDIT)")
bullet("A linha registra os dias creditados e se o cap foi aplicado (auditoria)")
para("Exemplo: mensalidade R$ 15.858,60, 30 dias sem serviço → crédito calculado R$ 15.858,60; cap de 2% sobre R$ 15.858,60 = R$ 317,17 → aplica R$ 317,17.")

# --- A.5 ---
h2("A.5 Penalidade de SLA")
para("Fórmula:", bold=True)
para("  Horas decorridas = (agora − abertura do ticket) em horas, arredondado a 2 casas\n"
     "  Penalidade = (horas decorridas − horas alvo de resolução) × valor por hora\n"
     "  Cap mensal = % de cap × faturamento do mês\n"
     "  Penalidade aplicada = limitada ao que resta do cap acumulado do contrato no mês", italic=True)
para("Regras:", bold=True)
bullet("O cap é sobre o ACUMULADO de penalidades do contrato no mês, não por violação — senão várias violações furariam o limite")
bullet("Penalty Cap % = 0 desliga o cap (penalidade integral por hora)")
bullet("Sem faturamento no mês não há base de cap → penalidade fica R$ 0,00")
para("Exemplo: alvo 24h, ticket aberto há 48h, R$ 10/h → (48−24) × 10 = R$ 240,00. Com cap de 1% sobre faturamento de R$ 15.858,60 (= R$ 158,59), a penalidade é reduzida para R$ 158,59 e as violações seguintes do mês não pagam mais nada.")

# --- A.6 ---
h2("A.6 Reajuste por índice")
para("Fórmula:", bold=True)
para("  Variação aplicada = menor valor entre (variação do índice, cap contratual)\n"
     "  Novo valor = valor atual × (1 + variação aplicada / 100)", italic=True)
para("Regras:", bold=True)
bullet("Cap = 0 significa SEM cap (aplica a variação integral do índice)")
bullet("Cada aplicação cria uma REVISÃO da condição — o histórico nunca é sobrescrito")
bullet("Idempotente por contrato + mês: rodar o scheduler duas vezes não reajusta de novo")
bullet("Frequência configurável: mensal, trimestral ou anual")
para("Exemplo: valor R$ 15.858,60, índice IPCA-T 8%, cap 5% → aplica-se 5% → R$ 16.651,53 (é o número do teste D6).")

# --- A.7 ---
h2("A.7 Preço de seminovo (remarketing)")
para("Fórmula:", bold=True)
para("  Preço-base = média PONDERADA das fontes de preço ativas\n"
     "     (soma de preço × peso, dividida pela soma dos pesos\n"
     "      e reescalada para 100% quando os pesos não somam 100)\n"
     "  Depreciação por km = preço-base × (1 − (km / 300.000 × 15%))", italic=True)
para("Regras:", bold=True)
bullet("Fontes típicas BR: FIPE e Webmotors, com pesos configuráveis no Setup")
bullet("A depreciação por km satura em 15% aos 300.000 km")
para("Exemplo: FIPE R$ 100.000 com peso 60% e Webmotors R$ 95.000 com peso 40% → base R$ 98.000; com 150.000 km → −7,5% → R$ 90.650,00.")

# --- A.8 ---
h2("A.8 Cobrança de dispositivo ao fornecedor (device aging)")
para("Fórmula:", bold=True)
para("  Cobrança = dias de aging × tarifa diária do país", italic=True)
bullet("Aging = dias entre o desligamento do contrato e a devolução do equipamento ao fornecedor")
bullet("A tarifa diária vem do Setup do país (Lookup GetDailyCharge)")
para("Exemplo: 70 dias × R$ 5,00 = R$ 350,00 (teste Device aging).")

# --- A.9 ---
h2("A.9 Encerramento (settlement)")
para("Fórmula:", bold=True)
para("  Total do encerramento = saldo de faturamento aberto\n"
     "                        + danos cobráveis do cliente\n"
     "                        + multas em aberto\n"
     "                        + excesso de quilometragem\n"
     "                        + franquia da apólice (roubo/perda total)\n"
     "                        − indenização do seguro recebida", italic=True)
bullet("O tipo de encerramento (Final Balance, Theft, Total Loss, Damage) define quais parcelas entram")
bullet("Franquia só entra quando a apólice ativa cobre o evento e o tipo é roubo/perda total")
para("Exemplo (teste D5): danos R$ 1.500 + franquia R$ 5.000 = R$ 6.500.")

# --- A.10 ---
h2("A.10 Avaliação de cliente (score e risco)")
para("Fórmula:", bold=True)
para("  Score = média(nota de pagamento, nota de cuidado com o veículo)\n"
     "  Penalidade: −1 ponto quando há mais de 2 multas/infrações\n"
     "  Score mínimo: 1,0", italic=True)
para("Faixas de risco:", bold=True)
bullet("Score ≥ 4,5 → risco BAIXO")
bullet("Score ≥ 3,0 → risco MÉDIO")
bullet("Score < 3,0 → risco ALTO")
para("Exemplo: 5/5 sem multas → 5,0 (Baixo); 3/3 → 3,0 (Médio); 1/1 com 5 multas → 1,0 (Alto).")

# --- A.11 ---
h2("A.11 Manutenção preventiva (agendamento)")
para("Regra de disparo:", bold=True)
para("  O contrato está devido quando:\n"
     "    odômetro atual ≥ (próximo odômetro previsto − tolerância em km)  OU\n"
     "    data atual ≥ próxima data prevista", italic=True)
para("Reagendamento após criar o ticket:", bold=True)
para("  próximo odômetro = odômetro da ÚLTIMA preventiva + intervalo do plano\n"
     "  próxima data = data da última preventiva + 6 meses", italic=True)
para("  (no primeiro ciclo, sem preventiva anterior, o próximo odômetro é o primeiro\n"
     "   múltiplo do intervalo acima do odômetro atual — nunca um valor já vencido)", italic=True)
bullet("Intervalo vem das linhas do plano de manutenção (KM Interval)")
bullet("Tolerância padrão: 500 km (configurável no plano)")
bullet("Idempotente: rodar a geração duas vezes não cria ticket duplicado")
para("Exemplo: plano de 10.000 km, próximo previsto em 20.000 km, veículo com 19.600 km → 19.600 ≥ (20.000 − 500), cria o ticket; como a última preventiva foi aos 20.000, reagenda para 30.000 km.")

# --- A.12 ---
h2("A.12 Preço de mão de obra (HH rate)")
para("Fórmula:", bold=True)
para("  Valor da linha de mão de obra = horas × taxa HH vigente", italic=True)
bullet("A taxa HH é por FORNECEDOR + TIPO DE SERVIÇO, com data de vigência")
bullet("Vale sempre a taxa mais recente cuja vigência seja ≤ data do serviço")
bullet("Tipo de serviço sem taxa cadastrada retorna 0 (não estima valor)")
para("Exemplo: tabela com R$ 120/h vigente e R$ 180/h a partir do próximo mês → serviço hoje usa R$ 120/h.")

# --- A.13 ---
h2("A.13 Resumo dos limites (caps) do sistema")
para("Tabela de limites:")
t = doc.add_table(rows=1, cols=4)
t.style = 'Light Grid Accent 1'
hdr = t.rows[0].cells
for i, v in enumerate(['Cálculo', 'Limite', 'Base', 'Parametrização']):
    hdr[i].text = v
    for r in hdr[i].paragraphs[0].runs: r.bold = True
for row in [
    ('Excesso de km', 'Booking Value do veículo', 'Cadastro do veículo', 'Fixa'),
    ('Crédito de serviço', '2% do faturamento do mês', 'Linhas de billing do mês', 'Fixa no código'),
    ('Penalidade de SLA', 'Penalty Cap % do faturamento do mês', 'Linhas de billing do mês', 'Por contrato (SLA)'),
    ('Reajuste por índice', 'Index Cap % do contrato', 'Contrato', 'Por contrato (0 = sem cap)'),
    ('Preço de seminovo', 'Depreciação máx. 15%', 'Odômetro do veículo', 'Fixa no código'),
]:
    cells = t.add_row().cells
    for i, v in enumerate(row): cells[i].text = v
para("")
note("Os valores de cap marcados como 'Fixa no código' são regra de negócio acordada — alterá-los exige nova versão do app, não configuração de tela.")

# ================= APÊNDICE B — GLOSSÁRIO DE VALORES =================
doc.add_page_break()
h1("Apêndice B — Onde cada valor aparece")
para("Rastreabilidade entre o cálculo e a tela onde o número pode ser conferido.")
t2 = doc.add_table(rows=1, cols=3)
t2.style = 'Light Grid Accent 1'
hdr2 = t2.rows[0].cells
for i, v in enumerate(['Valor', 'Tela / Campo', 'Origem do cálculo']):
    hdr2[i].text = v
    for r in hdr2[i].paragraphs[0].runs: r.bold = True
for row in [
    ('Tarifa mensal da cotação', 'Quote Item → Monthly Tariff', 'A.1 — goal seek Target ROI'),
    ('Faturamento do mês', 'Billing Lines → Amount', 'A.2 — condição × prorrata'),
    ('Excesso de km', 'Vehicle Return → Mileage Excess Charge', 'A.3 — 2 faixas + cap FIPE'),
    ('Crédito de serviço', 'Billing Line (negativa, SVC-CREDIT)', 'A.4 — dias × mensalidade/30, cap 2%'),
    ('Penalidade de SLA', 'SLA Violation → Penalty Amount', 'A.5 — horas excedentes × valor/hora'),
    ('Reajuste aplicado', 'Adjustment Ledger → Cap Applied %', 'A.6 — menor(índice, cap)'),
    ('Preço de oferta', 'Remarketing Offer → Offer Price', 'A.7 — média ponderada − km'),
    ('Cobrança de device', 'Device Aging Charge → Charge Amount', 'A.8 — dias × tarifa diária'),
    ('Total do encerramento', 'Settlement → Total', 'A.9 — soma de parcelas menos indenização'),
    ('Score do cliente', 'Contract Evaluation → Overall Score', 'A.10 — média penalizada por multas'),
    ('Próximo serviço', 'Vehicle Contract → Next Preventive Odometer', 'A.11 — múltiplo do intervalo'),
    ('Mão de obra', 'Maint Ticket Line → Amount', 'A.12 — horas × taxa HH vigente'),
]:
    cells = t2.add_row().cells
    for i, v in enumerate(row): cells[i].text = v



# ================= APÊNDICE C — CONFIGURAÇÃO =================
doc.add_page_break()
h1("Apêndice C — Configuração do sistema")
para("Como o Kinto é configurado: onde ficam os parâmetros, o que é por empresa e o que é por país, e como validar que está correto.")

h2("C.1 Vínculo empresa → país (passo obrigatório)")
para("Cada empresa do Business Central aponta para UM KINTO Country Setup. Esse vínculo define TODAS as regras que o sistema aplica: séries de numeração, impostos, limites de cálculo e caps.", bold=True)
para("Onde: página Company Information (Informações da Empresa) → campo KINTO Country.")
para("Por que existe: uma mesma instalação pode atender operações com regras diferentes (Brasil e Argentina, por exemplo). Sem o vínculo, o sistema não tem como saber qual regra aplicar e usa o default histórico — que pode estar errado.", italic=True)
para("Sequência de resolução usada por todos os processos:", bold=True)
bullet("1º — KINTO Country da Company Information (o vínculo explícito)")
bullet("2º — país do documento (contrato, cotação, veículo), quando a empresa não foi configurada")
bullet("3º — o único Country Setup existente (compatibilidade com base de um país só)")
bullet("4º — erro explícito, nunca um valor adivinhado")
para("A atualização do app preenche o vínculo automaticamente: respeita o que já estiver configurado, senão usa o setup único, senão assume BR como default histórico. Sempre confira na tela após atualizar.", bold=True)

h2("C.2 KINTO Country Setup — o hub de configuração")
para("Tela: busca → \"KINTO Country Setup\". Um registro por país. 91 campos, organizados em 14 grupos.")
para("Grupos e o que controlam:", bold=True)
t = doc.add_table(rows=1, cols=2)
t.style = 'Light Grid Accent 1'
hdr = t.rows[0].cells
for i, v in enumerate(['Grupo', 'O que configura']):
    hdr[i].text = v
    for r in hdr[i].paragraphs[0].runs: r.bold = True
for row in [
    ('General', 'Metodologia de precificação, moeda, parada de emergência'),
    ('Number Series', 'Séries de cotação, contrato, condição, faturamento, ticket, devolução, substituição, encerramento, recovery, sinistro, multa, apólice, dispositivo, veículo, aprovação'),
    ('Number Series — Remarketing & Contracts', 'Séries de oferta, venda de seminovo, avaliação de contrato e pré-fechamento'),
    ('Calculation Limits and Caps', 'Faixa 1 de excesso de km, cap de crédito de serviço, cap de penalidade SLA, limite de destruição total, depreciação de seminovo, diária de dispositivo'),
    ('Maintenance and Contract Rules', 'Intervalo de preventiva, tolerância de odômetro, dias de aviso de vencimento, auto-extensão'),
    ('Taxes', 'Alíquotas federal/estadual/municipal, PIS/COFINS, ISS, stamp tax e suas descrições'),
    ('Financial', 'Taxa de juros, spread, inflação, risco de crédito por faixa'),
    ('Fleet Operations', 'Fleet Behavior, SLAs de desmobilização, aging de dispositivo, reconciliação de fechamento'),
    ('CreditRisk / Pricing / UsedVehicles / Mileage / Dates / CashFlow', 'Parâmetros de cada motor de cálculo'),
]:
    cells = t.add_row().cells
    for i, v in enumerate(row): cells[i].text = v

h2("C.3 Séries de numeração")
para("Todas as séries são configuráveis — nenhuma está fixa no código. Se o campo estiver vazio, o sistema usa a série histórica como fallback (nada quebra), mas o recomendado é preencher.", bold=True)
para("Séries criadas na instalação e na atualização:", bold=True)
bullet("KINTO-QUOTE (cotações), KINTO-CONTR (contratos), KINTO-COND (condições)")
bullet("KINTO-TICK (tickets), KINTO-RET (devoluções), KINTO-SUB (substituições)")
bullet("KINTO-STL (encerramentos), KINTO-REC (recovery), KINTO-RET")
bullet("KINTO-CLM (sinistros), KINTO-FINE (multas), KINTO-POL (apólices)")
bullet("KINTO-DEV (dispositivos), KINTO-VEH (veículos), KINTO-APPR (aprovações)")
bullet("KINTO-RMK (ofertas), KINTO-RMS (vendas de seminovo)")
bullet("KINTO-EVAL (avaliações), KINTO-PCL (pré-fechamentos)")
note("Série ausente era a causa do erro \"Já existe o registro\": o documento nascia sem número e o segundo registro colidia. A atualização cria as séries que faltarem.")

h2("C.4 Limites de cálculo — o que era fixo e agora é configurável")
para("Estes valores estavam no código e agora são parâmetros por país. Alterá-los muda o cálculo imediatamente, sem publicar nova versão do app.", bold=True)
t2 = doc.add_table(rows=1, cols=3)
t2.style = 'Light Grid Accent 1'
hdr2 = t2.rows[0].cells
for i, v in enumerate(['Campo', 'Default', 'Efeito']):
    hdr2[i].text = v
    for r in hdr2[i].paragraphs[0].runs: r.bold = True
for row in [
    ('Excess Km Band 1 %', '10%', 'Até quanto do km contratado paga a tarifa 1 (acima vai para tarifa 2)'),
    ('Service Credit Cap %', '2%', 'Teto do crédito de serviço sobre o faturamento do mês'),
    ('SLA Penalty Cap %', '0 (sem cap)', 'Teto de penalidade de SLA quando o contrato não define o seu'),
    ('Preventive Interval Months', '6', 'Intervalo padrão de reagendamento da preventiva'),
    ('Contract Notice Days', '60', 'Antecedência do aviso de vencimento'),
    ('Auto Extend Contracts', 'desligado no BR', 'Renova contrato vencido automaticamente'),
    ('Remarketing Km Deprec. Base / %', '300.000 km / 15%', 'Base e teto da depreciação por km do seminovo'),
    ('Device Daily Charge', '5,00', 'Diária de armazenagem cobrada do fornecedor'),
    ('Total Loss Threshold %', '70%', 'Relação dano/valor que caracteriza perda total'),
    ('Odometer Tolerance (km)', '500', 'Tolerância para disparar preventiva por km'),
]:
    cells = t2.add_row().cells
    for i, v in enumerate(row): cells[i].text = v

h2("C.5 Roteiro de validação após atualizar")
para("Confira nesta ordem:", bold=True)
bullet("1. Company Information → KINTO Country está preenchido com o país correto")
bullet("2. KINTO Country Setup → grupo Number Series: todas as séries preenchidas")
bullet("3. KINTO Country Setup → Calculation Limits: valores conforme a política comercial")
bullet("4. Rodar Run All Tests (45 cenários) — o cenário \"Setup: empresa vinculada ao Country Setup\" falha se o vínculo estiver ausente ou apontando para país inexistente")
bullet("5. Criar um contrato novo e conferir se o número saiu pela série configurada")


doc.save("artifacts/kiadynbc-manual-usuario-v6.docx")
print("OK — manual v6 gerado")
