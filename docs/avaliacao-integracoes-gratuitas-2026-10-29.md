# Avaliação de integrações SEM CUSTO para o piloto KINTO

**Data:** 29/10/2026 · **Contexto:** piloto de avaliação da capacidade do Business Central. O objetivo é montar o máximo de integração real **sem contratar terceiros**, demonstrando capacidade de entrega.

Todos os endpoints abaixo foram **testados ao vivo** deste ambiente nesta data. Onde não funcionou, está registrado.

---

## Veredito rápido

| Domínio | Dá de graça? | Como | Qualidade |
|---|---|---|---|
| **CNPJ** | **Sim, completo** | BrasilAPI / Minha Receita | ⭐⭐⭐ nome, endereço, CNAE, sócios, situação |
| **CEP** | **Sim, completo** | BrasilAPI CEP v2 / ViaCEP | ⭐⭐⭐ logradouro, bairro, cidade, UF, IBGE, **lat/long** |
| **FIPE (preço de veículo)** | **Sim, completo** | parallelum / fipex | ⭐⭐⭐ valor de referência mensal + código FIPE |
| **Feriados / taxas** | **Sim** | BrasilAPI | ⭐⭐ Selic, CDI, IPCA (útil para reajuste) |
| **DDD / IBGE** | **Sim** | BrasilAPI | ⭐⭐ cidade por DDD |
| **CPF — validação formal** | **Sim, sem API** | algoritmo módulo 11 no próprio AL | ⭐⭐⭐ pega erro de digitação |
| **CPF — dados do titular** | **Não** | só SERPRO (pago, exige e-CNPJ) | — |
| **Placa / dados do veículo** | **Não de forma legítima** | ver §4 | — |
| **Multas** | **Não** | ver §5 | — |

**Resumo:** 4 dos 7 domínios dão para fazer **100% de graça e oficialmente**. Os 3 que sobram (dados de CPF, placa, multas) têm impedimento estrutural, não é questão de achar o endpoint certo.

---

## 1. CNPJ — completo e gratuito

### Testado agora

```
GET https://brasilapi.com.br/api/cnpj/v1/19131243000197
```
Resposta real: razão social, UF, CEP, bairro, número, porte, **QSA completo com nome dos sócios, qualificação, data de entrada e faixa etária**.

### Opções

| Fonte | Chave | Limite | Observação |
|---|---|---|---|
| **BrasilAPI** | não | uso "de pessoa real" | Sem SLA formal; é projeto comunitário |
| **Minha Receita** | não | **ilimitado, por diretriz** | "nenhuma consulta é ou será recusada por limite de uso" |
| apipj | opcional | 50.000/mês grátis, 3/min sem chave | Base mensal da Receita |
| SERPRO (oficial) | sim, pago | teste 30 dias / 3.000 | Exige e-CNPJ |

**Recomendação para o piloto:** Minha Receita como principal (não tem limite e é o mesmo dado), BrasilAPI como fallback. Zero contratação.

### Onde usar no KiaDynBC

- Preencher o cliente no ato do cadastro (razão social, endereço, CNAE, sócios)
- **Validar o CNPJ do prospect** antes de converter em cliente
- Conferir situação cadastral (ativa/baixa) na renovação do contrato
- Alimentar a tabela de `KINTO Prospect` que hoje é digitada à mão

---

## 2. CEP — completo e gratuito

### Testado agora

```
GET https://brasilapi.com.br/api/cep/v2/01310100
```
Resposta real: `SP / São Paulo / Bela Vista / Avenida Paulista` **+ código IBGE + timezone + latitude/longitude**.

O `v2` traz **coordenadas geográficas** — isso permite plotar a frota num mapa sem contratar serviço de geocoding.

### Opções

| Fonte | Chave | Observação |
|---|---|---|
| **BrasilAPI CEP v2** | não | Tem fallback entre vários provedores; devolve lat/long |
| ViaCEP | não | Base de 1,6 milhão de CEPs (22/10/2026); **bloqueou este sandbox** no teste |
| BrasilCEP | não | Sem limite declarado |

**Recomendação:** BrasilAPI CEP v2 (já testado OK aqui). ViaCEP como alternativa — funciona em geral, só não respondeu deste ambiente.

### Onde usar

- Preencher endereço do cliente pelo CEP no cadastro
- Endereço de entrega/devolução do veículo
- **Mapa da frota** usando lat/long — combina com o Leaflet+OSM que já usamos no portal da FUPA

---

## 3. FIPE — preço de referência do veículo, de graça

Este é o achado mais forte para o piloto: **o cap de cobrança do excesso de quilometragem usa o "Booking Value" do veículo** (`CalcCharge` → `Vehicle."Booking Value"`). Hoje esse valor é digitado à mão.

