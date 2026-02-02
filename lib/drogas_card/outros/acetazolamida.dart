import 'package:flutter/material.dart';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAcetazolamida {
  static const String nome = 'Acetazolamida';
  static const String idBulario = 'acetazolamida';

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    // Verificar se há indicações para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink(); // Não exibe o card se não há indicações
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAcetazolamida(context, peso, faixaEtaria),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Card aparece apenas para Criança, Adolescente, Adulto e Idoso
    return faixaEtaria == 'Criança' || 
           faixaEtaria == 'Adolescente' || 
           faixaEtaria == 'Adulto' || 
           faixaEtaria == 'Idoso';
  }

  static Widget _buildCardAcetazolamida(BuildContext context, double peso, String faixaEtaria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // CLASSE
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Inibidor da anidrase carbônica', 'Diurético, antiglaucomatoso'),
        
        const SizedBox(height: 16),
        
        // APRESENTAÇÕES
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimidos 250 mg', 'Diamox®, genérico'),
        _linhaPreparo('Ampola 500 mg/5 mL', 'Uso IV'),
        
        const SizedBox(height: 16),
        
        // PREPARO
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Via oral', 'Comprimidos inteiros com água'),
        _linhaPreparo('Via IV', 'Diluir 500 mg em 5-10 mL de SF 0,9% ou SG 5%'),
        _linhaPreparo('Infusão', 'Diluir em 100-250 mL de SF 0,9% ou SG 5%'),
        _linhaPreparo('Administração', '5-10 minutos'),
        
        const SizedBox(height: 16),
        
        // INDICAÇÕES
        Text('Indicações ($faixaEtaria)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        
        const SizedBox(height: 16),
        
        // INFUSÃO CONTÍNUA
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Não recomendada', 'Uso intermitente preferível'),
        _linhaPreparo('Diluição', 'SF 0,9% ou SG 5%'),
        _linhaPreparo('Velocidade', '5-10 minutos'),
        
        const SizedBox(height: 16),
        
        // OBSERVAÇÕES
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Mecanismo: Inibe anidrase carbônica, reduz produção de humor aquoso'),
        _textoObs('Farmacocinética: Início 30-60 min (oral), 2-5 min (IV). Meia-vida: 2-4h'),
        _textoObs('Efeitos adversos: Parestesias, alterações do paladar, náuseas, acidose metabólica'),
        _textoObs('Contraindicações: Insuficiência renal grave, hipocalemia, acidose metabólica'),
        _textoObs('Ajuste renal: Contraindicado ClCr <30 mL/min. Reduzir 50% se ClCr 30-60 mL/min'),
        _textoObs('Ajuste hepático: Reduzir 50% em insuficiência hepática'),
        _textoObs('Interações: Diuréticos (hipocalemia), digoxina, fenitoína, salicilatos'),
        _textoObs('Monitoramento: Eletrólitos, pH, função renal, pressão intraocular'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
    List<Map<String, dynamic>> indicacoes = [];
    
    if (faixaEtaria == 'Criança' || faixaEtaria == 'Adolescente') {
      indicacoes = [
        {
          'titulo': 'Epilepsia (adjuvante)',
          'descricaoDose': '8-30 mg/kg/dia VO dividido em 1-4 doses',
          'dosePorKgMinima': 8.0,
          'dosePorKgMaxima': 30.0,
          'unidade': 'mg/kg/dia',
          'via': 'VO',
          'prioridade': 2
        },
        {
          'titulo': 'Edema',
          'descricaoDose': '5 mg/kg/dia VO',
          'dosePorKgMinima': 5.0,
          'dosePorKgMaxima': 5.0,
          'unidade': 'mg/kg/dia',
          'via': 'VO',
          'prioridade': 2
        }
      ];
    } else if (faixaEtaria == 'Adulto') {
      indicacoes = [
        {
          'titulo': 'Glaucoma agudo de ângulo fechado',
          'descricaoDose': '250-500 mg IV, dose única',
          'doseMinima': 250.0,
          'doseMaxima': 500.0,
          'unidade': 'mg',
          'via': 'IV',
          'prioridade': 1
        },
        {
          'titulo': 'Glaucoma crônico',
          'descricaoDose': '125-250 mg VO 2-4x/dia',
          'doseMinima': 125.0,
          'doseMaxima': 250.0,
          'unidade': 'mg',
          'via': 'VO',
          'prioridade': 2
        },
        {
          'titulo': 'Edema',
          'descricaoDose': '250-375 mg VO 1x/dia (manhã)',
          'doseMinima': 250.0,
          'doseMaxima': 375.0,
          'unidade': 'mg',
          'via': 'VO',
          'prioridade': 2
        },
        {
          'titulo': 'Epilepsia (adjuvante)',
          'descricaoDose': '8-30 mg/kg/dia VO dividido em 1-4 doses',
          'dosePorKgMinima': 8.0,
          'dosePorKgMaxima': 30.0,
          'unidade': 'mg/kg/dia',
          'via': 'VO',
          'prioridade': 2
        },
        {
          'titulo': 'Mal da altitude',
          'descricaoDose': '125-250 mg VO 2x/dia',
          'doseMinima': 125.0,
          'doseMaxima': 250.0,
          'unidade': 'mg',
          'via': 'VO',
          'prioridade': 2
        }
      ];
    } else if (faixaEtaria == 'Idoso') {
      indicacoes = [
        {
          'titulo': 'Glaucoma agudo de ângulo fechado',
          'descricaoDose': '125-250 mg IV, dose única (reduzir 50%)',
          'doseMinima': 125.0,
          'doseMaxima': 250.0,
          'unidade': 'mg',
          'via': 'IV',
          'prioridade': 1
        },
        {
          'titulo': 'Glaucoma crônico',
          'descricaoDose': '62,5-125 mg VO 2-4x/dia (reduzir 50%)',
          'doseMinima': 62.5,
          'doseMaxima': 125.0,
          'unidade': 'mg',
          'via': 'VO',
          'prioridade': 2
        },
        {
          'titulo': 'Edema',
          'descricaoDose': '125-187,5 mg VO 1x/dia (reduzir 50%)',
          'doseMinima': 125.0,
          'doseMaxima': 187.5,
          'unidade': 'mg',
          'via': 'VO',
          'prioridade': 2
        }
      ];
    }
    
    // Ordenar por prioridade: IV/IM primeiro (prioridade 1), depois VO (prioridade 2)
    indicacoes.sort((a, b) {
      final prioridadeA = a['prioridade'] ?? 3;
      final prioridadeB = b['prioridade'] ?? 3;
      return prioridadeA.compareTo(prioridadeB);
    });
    
    return indicacoes.map<Widget>((indicacao) {
      final titulo = indicacao['titulo'] ?? '';
      final descricaoDose = indicacao['descricaoDose'] ?? '';
      final doseMinima = indicacao['doseMinima'] ?? 0.0;
      final doseMaxima = indicacao['doseMaxima'] ?? 0.0;
      final dosePorKgMinima = indicacao['dosePorKgMinima'] ?? 0.0;
      final dosePorKgMaxima = indicacao['dosePorKgMaxima'] ?? 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              descricaoDose,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            if (dosePorKgMinima > 0) ...[
              const SizedBox(height: 4),
              _buildCalculoDose(peso, dosePorKgMinima, dosePorKgMaxima),
            ] else if (doseMinima > 0) ...[
              const SizedBox(height: 4),
              _buildCalculoDoseFixa(doseMinima, doseMaxima),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    }).toList();
  }

  static Widget _buildCalculoDose(double peso, double doseMinima, double doseMaxima) {
    final doseCalculadaMin = (peso * doseMinima).round();
    final doseCalculadaMax = (peso * doseMaxima).round();
    
    return SizedBox(
      width: double.infinity,
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

  static Widget _buildCalculoDoseFixa(double doseMinima, double doseMaxima) {
    return SizedBox(
      width: double.infinity,
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

  static Widget _linhaPreparo(String texto, String obs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(texto)),
          if (obs.isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(child: Text(obs, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12))),
          ]
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}