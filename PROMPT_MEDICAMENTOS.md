# Template de Prompt para Medicamentos (Aba Calculos)

**Execução:** Para um medicamento específico, use nome e id (snake_case); siga [docs/ABA_CALCULOS_WORKFLOW.md](docs/ABA_CALCULOS_WORKFLOW.md) (secção "Como executar este workflow") para cenário A ou B.  
Fluxo completo (onde salvar, checklist, remoção em Dose Rápida e Drogas): [docs/ABA_CALCULOS_WORKFLOW.md](docs/ABA_CALCULOS_WORKFLOW.md). Regra Cursor: [.cursor/rules/medicamentos-aba-calculos.mdc](.cursor/rules/medicamentos-aba-calculos.mdc).

## Como usar

1. Copie o bloco "PROMPT" abaixo.
2. Substitua `[NOME DO MEDICAMENTO]` pelo medicamento desejado (ex.: NaCl 20%, Insulina Glargina, Adrenalina) e `[id]` pelo ID em snake_case do arquivo (ex.: `sorofisiologico`, `insulina_glargina`, `adrenalina`, `eritromicina`).
3. Envie o prompt para gerar o conteudo do proximo medicamento.
4. O bulario (pagina 3) e carregado de `assets/medicamentos/[id].json` (ja existe). O arquivo de dose deve ser salvo em `assets/medicamentos_dose/[id].json`. O ID deve ser o mesmo em ambas as pastas.
5. Apos gerar, seguir o **Checklist pos-geracao** abaixo e a **Integracao no app** (remocao em Dose Rapida e Drogas); fluxo completo em [docs/ABA_CALCULOS_WORKFLOW.md](docs/ABA_CALCULOS_WORKFLOW.md). Regra Cursor: [.cursor/rules/medicamentos-aba-calculos.mdc](.cursor/rules/medicamentos-aba-calculos.mdc).

---

## Onde o app usa esse conteúdo

| O que | Onde no código / assets |
|-------|-------------------------|
| Lista de medicamentos da aba Cálculos | [medicamento_unificado_page.dart](lib/medicamento_unificado/medicamento_unificado_page.dart): lista via AssetManifest (todos os `.json` em `assets/medicamentos_dose/`). Fallback: `_medicamentosDoseFallback`. |
| Bulário (página 3) | Carregado de `assets/medicamentos/[id].json` (mesmo `id` usado no arquivo de dose). |
| Nome exibido | [medicamento_data.dart](lib/medicamento_unificado/medicamento_data.dart): prioridade em `nome` por idioma; depois primeiro item de `vistaRapida`. |

Ao adicionar um **medicamento novo**, incluir em `_medicamentosDoseFallback` o path `'assets/medicamentos_dose/[id].json'` em **ordem alfabética** (por nome do arquivo).

---

## PROMPT (copie e cole)

