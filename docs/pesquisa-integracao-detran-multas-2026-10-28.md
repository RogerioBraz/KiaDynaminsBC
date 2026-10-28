# Integrações DETRAN, consulta de placa e CPF/CNPJ — pesquisa para o KiaDynBC

**Data:** 28/10/2026 · **Contexto:** o KiaDynBC já tem tabelas de `KINTO Fine Provider`, `KINTO Fine Integration Error` e `KINTO Issuing Authority` — ou seja, a arquitetura para importar multas de provedor está prevista, falta escolher o canal.

---

## Resumo da recomendação

| Necessidade | Caminho recomendado | Por quê |
|---|---|---|
| Multas em escala, multi-estado | **Provedor especializado** (Infosimples, APIBrasil, NITRO) | Só eles cobrem vários DETRANs com um contrato |
| Multas, frota própria em 1 estado | **API oficial do DETRAN do estado** (PR, SP) | Sem custo por consulta, dados na fonte |
| Dados do veículo pela placa | **Provedor de placa** (R$ 0,03–0,20) | Barato e imediato; oficial não é uniforme |
| CPF / CNPJ | **SERPRO** (oficial) | Única fonte oficial com contrato público |

**Decisão que vem antes de tudo:** a KINTO já informa ao cliente que "gerencia e monitora as multas junto aos órgãos de trânsito através de uma empresa especializada na Gestão de Multas" (Manual do Usuário One Fleet, seção 8). Se essa empresa já entrega os dados, o caminho mais barato é **integrar o que ela já produz**, não contratar um segundo provedor.

---

## 1. APIs oficiais de DETRAN

### DETRAN/PR — API Frotista (a mais completa para frota)

REST com Swagger público: `https://detranfrotistaapi.paas.pr.gov.br/q/swagger-ui/`

Cobre 23 serviços, incluindo os que importam para locadora:

- VII — Consulta frota de veículos pelo **CNPJ**
- VIII — Consulta dados do **Condutor**
- IX — Consulta **Bloqueios**
- X — Consulta **Dados do Veículo**
- XV — Consulta Débitos de Licenciamento
- XVII — **Consulta Débitos de Multas**
- XVIII — Emite guia de pagamento de multas
- XIX — Consulta Recursos
- XX — Consulta Multas Pagas
- XXIII — **Indicação de Condutor** para Auto de Infração

**Requisitos:** e-CNPJ A1 ICP-Brasil válido; requerimento do Anexo II da Portaria 1846/2024-DP via e-Protocolo; prova de capacidade de integração antes da liberação. Cada estado tem o seu — não existe uma API frotista nacional.

**Por que é relevante:** a indicação de condutor (item XXIII) é justamente o processo que a KINTO faz hoje por e-mail com o cliente, e cujo descumprimento gera a multa NIC (dobro do valor) descrita no manual da KINTO.

### DETRAN/SP — Prodesp e Integrador SP.GOV.BR

- `API Detran Multas` (RENAINF): AIT, histórico de infrações, documentos
- `API Detran Veículos`: cadastro, débitos, RENAVE
- **Consulta Veículos por CPF/CNPJ** — existe e é exatamente o que uma locadora precisa para conferir a frota por titular

Acesso pelo Integrador de APIs do Estado de SP: `integrador.sp.gov.br` → catálogo → Detran. Documentação OpenAPI pública.

### Pontos de atenção das APIs oficiais

- **Fragmentação por estado** — 27 DETRANs, 27 credenciamentos, 27 certificados
- Exigem certificado e-CNPJ e, em vários, login/senha do gov.br
- Nem todos publicam doc; alguns exigem scraping (ver §3)

---

## 2. Provedores especializados (multi-estado)

### Infosimples

Cobre consultas DETRAN por UF com uma única API. Detalhes que importam:

- `DETRAN / Restrições (Unificada)`: exige **UF + Placa + RENAVAM + Chassi**
- Para TO, exige CPF/CNPJ do proprietário
- Para **MG, RS e SC**: exige login e senha do **gov.br**
- Para **SP**: exige login e senha do **DETRAN-SP**
- Para PR: exige certificado PKCS#12 e senha (`pkcs12_cert`, `pkcs12_pass`)

Ou seja: **não é plug-and-play**. Cada UF tem seu conjunto de credenciais. A boa notícia é que a API unifica o formato de resposta.

A empresa declara-se "ferramenta tecnológica de automação de processo, sem vínculo com os órgãos" — é scraping organizado, não integração oficial. Isso tem implicação de conformidade.

### APIBrasil (open source)

`github.com/APIBrasil/api-multas` — projeto aberto que consulta multas nos DETRANs via web scraping e devolve JSON. O próprio repositório avisa: "apenas parte de um estudo pessoal, use em produção por sua conta e risco". Estados operacionais listados: MG, AL, PB, GO, MA, DF, MS.

Serve como **referência técnica** de como cada DETRAN expõe os dados — não como dependência de produção.

### API NITRO

Consulta multas por placa **e** RENAVAM, preservando órgão autuador, número do AIT, valor e situação. A resposta informa **quais fontes foram consultadas e quais não responderam** — desenho honesto para lidar com a fragmentação.

---

## 3. Consulta de placa (dados do veículo)

Mercado maduro e barato. Preços públicos consultados hoje:

| Provedor | Produto | Preço |
|---|---|---|
| API PLACAS | Consulta simples (marca, modelo, ano, cor, combustível, município) | **R$ 0,03** |
| API PLACAS | Consulta completa (motor, chassi, Renavam) | **R$ 0,20** |
| API PLACAS | Renavam | R$ 0,12 |
| Puxa Placa | Plano Essencial | R$ 49/mês (~1.500 consultas) |
| Puxa Placa | Excedente | R$ 0,04/consulta |