### Testado agora (fluxo completo)

```
GET https://parallelum.com.br/fipe/api/v1/carros/marcas/59/modelos
GET .../marcas/59/modelos/5585/anos
GET .../marcas/59/modelos/5585/anos/2011-3
```
Resposta real:
```json
{"Valor":"R$ 60.320,00","Marca":"VW - VolksWagen","Modelo":"AMAROK ...",
 "AnoModelo":2011,"Combustivel":"Diesel","CodigoFipe":"005329-5",
 "MesReferencia":"outubro de 2026"}
```

### Opções

| Fonte | Chave | Limite |
|---|---|---|
| **parallelum** (deividfortuna) | não | 500/dia sem token, **1.000/dia com token grátis** |
| fipex | não | sem chave, histórico completo |
| tabelafipe.info | não | sem cadastro |
| fipe.api.br | token grátis | 1.000/dia |

**Recomendação:** parallelum com token grátis (1.000 consultas/dia cobre uma frota piloto com folga).

### Onde usar — e por que importa

1. **`Booking Value` do veículo** — alimenta o cap da cobrança de excesso de km. Hoje manual, viraria automático.
2. **Depreciação na precificação** — o `A.1` do manual calcula depreciação; a FIPE dá o valor de mercado mês a mês.
3. **Preço do seminovo no remarketing** — `CalculatePrice` usa depreciação por km; a FIPE ancora no mercado real.
4. **Conferência na devolução** — valor do veículo na entrada × na saída.

Este é o tipo de integração que **demonstra capacidade real**: pega um número que hoje é chutado e ancora numa fonte oficial mensal.

---

## 4. Placa / dados do veículo — o impedimento honesto

Aqui é importante ser direto: **não existe API pública e oficial de consulta por placa para empresas privadas.**

### o que existe

| Caminho | Situação real |
|---|---|
| **WSDenatran / Consulta Online Senatran** (oficial) | Existe e é o canal correto — mas exige **termo de autorização no Denatran + contrato com o SERPRO** e certificado digital |
| **Consulta Placa Veicular (SENATRAN)** | Pública, mas exige o **QR Code da placa física** — serve para validar a placa, não para descobrir dados de um veículo qualquer |
| **DETRAN-SP Dados Abertos** | Publica bases mensais de veículos, habilitação, sinistros, infrações — **download em lote, não consulta por placa** |
| **DETRAN/PR API Frotista** | A mais completa do país (23 serviços, inclui consulta por CNPJ) — exige e-CNPJ e requerimento formal |
| SINESP Cidadão (app) | API interna usada pelo app do governo, **sem autorização pública**; usá-la é acesso não autorizado |

### O que eu **não** recomendo

Existe prática difundida de consumir endpoints internos do app SINESP ou fazer scraping dos portais de DETRAN. **Para um piloto com a KINTO isso é risco desnecessário** — é acesso não autorizado a sistema público, e num projeto de avaliação de capacidade o argumento vira contra.

### Alternativa que funciona de graça

**DETRAN-SP Dados Abertos**: baixar a base mensal de veículos do estado de SP e **carregar em tabela no BC**. Aí a "consulta por placa" é uma busca local — instantânea, sem API, sem custo, sem risco. Para uma frota piloto em SP isso resolve o caso de uso inteiro e ainda demonstra capacidade de ingestão de dados em lote.

---

## 5. Multas — o impedimento é outro

Multas **não têm fonte gratuita**. Todas as vias passam por credenciamento:

- DETRAN/PR Frotista (oficial, e-CNPJ)
- Prodesp/DETRAN-SP (oficial, credenciamento)
- Infosimples / NITRO / APIBrasil (provedores — cada UF exige credencial própria; é scraping organizado)

E há o fato já registrado: **o manual da KINTO informa que a gestão de multas é feita por uma empresa especializada**. Se ela já entrega os dados, integrar com ela é o caminho — e é uma conversa comercial, não técnica.

### O que dá para fazer de graça, ainda assim

**Modelar o processo completo sem o dado real.** O KiaDynBC já tem:
- `KINTO Fine Provider` (cadastro do provedor)
- `KINTO Fine Integration Error` (tratamento de erro com data/hora)
- `KINTO Fine Fee Setup` (valor por tipo de taxa — página criada na 1.2.0.6)

Falta só o "motor". Dá para construir um **importador de arquivo CSV/JSON** no padrão que provedores entregam. A integração fica pronta e plugável: quando houver contrato, troca-se a origem do arquivo por uma chamada HTTP. Isso demonstra arquitetura, não depende de terceiro, e é honesto.

---

## 6. CPF — dois níveis

### Nível 1: validação formal — **de graça, no AL**