```
Voce e um assistente clinico especializado em farmacologia. Gere o conteudo do
medicamento abaixo para a aba "Calculos" do app Guide Dose.

===============================================================================
MEDICAMENTO: [NOME DO MEDICAMENTO]  |  ID do arquivo: [id]
===============================================================================

CONTEXTO:
- O bulario completo JA EXISTE em assets/medicamentos/[id].json (pagina 3). Voce deve gerar APENAS as paginas 1 e 2 (calculos e detalhes) + vistaRapida.
- A pagina 3 (bulario) sera carregada do JSON existente. A traducao do bulario para US/ES/ZH e um trabalho separado; nao faz parte desta geracao. Se o bulario nao tiver versao ZH (chines), a bula continua sendo carregada do JSON existente; se desejar, pode gerar tambem a versao ZH do bulario.
- Salvar resultado em assets/medicamentos_dose/[id].json (ex.: insulina_glargina.json, eritromicina.json).

VARIAVEIS DO USUARIO (usar em todos os calculos):
- peso (kg) | altura (cm) | idade (anos/meses) | sexo | creatinina (mg/dL)
- Faixas etarias: Recem-nascido (<1m), Lactente (1-12m), Crianca (1-12a),
  Adolescente (12-18a), Adulto (18-60a), Idoso (>60a)

CALCULO AUTOMATICO DO ClCr (Clearance de Creatinina):
- Formula de Cockcroft-Gault:
  * Homem: ClCr = [(140 - idade) × peso] / (72 × creatinina)
  * Mulher: ClCr = [(140 - idade) × peso] / (72 × creatinina) × 0.85
- Classificacao da funcao renal:
  * Normal: ClCr >= 90 mL/min
  * Leve (G2): ClCr 60-89 mL/min
  * Moderada (G3): ClCr 30-59 mL/min
  * Grave (G4): ClCr 15-29 mL/min
  * Terminal (G5): ClCr < 15 mL/min ou dialise

REGRAS:
1. NAO inovar no layout - seguir padrao da Adrenalina (ver exemplo no arquivo).
2. Ordem das secoes: pagina1 (indicacoes, slidersInfusao); pagina2 (classe, apresentacoes, preparo, observacoes em 6 itens, ajustesEspeciais).
3. Ordem no JSON (como o app usa): pagina1: indicacoes, slidersInfusao; pagina2: classe, apresentacoes, preparo, ajustesEspeciais, observacoes (6 observacoes).
4. Entregar em 4 idiomas: PT, US, ES, ZH (chaves de primeiro nivel identicas). O app exibe "CH" na UI mas le o idioma chines da chave "ZH" no JSON; use sempre "ZH".
5. CAMPOS TIPO ENUM (manter os MESMOS valores em todos os idiomas; o app filtra por esses textos): faixaEtaria ("Adulto" | "Pediatrico" | "Todas"), sexo ("Todos" | "Masculino" | "Feminino"), via ("IV" | "IM" | "SC" | "VO" | "IO" | "IV/IO"), tipoDose ("fixa" | "calculada" | "infusao"), unidade (ex.: "mg", "mcg", "mcg/min", "mcg/kg/min"). Traduzir apenas titulos, descricoes, classe, apresentacoes, preparo, observacoes, ajustesEspeciais e nome do medicamento.

===============================================================================
TIPOS DE INDICACOES
===============================================================================

1. FIXA: Dose fixa (ex: "1 mg IV")
   - tipoDose: "fixa"
   - doseFixa: "1 mg" (string com o valor)
   - dosePorKg: null

2. CALCULADA: Dose por peso (ex: "0,01 mg/kg")
   - tipoDose: "calculada"
   - dosePorKg: 0.01 (numero)
   - doseMaxima: valor maximo (se houver)
   - doseFixa: null

2b. CALCULADA COM FAIXA: Dose por peso com faixa por TOMADA (ex: 80-100 mg/kg/dia em 4 doses = 20-25 mg/kg por tomada)
   - tipoDose: "calculada"
   - dosePorKg: null
   - dosePorKgMin: 20, dosePorKgMax: 25 (valores por tomada; o intervalo descreve a frequencia, ex.: "4x/dia", "a cada 6h")
   - doseMaxima: limite total por tomada (ex: 1000 mg)
   - doseFixa: null

3. INFUSAO COM DOSE FIXA: mcg/min (ex: Bradicardia)
   - tipoDose: "infusao"
   - unidade: "mcg/min" (SEM /kg)
   - doseMin/doseMax: faixa de dose (ex: 2-10)
   - Gera SLIDER PROPRIO com conversao para mL/h

4. INFUSAO POR PESO: mcg/kg/min (ex: Choque)
   - tipoDose: "infusao"
   - unidade: "mcg/kg/min" (COM /kg)
   - doseMin/doseMax: faixa de dose (ex: 0.01-0.5)
   - Usa o SLIDER PRINCIPAL (slidersInfusao)

===============================================================================
AJUSTE RENAL
===============================================================================

O campo "ajusteRenal" usa formato SIMPLES (string + campos numericos opcionais):

FORMATO:
{
  "parametros": {
    ...
    "ajusteRenal": "ClCr <30: reduzir 50%",  // STRING descritiva
    "clCrThreshold": 30,                      // NUMERO: limiar de ClCr para ajuste
    "fatorAjusteRenal": 0.5                   // NUMERO: fator de multiplicacao (0.5 = 50%)
  }
}

EXEMPLOS:

1. Medicamento COM ajuste renal:
   "ajusteRenal": "ClCr <30: reduzir 50%",
   "clCrThreshold": 30,
   "fatorAjusteRenal": 0.5

2. Medicamento COM ajuste renal mais detalhado:
   "ajusteRenal": "ClCr 30-59: reduzir 25%; ClCr <30: reduzir 50%",
   "clCrThreshold": 30,
   "fatorAjusteRenal": 0.5

3. Medicamento SEM ajuste renal:
   "ajusteRenal": "NAO"
   // Sem clCrThreshold e fatorAjusteRenal

LOGICA DE CALCULO NO APP:
- Se clCrThreshold definido E ClCr do paciente < clCrThreshold:
  doseAjustada = doseOriginal × fatorAjusteRenal
- Exibir texto de ajusteRenal como informacao ao usuario

===============================================================================
FORMATO DE SAIDA
===============================================================================

{
  "PT": {
    "nome": "Nome do Medicamento",
    "pagina1": {
      "indicacoes": [
        {
          "titulo": "Nome da indicacao",
          "descricaoDose": "Dose completa com unidade e intervalo",
          "tipoDose": "fixa | calculada | infusao",
          "parametros": {
            "unidade": "mg | mcg | mcg/min | mcg/kg/min",
            "dosePorKg": null,
            "dosePorKgMin": null,
            "dosePorKgMax": null,
            "doseMin": null,
            "doseMax": null,
            "doseMaxima": null,
            "doseFixa": "string ou null",
            "faixaEtaria": "Adulto | Pediatrico | Todas",
            "sexo": "Masculino | Feminino | Todos",
            "via": "IV | IM | SC | VO | IO",
            "intervalo": "dose unica | a cada Xh | infusao continua",
            "ajusteRenal": "NAO | ClCr <X: reduzir Y%",
            "ajusteHepatico": "NAO | Child B/C: reduzir Y%",
            "clCrThreshold": null,
            "fatorAjusteRenal": null
          }
        }
      ],
      "slidersInfusao": [
        {
          "titulo": "Infusao Continua",
          "unidade": "mcg/kg/min",
          "adulto": { "doseMin": 0.05, "doseMax": 0.5 },
          "pediatrico": { "doseMin": 0.05, "doseMax": 0.3 },
          "concentracaoEmMcg": true,
          "fatorTempo": 60,
          "opcoesConcentracao": [
            { "rotulo": "10mg em 50mL SF (200 mcg/mL)", "valor": 200 },
            { "rotulo": "1mg em 50mL SF (20 mcg/mL)", "valor": 20 },
            { "rotulo": "1mg em 100mL SF (10 mcg/mL)", "valor": 10 },
            { "rotulo": "1mg em 250mL SF (4 mcg/mL)", "valor": 4 }
          ]
        }
      ]
    },
    "pagina2": {
      "classe": "Classe farmacologica",
      "apresentacoes": [
        { "forma": "Ampola 1mg/mL", "obs": "1:1000" }
      ],
      "preparo": [
        { "diluicao": "1mg + 100mL SF", "concentracao": "10 mcg/mL" }
      ],
      "observacoes": [
        "Obs critica 1",
        "Obs critica 2",
        "Obs critica 3",
        "Obs critica 4",
        "Obs critica 5",
        "Obs critica 6"
      ],
      "ajustesEspeciais": {
        "idoso": "Texto ajuste idoso",
        "renal": "Texto ajuste renal (ex: DRC: reduzir 50% se ClCr <30)",
        "hepatico": "Texto ajuste hepatico"
      }
    },
    "vistaRapida": [
      {
        "nome": "Nome (adulto)",
        "doseTexto": "1 mg IV a cada 3-5 min",
        "doseMin": null,
        "doseMax": null,
        "unidadeResultado": "mg",
        "decimais": 0,
        "resultadoFixo": "1 mg",
        "faixaEtaria": "Adulto"
      }
    ]
  },
  "US": { "nome": "...", "pagina1": { ... }, "pagina2": { ... }, "vistaRapida": [ ... ] },
  "ES": { "nome": "...", "pagina1": { ... }, "pagina2": { ... }, "vistaRapida": [ ... ] },
  "ZH": { "nome": "...", "pagina1": { ... }, "pagina2": { ... }, "vistaRapida": [ ... ] }
}

===============================================================================
CALCULO DOS SLIDERS DE INFUSAO
===============================================================================

Formula para converter dose em mL/h:

1. Infusao por peso (mcg/kg/min):
   mL/h = (dose × peso × 60) / concentracao

2. Infusao dose fixa (mcg/min):
   mL/h = (dose × 60) / concentracao

3. Infusao em g/h (ex: sulfato de magnesio):
   mL/h = (dose × 1000) / concentracao
   Usar fatorTempo: 1 (em vez de 60)

Onde:
- dose: valor selecionado no slider
- peso: peso do paciente em kg
- concentracao: valor em mcg/mL (ou mg/mL) da diluicao selecionada
- 60: conversao de minutos para hora (fatorTempo padrao)

===============================================================================
CALCULO DO CLEARANCE DE CREATININA (ClCr)
===============================================================================

Formula de Cockcroft-Gault (padrao clinico):

1. Homem:
   ClCr (mL/min) = [(140 - idade) × peso] / (72 × creatinina)

2. Mulher:
   ClCr (mL/min) = [(140 - idade) × peso] / (72 × creatinina) × 0.85

Onde:
- idade: anos
- peso: kg (usar peso real; para obesos usar peso ajustado)
- creatinina: mg/dL

PESO AJUSTADO PARA OBESOS (IMC > 30):
  pesoAjustado = pesoIdeal + 0.4 × (pesoReal - pesoIdeal)
  pesoIdeal (Homem) = 50 + 0.9 × (altura_cm - 152)
  pesoIdeal (Mulher) = 45.5 + 0.9 × (altura_cm - 152)

PEDIATRICO (formula de Schwartz):
  ClCr (mL/min/1.73m²) = (k × altura_cm) / creatinina
  - k = 0.33 (prematuros)
  - k = 0.45 (RN a termo ate 1 ano)
  - k = 0.55 (criancas 1-12 anos)
  - k = 0.70 (adolescentes masculinos)
  - k = 0.55 (adolescentes femininas)

===============================================================================
NOTAS IMPORTANTES
===============================================================================

- ID vs nome: "nome" e o texto exibido no app (traduzido por idioma). O ID e o nome do arquivo em snake_case (ex.: eritromicina.json); nao vai dentro do JSON.
- Manter faixaEtaria, sexo, via, tipoDose e unidade com os mesmos valores em PT/US/ES/ZH (ver REGRAS item 4).
- Se nao houver infusao continua: "slidersInfusao": []
- Se nao houver ajuste renal: ajusteRenal: "NAO" (sem clCrThreshold)
- Se nao houver ajuste hepatico: ajusteHepatico: "NAO"
- Valores numericos = numeros, textos = strings
- Minimo 1 indicacao adulto + 1 pediatrica (se aplicavel)
- IMPORTANTE: Incluir campo "nome" em cada idioma para exibicao correta no app.
- Se for antibiotico, nao esquecer profilaxia cirurgica se houver (ex.: cefalosporina em cirurgia limpa).
- Fontes: Miller, Stoelting, ACLS/PALS, UpToDate, Micromedex

Gere agora para: [NOME DO MEDICAMENTO] (id do arquivo: [id]).
```

