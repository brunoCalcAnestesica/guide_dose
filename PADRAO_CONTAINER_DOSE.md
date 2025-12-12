# Padrão para Containers de Dose - Medicamentos

## Regras Gerais
1. **Todos os containers de dose devem ocupar toda a largura horizontal disponível.**
2. **Priorizar medicamentos IV e IM sobre VO na estruturação das indicações.**

## Implementação

### Para Cálculos de Dose por Peso (mg/kg)
```dart
static Widget _buildCalculoDose(double peso, double doseMinima, double doseMaxima) {
  final doseCalculadaMin = (peso * doseMinima).round();
  final doseCalculadaMax = (peso * doseMaxima).round();
  
  return SizedBox(
    width: double.infinity,  // ← OBRIGATÓRIO: Ocupa toda largura
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cálculo para ${peso.toStringAsFixed(1)} kg:',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '${doseCalculadaMin}-${doseCalculadaMax} mg',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
          ),
          Text(
            '(${doseMinima.toStringAsFixed(1)}-${doseMaxima.toStringAsFixed(1)} mg/kg × ${peso.toStringAsFixed(1)} kg)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    ),
  );
}
```

### Para Doses Fixas
```dart
static Widget _buildCalculoDoseFixa(double doseMinima, double doseMaxima) {
  return SizedBox(
    width: double.infinity,  // ← OBRIGATÓRIO: Ocupa toda largura
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dose fixa:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '${doseMinima.toStringAsFixed(1)}-${doseMaxima.toStringAsFixed(1)} mg',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
          ),
        ],
      ),
    ),
  );
}
```

### Para Conversores de Infusão
```dart
static Widget _buildConversorInfusao() {
  return SizedBox(
    width: double.infinity,  // ← OBRIGATÓRIO: Ocupa toda largura
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conteúdo do conversor...
        ],
      ),
    ),
  );
}
```

## Pontos Importantes

1. **Sempre usar `SizedBox(width: double.infinity)`** como wrapper do Container
2. **Manter `crossAxisAlignment: CrossAxisAlignment.start`** no Column interno
3. **Usar cores consistentes**:
   - Azul para cálculos por peso
   - Verde para doses fixas
   - Laranja para conversores
4. **Padding de 8px** para containers simples, **12px** para conversores
5. **Border radius de 6px** para containers simples, **8px** para conversores

### Para Priorização de Vias de Administração
```dart
static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
  List<Map<String, dynamic>> indicacoes = [];
  
  // Adicionar indicações com campo 'prioridade' e 'via'
  indicacoes = [
    {
      'titulo': 'Indicação IV',
      'descricaoDose': '250-500 mg IV, dose única',
      'doseMinima': 250.0,
      'doseMaxima': 500.0,
      'unidade': 'mg',
      'via': 'IV',
      'prioridade': 1  // ← Prioridade 1 para IV/IM
    },
    {
      'titulo': 'Indicação VO',
      'descricaoDose': '125-250 mg VO 2-4x/dia',
      'doseMinima': 125.0,
      'doseMaxima': 250.0,
      'unidade': 'mg',
      'via': 'VO',
      'prioridade': 2  // ← Prioridade 2 para VO
    }
  ];
  
  // Ordenar por prioridade: IV/IM primeiro, depois VO
  indicacoes.sort((a, b) {
    final prioridadeA = a['prioridade'] ?? 3;
    final prioridadeB = b['prioridade'] ?? 3;
    return prioridadeA.compareTo(prioridadeB);
  });
  
  return indicacoes.map<Widget>((indicacao) {
    // Construir widget da indicação...
  }).toList();
}
```

## Sistema de Priorização

### Níveis de Prioridade
- **Prioridade 1**: IV (intravenosa) e IM (intramuscular)
- **Prioridade 2**: VO (via oral)
- **Prioridade 3**: Outras vias (subcutânea, tópica, etc.)

### Implementação
1. **Adicionar campos `via` e `prioridade`** em cada indicação
2. **Usar `indicacoes.sort()`** para ordenar por prioridade
3. **IV/IM sempre aparecem primeiro** na lista de indicações
4. **VO aparece depois** das vias parenterais

## Aplicação
Este padrão deve ser aplicado em **TODOS** os medicamentos, tanto nos existentes quanto nos futuros.
