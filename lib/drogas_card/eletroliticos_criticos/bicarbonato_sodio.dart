import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoBicarbonatoSodio {
  static const String nome = 'Bicarbonato de Sódio';
  static const String idBulario = 'bicarbonato_sodio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/bicarbonato_sodio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

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
      conteudo: _buildCardBicarbonatoSodio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return _buildCardBicarbonatoSodio(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Bicarbonato de sódio tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
        // Para RN, usar com extrema cautela devido ao risco de alcalose
        return true;
      case 'Lactente':
      case 'Criança':
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        return true;
      default:
        return false;
    }
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, bool isAdulto) {
    if (isAdulto) {
      return [
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Acidose metabólica grave (pH < 7,1)',
          descricaoDose: '1-2 mEq/kg IV, infundir lentamente',
          unidade: 'mEq',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMinima: 10,
          doseMaxima: 150,
          peso: peso,
        ),
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipercalemia grave',
          descricaoDose: '50 mEq IV em 5 minutos',
          unidade: 'mEq',
          doseFixa: 50,
          peso: peso,
        ),
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por tricíclicos',
          descricaoDose: '1-2 mEq/kg IV em bolus, manter pH 7,45-7,55',
          unidade: 'mEq',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMinima: 10,
          doseMaxima: 150,
          peso: peso,
        ),
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por salicilatos',
          descricaoDose: '1-2 mEq/kg IV, manter pH 7,45-7,55',
          unidade: 'mEq',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMinima: 10,
          doseMaxima: 150,
          peso: peso,
        ),
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Alcalinização urinária',
          descricaoDose: '100-150 mEq em 1L SG5%, infundir 250-500 mL/h',
          unidade: 'mEq',
          doseMinima: 100,
          doseMaxima: 150,
          peso: peso,
        ),
      ];
    } else {
      // Cálculos pediátricos refinados
      return [
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Acidose metabólica pediátrica',
          descricaoDose: '1-2 mEq/kg IV, administrar lentamente',
          unidade: 'mEq',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMinima: 2,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipercalemia pediátrica',
          descricaoDose: '1-2 mEq/kg IV em 5 minutos',
          unidade: 'mEq',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMinima: 2,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação pediátrica (tricíclicos/salicilatos)',
          descricaoDose: '1-2 mEq/kg IV, manter pH 7,45-7,55',
          unidade: 'mEq',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMinima: 2,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoBicarbonatoSodio._linhaIndicacaoDoseCalculada(
          titulo: 'Acidose tubular renal tipo I',
          descricaoDose: '1-2 mEq/kg IV, ajustar conforme gasometria',
          unidade: 'mEq',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMinima: 2,
          doseMaxima: 50,
          peso: peso,
        ),
      ];
    }
  }

  static Widget _buildCardBicarbonatoSodio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Agente alcalinizante - Corretor de distúrbios ácido-base'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBicarbonatoSodio._linhaPreparo('Ampola 8,4% - 50mL (1 mEq/mL)', 'Solução injetável - Uso IV'),
        MedicamentoBicarbonatoSodio._linhaPreparo('Frasco para infusão 1 mEq/mL', 'Solução injetável - Uso IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBicarbonatoSodio._linhaPreparo('Uso direto da ampola para bolus', 'Administração lenta IV (2-3 min)'),
        MedicamentoBicarbonatoSodio._linhaPreparo('Para infusão: 100 mEq em 1L SG5%', 'Nunca diluir em SF 0,9%'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBicarbonatoSodio._textoObs('Agente alcalinizante para correção de acidose metabólica'),
        MedicamentoBicarbonatoSodio._textoObs('Monitorar gasometria, eletrólitos (K+, Ca++, Na+) e osmolaridade'),
        MedicamentoBicarbonatoSodio._textoObs('Contraindicado em alcalose metabólica e hipocalcemia não corrigida'),
        MedicamentoBicarbonatoSodio._textoObs('Incompatível com cloreto de cálcio, potássio e catecolaminérgicos'),
        MedicamentoBicarbonatoSodio._textoObs('Usar acesso central preferencialmente (osmolaridade elevada)'),
        MedicamentoBicarbonatoSodio._textoObs('Efeitos adversos: hipernatremia, alcalose, hipocalemia, tetania'),
      ],
    );
  }

  static Widget _linhaPreparo(String texto, String marca) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(text: texto),
                  if (marca.isNotEmpty) ...[
                    const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: marca, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMinima,
    double? doseMaxima,
    double? doseFixa,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      // Verificar se dose mínima não ultrapassou a máxima
      if (doseMin > doseMax) doseMin = doseMax;
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            descricaoDose,
            style: const TextStyle(fontSize: 13),
          ),
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Dose calculada: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (doseLimite) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Dose limitada por segurança',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
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