---

## Exemplo Completo: Adrenalina

O arquivo completo esta em `assets/medicamentos_dose/adrenalina.json`.

```json
{
  "PT": {
    "nome": "Adrenalina",
    "pagina1": {
      "indicacoes": [
        {
          "titulo": "PCR (ACLS)",
          "descricaoDose": "1mg IV/IO a cada 3-5 min",
          "tipoDose": "fixa",
          "parametros": {
            "unidade": "mg",
            "dosePorKg": null,
            "doseMin": null,
            "doseMax": null,
            "doseMaxima": 1,
            "doseFixa": "1 mg",
            "faixaEtaria": "Adulto",
            "sexo": "Todos",
            "via": "IV/IO",
            "intervalo": "a cada 3-5 min",
            "ajusteRenal": "NAO",
            "ajusteHepatico": "NAO"
          }
        },
        {
          "titulo": "Anafilaxia",
          "descricaoDose": "0,3-0,5mg IM face lateral da coxa",
          "tipoDose": "fixa",
          "parametros": {
            "unidade": "mg",
            "dosePorKg": null,
            "doseMin": 0.3,
            "doseMax": 0.5,
            "doseMaxima": 0.5,
            "doseFixa": "0,3-0,5 mg IM",
            "faixaEtaria": "Adulto",
            "sexo": "Todos",
            "via": "IM",
            "intervalo": "a cada 5-15 min se necessario",
            "ajusteRenal": "NAO",
            "ajusteHepatico": "NAO"
          }
        },
        {
          "titulo": "Bradicardia sintomatica",
          "descricaoDose": "2-10 mcg/min IV infusao",
          "tipoDose": "infusao",
          "parametros": {
            "unidade": "mcg/min",
            "dosePorKg": null,
            "doseMin": 2,
            "doseMax": 10,
            "doseMaxima": null,
            "doseFixa": "2-10 mcg/min",
            "faixaEtaria": "Adulto",
            "sexo": "Todos",
            "via": "IV",
            "intervalo": "infusao continua",
            "ajusteRenal": "NAO",
            "ajusteHepatico": "NAO"
          }
        },
        {
          "titulo": "Choque (vasopressor)",
          "descricaoDose": "0,01-0,5 mcg/kg/min - titular conforme PAM",
          "tipoDose": "infusao",
          "parametros": {
            "unidade": "mcg/kg/min",
            "dosePorKg": null,
            "doseMin": 0.01,
            "doseMax": 0.5,
            "doseMaxima": null,
            "doseFixa": null,
            "faixaEtaria": "Adulto",
            "sexo": "Todos",
            "via": "IV",
            "intervalo": "infusao continua",
            "ajusteRenal": "NAO",
            "ajusteHepatico": "NAO"
          }
        },
        {
          "titulo": "PCR (PALS)",
          "descricaoDose": "0,01mg/kg IV/IO a cada 3-5 min (max 1mg)",
          "tipoDose": "calculada",
          "parametros": {
            "unidade": "mg",
            "dosePorKg": 0.01,
            "doseMin": null,
            "doseMax": null,
            "doseMaxima": 1,
            "doseFixa": null,
            "faixaEtaria": "Pediatrico",
            "sexo": "Todos",
            "via": "IV/IO",
            "intervalo": "a cada 3-5 min",
            "ajusteRenal": "NAO",
            "ajusteHepatico": "NAO"
          }
        },
        {
          "titulo": "Anafilaxia pediatrica",
          "descricaoDose": "0,01mg/kg IM (max 0,3mg)",
          "tipoDose": "calculada",
          "parametros": {
            "unidade": "mg",
            "dosePorKg": 0.01,
            "doseMin": null,
            "doseMax": null,
            "doseMaxima": 0.3,
            "doseFixa": null,
            "faixaEtaria": "Pediatrico",
            "sexo": "Todos",
            "via": "IM",
            "intervalo": "a cada 5-15 min se necessario",
            "ajusteRenal": "NAO",
            "ajusteHepatico": "NAO"
          }
        },
        {
          "titulo": "Choque pediatrico",
          "descricaoDose": "0,05-0,3 mcg/kg/min IV continua",
          "tipoDose": "infusao",
          "parametros": {
            "unidade": "mcg/kg/min",
            "dosePorKg": null,
            "doseMin": 0.05,
            "doseMax": 0.3,
            "doseMaxima": null,
            "doseFixa": null,
            "faixaEtaria": "Pediatrico",
            "sexo": "Todos",
            "via": "IV",
            "intervalo": "infusao continua",
            "ajusteRenal": "NAO",
            "ajusteHepatico": "NAO"
          }
        }
      ],
      "slidersInfusao": [
        {
          "titulo": "Infusao Continua",
          "unidade": "mcg/kg/min",
          "adulto": { "doseMin": 0.05, "doseMax": 0.5 },
          "pediatrico": { "doseMin": 0.05, "doseMax": 0.3 },
          "concentracaoEmMcg": true,
          "opcoesConcentracao": [
            { "rotulo": "10mg em 50mL SF 0,9% (200 mcg/mL)", "valor": 200 },
            { "rotulo": "1mg em 50mL SF 0,9% (20 mcg/mL)", "valor": 20 },
            { "rotulo": "1mg em 100mL SF 0,9% (10 mcg/mL)", "valor": 10 },
            { "rotulo": "1mg em 250mL SF 0,9% (4 mcg/mL)", "valor": 4 }
          ]
        }
      ]
    },
    "pagina2": {
      "classe": "Vasopressor - Simpatomimetico alfa e beta-adrenergico",
      "apresentacoes": [
        { "forma": "Ampola 1mg/mL (1mL)", "obs": "1:1000" },
        { "forma": "Ampola 1mg/10mL", "obs": "1:10.000 - para uso IV" },
        { "forma": "Auto-injetor 0,3mg", "obs": "Adulto - anafilaxia" },
        { "forma": "Auto-injetor 0,15mg", "obs": "Pediatrico - anafilaxia" }
      ],
      "preparo": [
        { "diluicao": "10mg + 50mL SF", "concentracao": "200 mcg/mL" },
        { "diluicao": "1mg + 50mL SF", "concentracao": "20 mcg/mL" },
        { "diluicao": "1mg + 100mL SF", "concentracao": "10 mcg/mL" },
        { "diluicao": "1mg + 250mL SF", "concentracao": "4 mcg/mL" }
      ],
      "observacoes": [
        "Primeira linha em PCR e anafilaxia",
        "Meia-vida ultracurta: 2-3 minutos",
        "Usar preferencialmente via central (risco de necrose)",
        "Monitorizar ECG continuo (risco de arritmias)",
        "Dose de anafilaxia: sempre IM, nunca IV em bolus",
        "Incompativel com bicarbonato na mesma via"
      ],
      "ajustesEspeciais": {
        "idoso": "Sem ajuste especifico. Monitorar efeitos cardiovasculares.",
        "renal": "Nao requer ajuste. Meia-vida ultracurta, nao dializavel.",
        "hepatico": "Usar com cautela em insuficiencia hepatica grave."
      }
    },
    "vistaRapida": [
      {
        "nome": "Adrenalina (adulto)",
        "doseTexto": "1 mg IV a cada 3-5 min",
        "doseMin": null,
        "doseMax": null,
        "unidadeResultado": "mg",
        "decimais": 0,
        "resultadoFixo": "1 mg",
        "faixaEtaria": "Adulto"
      },
      {
        "nome": "Adrenalina (pediatrico)",
        "doseTexto": "0,01 mg/kg IV/IO (max 1 mg)",
        "doseMin": 0.01,
        "doseMax": null,
        "unidadeResultado": "mg",
        "decimais": 2,
        "resultadoFixo": null,
        "faixaEtaria": "Pediatrico"
      },
      {
        "nome": "Adrenalina IM - Anafilaxia",
        "doseTexto": "0,3-0,5 mg IM",
        "doseMin": null,
        "doseMax": null,
        "unidadeResultado": "mg",
        "decimais": 1,
        "resultadoFixo": "0,3-0,5 mg",
        "faixaEtaria": "Adulto"
      },
      {
        "nome": "Adrenalina IM - Anafilaxia (ped)",
        "doseTexto": "0,01 mg/kg IM (max 0,3 mg)",
        "doseMin": 0.01,
        "doseMax": null,
        "unidadeResultado": "mg",
        "decimais": 2,
        "resultadoFixo": null,
        "faixaEtaria": "Pediatrico"
      }
    ]
  }
}
```

