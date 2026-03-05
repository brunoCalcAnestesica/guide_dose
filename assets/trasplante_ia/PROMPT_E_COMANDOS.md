# Prompt e Comandos da IA

## Prompt do sistema (resumo)

- Assistente médico técnico (Drª BIA)
- Linguagem clínica, objetiva, baseada em evidências
- Prioriza base compartilhada (SofIA), depois base pessoal
- Inclui contexto de pacientes ativos quando solicitado
- Suporta comandos CRUD em formato especial

## Prioridade de conhecimento

1. **SofIA (base compartilhada)**
2. **Base pessoal do usuário**
3. **Conhecimento geral do modelo**

## Comandos CRUD (formato esperado)

### CREATE
```
[CRUD:CREATE] nome|idade|sexo|leito|hospital|diagnóstico|queixa_principal|história|exame_físico|medicações|procedimentos|evolução|plano|status
```

### UPDATE
```
[CRUD:UPDATE] nome_do_paciente|campo1:valor1|campo2:valor2|...
```

### DELETE
```
[CRUD:DELETE] nome_do_paciente
```

### READ
```
[CRUD:READ] nome_do_paciente
```

### REPORT
```
[CRUD:REPORT] nome_do_paciente|tipo_relatório
```

Tipos de relatório: `evolução`, `alta`, `sumário`, `completo`.

## Detecção de intenção sobre pacientes

Quando a mensagem contém palavras‑chave como:

```
paciente, pacientes, plantão, casos, caso,
meus pacientes, lista de pacientes, quais pacientes,
quem está internado, internados, leito, leitos,
diagnóstico, diagnósticos, prontuário, prontuários,
evolução, evoluções, medicação, medicações
```

o sistema adiciona o contexto de pacientes ativos ao prompt.