A API PLACAS usa `GET https://wdapi2.com.br/v3/basico/{placa}` com Bearer token, aceita placa antiga (ABC1234) e Mercosul (ABC1D23), e **não cobra requisições com erro**.

**Uso no KiaDynBC:** preencher automaticamente o cadastro de `KINTO Inventory Vehicle` na entrada do veículo — marca, modelo, ano, chassi, Renavam — eliminando digitação e erro. A R$ 0,03, um cadastro de 1.000 veículos custa R$ 30.

---

## 4. CPF e CNPJ — SERPRO (oficial)

### CNPJ API Query

Loja SERPRO (`loja.serpro.gov.br/cnpj-api-query`). Três níveis de retorno: Básica, QSA (sócios) e Empresa. Autenticação OAuth2 com Consumer Key/Secret.

**Teste gratuito:** até 30 dias ou 3.000 consultas, o que vier primeiro.
**Pré-requisito:** certificado digital e-CNPJ.

### Consulta CPF — atenção a mudança recente

Desde **29/05/2026** está no ar a **v3**:
- Novo endpoint: `https://gateway.apiserpro.serpro.gov.br/consulta-cpf-df/v3`
- **Passou a exigir CPF + data de nascimento** (antes só o CPF)
- Campo "ano de óbito" removido

**As versões anteriores foram desativadas em 02/10/2026.** Quem integrou antes dessa data com v1/v2 já está fora do ar — vale conferir se algum sistema da RSBTech ou da KINTO usa a versão antiga.

A SERPRO exige certificado **e-CNPJ** para contratar (não serve e-CPF).

---

## 5. Faixa de preço do mercado

Para dimensionar: um fornecedor brasileiro publica tabela em escada — **R$ 0,20 por consulta** nas primeiras 500 do mês, caindo para **R$ 0,05** acima de 100 mil consultas mensais. O padrão do mercado é esse: preço unitário cai conforme o volume.

Comparando com o custo de uma multa NIC (dobro do valor da infração, conforme o §8º do art. 257 do CTB), o custo por consulta é irrelevante — o que pesa é **não consultar**.

---

## 6. Como isso encaixa no KiaDynBC

O sistema já tem o desenho pronto:

| Objeto existente | Papel | O que falta |
|---|---|---|
| `KINTO Fine Provider` | Cadastro do provedor | Preencher com o escolhido |
| `KINTO Fine Integration Error` | Erros de importação com data/hora | Já modelado |
| `KINTO Issuing Authority` | Órgãos autuadores | Já modelado |
| `KINTO Traffic Fine` | Multa com status de vínculo | Já modelado |
| `KINTO Fine Fee Setup` | Valor por tipo de taxa | Página criada na 1.2.0.6 |

**O que seria preciso construir:**
1. Implementação HTTP no padrão do `KINTO Portal Integration` (já existe HttpClient com Bearer e retry)
2. Codeunit de Job Queue para varredura periódica
3. Mapeamento de payload por provedor
4. Tratamento de credencial por UF (o ponto mais chato — ver §2)

---

## O que não está claro

- **Qual é a empresa especializada que a KINTO já usa.** O manual do cliente cita mas não nomeia. Se ela já entrega arquivo/API, integrar com ela é muito mais barato que contratar um segundo canal.
- **Se o KiaDynBC é para uso da KINTO Brasil ou é produto a vender.** Se for produto, a fragmentação de 27 DETRANs vira requisito de arquitetura; se for uso interno, um provedor unificado resolve.
- **Conformidade LGPD do scraping.** Infosimples e similares não têm vínculo com os órgãos. Para dados de multa (que incluem CPF do proprietário) isso merece avaliação jurídica — a via oficial (SERPRO + DETRAN credenciado) é mais defensável.
- **Custo de cada via em volume.** Não obtive tabela pública de preço dos provedores de multa (só de placa e CPF/CNPJ). Precisa de cotação.

## Fontes

- DETRAN/PR — API Frotista: https://www.detran.pr.gov.br/Pagina/Frotista
- Swagger DETRAN/PR: https://detranfrotistaapi.paas.pr.gov.br/q/swagger-ui/
- Integrador SP.GOV.BR (Detran Multas): https://integrador.sp.gov.br/wps/portal/integrador/catalogoApis/API/detran-multas
- Prodesp — API Detran Veículos: https://api.prodesp.sp.gov.br/portaldeapis/product/api-detran-ve%C3%ADculos/01tKj00000RGnXxIAL
- Infosimples — DETRAN Restrições Unificada: https://infosimples.com/consultas/detran-restricoes/
- API PLACAS — valores: https://apiplacas.com.br/valores
- API PLACAS — documentação: https://apiplacas.com.br/documentacao
- Puxa Placa: https://puxaplaca.app/
- API NITRO — multas: https://apinitro.com/pt/apis/multas-transito-brasil/
- APIBrasil/api-multas: https://github.com/APIBrasil/api-multas
- SERPRO — CNPJ API Query: https://loja.serpro.gov.br/cnpj-api-query/product/cnpjapi
- SERPRO — Consulta CPF v3: https://centraldeajuda.serpro.gov.br/duvidas/pt/avisos/avisoconsultacpfv3/
- SERPRO — como contratar: https://apicenter.estaleiro.serpro.gov.br/documentacao/consulta-cpf/pt/como_contratar
- KINTO — Manual One Fleet (gestão de multas por empresa especializada): https://kintomobility.com.br/documents/manuais-onefleet-pt.pdf