---

## Exemplo com Ajuste Renal: Sulfato de Magnesio

```json
{
  "titulo": "Eclampsia - Ataque",
  "descricaoDose": "4-6 g IV em 20-30 min",
  "tipoDose": "fixa",
  "parametros": {
    "unidade": "g",
    "dosePorKg": null,
    "doseMin": 4,
    "doseMax": 6,
    "doseMaxima": 6,
    "doseFixa": "4-6 g",
    "faixaEtaria": "Adulto",
    "sexo": "Todos",
    "via": "IV",
    "intervalo": "dose unica",
    "ajusteRenal": "ClCr <30: reduzir 50%",
    "ajusteHepatico": "NAO",
    "clCrThreshold": 30,
    "fatorAjusteRenal": 0.5
  }
}
```

---

## Exemplo com Dose Calculada com Faixa: AAS (Kawasaki)

Para indicacoes com dose por kg em faixa (ex: 80-100 mg/kg/dia em 4 doses = 20-25 mg/kg por tomada):

```json
{
  "titulo": "Kawasaki - fase aguda (pediatrico)",
  "descricaoDose": "80-100 mg/kg/dia em 4 doses",
  "tipoDose": "calculada",
  "parametros": {
    "unidade": "mg",
    "dosePorKg": null,
    "dosePorKgMin": 20,
    "dosePorKgMax": 25,
    "doseMin": null,
    "doseMax": null,
    "doseMaxima": 1000,
    "doseFixa": null,
    "faixaEtaria": "Pediatrico",
    "sexo": "Todos",
    "via": "VO",
    "intervalo": "4x/dia",
    "ajusteRenal": "Contraindicado em IR grave. Cautela em IR.",
    "ajusteHepatico": "Cautela em hepatopatia grave."
  }
}
```