O algoritmo módulo 11 valida os dois dígitos verificadores. Roda em microssegundos, sem rede, sem custo, e pega a maioria dos erros de digitação (inclusive transposição de dígitos).

**Vale implementar no KiaDynBC de qualquer forma** — é boa prática de cadastro. Hoje o `ValidateTaxId` do prospect valida unicidade, mas não sei se valida o dígito.

### Nível 2: dados do titular — **pago, sem alternativa**

Nome, situação cadastral e data de nascimento do CPF só saem pela SERPRO (Consulta CPF v3, exige e-CNPJ, e **desde 29/05/2026 exige CPF + data de nascimento**; versões antigas desativadas em 02/10/2026).

Não existe fonte pública gratuita de dados de CPF — por LGPD, e isso está correto.

---

## 7. O que eu montaria no piloto (proposta)

Ordem por **impacto demonstrado ÷ esforço**:

| # | Integração | Grátis | Esforço | O que demonstra |
|---|---|---|---|---|
| 1 | **CEP → endereço + lat/long** | ✅ | Baixo | Preenchimento automático, mapa da frota |
| 2 | **CNPJ → cliente completo** | ✅ | Baixo | Cadastro sem digitação, validação de situação |
| 3 | **FIPE → Booking Value** | ✅ | Médio | **Liga um número hoje manual a fonte oficial** |
| 4 | **Validação CPF/CNPJ local** | ✅ | Baixo | Qualidade de dado na entrada |
| 5 | **Feriados/Selic/IPCA** | ✅ | Baixo | Indexador de reajuste alimentado |
| 6 | **Importador de multas por arquivo** | ✅ | Médio | Processo completo, plugável a qualquer provedor |
| 7 | **DETRAN-SP dados abertos em tabela** | ✅ | Médio | Ingestão em lote + consulta local por placa |

Tudo isso é **zero contratação** e monta uma narrativa forte: o BC conversa com fontes oficiais brasileiras, ingere base pública em lote, e deixa o módulo de multas pronto para plugar quando o comercial fechar.

---

## O que não está claro

- **Se a KINTO já tem a base de veículos em algum sistema.** Se tiver, o item 7 perde valor.
- **Qual a UF da frota piloto.** Se for concentrada em SP, o item 7 (dados abertos DETRAN-SP) resolve; se for multi-estado, complica.
- **Se o piloto aceita dependência de projeto comunitário** (BrasilAPI/Minha Receita/parallelum) ou se exige SLA. Para piloto eu iria sem hesitar; para produção seria preciso discutir.
- **Se há certificado e-CNPJ da RSBTech disponível.** Ele destrava SERPRO e, com paciência, o credenciamento DETRAN/PR Frotista — que seria a integração oficial mais impressionante do conjunto.

## Endpoints testados nesta data

```bash
# OK — resposta real obtida
GET https://brasilapi.com.br/api/cnpj/v1/19131243000197
GET https://minhareceita.org/19131243000197
GET https://brasilapi.com.br/api/cep/v2/01310100
GET https://parallelum.com.br/fipe/api/v1/carros/marcas
GET https://parallelum.com.br/fipe/api/v1/carros/marcas/59/modelos/5585/anos/2011-3
GET https://brasilapi.com.br/api/ddd/v1/11
GET https://brasilapi.com.br/api/taxas/v1
GET https://brasilapi.com.br/api/feriados/v1/2026

# NÃO respondeu deste ambiente
GET https://viacep.com.br/ws/01310100/json/          # HTTP 000 (bloqueio de saída)
GET https://brasilapi.com.br/api/ibge/uf/v1/SP      # HTTP 504 (instabilidade da API)
```

## Fontes

- BrasilAPI: https://brasilapi.com.br/docs
- Minha Receita: https://minhareceita.org/
- ViaCEP: http://viacep.com.br/
- FIPE API (parallelum): https://deividfortuna.github.io/fipe/v2
- fipex: https://www.fipex.com.br/dados-e-api
- tabelafipe.info: https://tabelafipe.info/api-tabela-fipe
- WSDenatran (SENATRAN/SERPRO): https://www.gov.br/conecta/catalogo/apis/wsdenatran
- Consulta Placa Veicular SENATRAN: https://www.gov.br/pt-br/servicos/consultar-online-os-dados-de-placa-veicular
- DETRAN-SP Dados Abertos: https://www.detran.sp.gov.br/detransp/pb/informacoes/transparencia/dados_abertos?id=dados_abertos
- DETRAN/PR API Frotista: https://www.detran.pr.gov.br/Pagina/Frotista
- SERPRO Consulta CPF v3: https://centraldeajuda.serpro.gov.br/duvidas/pt/avisos/avisoconsultacpfv3/