---

## Resumo dos Tipos de Indicacao

| Tipo | tipoDose | unidade | Comportamento no App |
|------|----------|---------|---------------------|
| Dose fixa | `fixa` | mg, mcg | Mostra titulo + descricao + doseFixa |
| Dose calculada | `calculada` | mg, mcg | Calcula: dosePorKg × peso |
| Dose calculada com faixa | `calculada` | mg, mcg | Calcula: dosePorKgMin × peso a dosePorKgMax × peso |
| Infusao fixa | `infusao` | mcg/min | Slider proprio: titulo + dropdown + slider + mL/h |
| Infusao por kg | `infusao` | mcg/kg/min | Usa slider principal (slidersInfusao) |

---

## Checklist pos-geracao

- [ ] JSON valido (testar em jsonlint.com)
- [ ] 4 idiomas presentes (PT, US, ES, ZH); certifique que todas as paginas (pagina1, pagina2, vistaRapida) estao completas em cada um dos 4 idiomas
- [ ] Campo "nome" presente em cada idioma
- [ ] Todas as indicacoes tem faixaEtaria definida
- [ ] Infusoes com mcg/min tem doseMin e doseMax
- [ ] Infusoes com mcg/kg/min tem slider correspondente
- [ ] Sliders tem adulto e pediatrico separados
- [ ] opcoesConcentracao inclui diluicoes praticas
- [ ] 6 observacoes clinicas preenchidas
- [ ] Ajustes especiais (idoso, renal, hepatico) preenchidos como STRINGS
- [ ] vistaRapida com entradas separadas adulto/pediatrico
- [ ] ajusteRenal como STRING (ex: "ClCr <30: reduzir 50%" ou "NAO"); clCrThreshold e fatorAjusteRenal apenas se houver ajuste renal
- [ ] dosePorKgMin/dosePorKgMax para doses calculadas com faixa (ex: Kawasaki 20-25 mg/kg)
- [ ] Bulário: usar e, se necessário, melhorar `assets/medicamentos/[id].json` para a página 3
- [ ] Salvar em `assets/medicamentos_dose/[id].json`
- [ ] **Após concluir a criação:** apagar o medicamento de Highlight (dose rápida) e da aba Drogas (ver "Integração no app" abaixo)
- [ ] **Se o medicamento já existir em medicamentos_dose:** apenas apagar de Highlight e Drogas onde constar e pedir ao usuário para chamar o próximo medicamento

---

## Ao adicionar novo medicamento

1. **Bulário primeiro:** Garantir que existe `assets/medicamentos/[id].json` (bulário) antes de criar `assets/medicamentos_dose/[id].json`. O bulário (página 3) é carregado de `assets/medicamentos/`.
2. **Nome do arquivo:** Usar snake_case para o ID (ex: `acido_acetilsalicilico.json` ou `aas.json`). O ID deve ser consistente em ambas as pastas.
3. **Fallback:** Se o app usar fallback de lista, incluir o novo medicamento em `_medicamentosDoseFallback` em `lib/medicamento_unificado/medicamento_unificado_page.dart` em **ordem alfabética** (por nome do arquivo) para garantir visibilidade antes do rebuild.
4. **pubspec.yaml:** Os assets `assets/medicamentos/` e `assets/medicamentos_dose/` ja estao declarados; novos arquivos dentro dessas pastas sao incluidos automaticamente.

---

## Integração no app (após gerar o JSON)

Para evitar duplicidade, **remover** o medicamento da aba Highlight (Dose Rápida) e da aba Medicamentos (drogas) quando o mesmo já estiver na aba Cálculos via `medicamentos_dose/[id].json`.

### 1. Remover da Dose Rápida (Highlight)

- Arquivos: todos em `lib/doses_rapidas_page/*.dart` (ex.: `antidotos.dart`, `vasopressores_bolus.dart`, `outros.dart`, `antibioticos_iv.dart`, `antiarritmicos.dart`, etc.).
- Ação: procurar por `_DoseRapidaItem` cujo campo `nome` corresponda ao medicamento (ex.: `nome: 'Adrenalina'`) e **remover o bloco inteiro** (incluindo a vírgula) em cada arquivo onde aparecer.
- As listas são agregadas em `_todasAsDoses()` em `lib/doses_rapidas_page.dart`; não é necessário editar esse arquivo ao remover itens.

### 2. Remover das Drogas (cards antigos)

- **Lista de cards:** `lib/drogas_card/drogas.dart`
  - Em `_medicamentos`, localizar o(s) item(ns) cujo `'nome'` coincide com o medicamento (ex.: `MedicamentoAdrenalina.nome`).
  - Remover o(s) elemento(s) do array (o objeto `{ 'nome': ..., 'builder': ... }` inteiro).
  - Remover o **import** correspondente (ex.: `import 'vasopressores_hipotensores/adrenalina.dart' show MedicamentoAdrenalina;`).
- **Registry (navegação Dose Rápida → card):** `lib/drogas_card/medicamentos_registry.dart`
  - Remover todas as entradas de `medicamentosRegistry` que apontam para esse medicamento (incluindo aliases, ex.: `'adrenalina'` e `'epinefrina'`).
  - Remover o **import** do arquivo do card (ex.: `import 'vasopressores_hipotensores/adrenalina.dart' show MedicamentoAdrenalina;`).
- (Opcional) Excluir o arquivo do card em `lib/drogas_card/...` (ex.: `vasopressores_hipotensores/adrenalina.dart`). Se outros arquivos importarem esse card, remover ou ajustar referências.

### 3. Cenários ao finalizar

**Cenário A – Medicamento novo (acabou de ser criado em medicamentos_dose):**

1. Garantir bulário em `assets/medicamentos/[id].json` (criar ou melhorar).
2. Salvar `assets/medicamentos_dose/[id].json`.
3. Adicionar entrada em `_medicamentosDoseFallback` em `lib/medicamento_unificado/medicamento_unificado_page.dart` (ordem alfabética).
4. Remover o medicamento da Highlight e da Drogas (passos 1 e 2 acima).
5. Seguir para o próximo medicamento quando quiser.

**Cenário B – Medicamento já existe em medicamentos_dose:**

1. Não criar nem alterar o JSON de dose.
2. Apenas remover o medicamento da Highlight e da Drogas (passos 1 e 2 acima).
3. Pedir ao usuário para chamar o próximo medicamento.

**Resumo dos arquivos e fluxo:** ver [docs/ABA_CALCULOS_WORKFLOW.md](docs/ABA_CALCULOS_WORKFLOW.md) (tabela na secção 7; cenários A/B na secção 5; remoção Dose Rápida e Drogas nas secções 4.1 e 4.2). Regra do Cursor: [.cursor/rules/medicamentos-aba-calculos.mdc](.cursor/rules/medicamentos-aba-calculos.mdc).
