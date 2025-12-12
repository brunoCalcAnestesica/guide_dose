import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoBumetadina {
  static const String nome = 'Bumetadina';
  static const String idBulario = 'bumetadina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/bumetadina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
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
      conteudo: _buildCardBumetadina(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Bumetadina tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
        // Uso off-label em situações específicas
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

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        MedicamentoBumetadina._linhaIndicacaoDoseCalculada(
          titulo: 'Edema por insuficiência cardíaca',
          descricaoDose: '0,5-2 mg VO/IV a cada 4-6h (máximo 10 mg/dia)',
          unidade: 'mg',
          doseMinima: 0.5,
          doseMaxima: 2,
          peso: peso,
        ),
        MedicamentoBumetadina._linhaIndicacaoDoseCalculada(
          titulo: 'Edema agudo de pulmão',
          descricaoDose: '1-2 mg IV em bolus lento',
          unidade: 'mg',
          doseMinima: 1,
          doseMaxima: 2,
          peso: peso,
        ),
        MedicamentoBumetadina._linhaIndicacaoDoseCalculada(
          titulo: 'Edema hepático/renal',
          descricaoDose: '0,5-2 mg VO/IV a cada 6-12h',
          unidade: 'mg',
          doseMinima: 0.5,
          doseMaxima: 2,
          peso: peso,
        ),
        MedicamentoBumetadina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão resistente (off-label)',
          descricaoDose: '0,5-1 mg VO/dia',
          unidade: 'mg',
          doseMinima: 0.5,
          doseMaxima: 1,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria (uso off-label)
      return [
        MedicamentoBumetadina._linhaIndicacaoDoseCalculada(
          titulo: 'Edema pediátrico (off-label)',
          descricaoDose: '0,015-0,1 mg/kg/dose VO/IV a cada 6-12h',
          unidade: 'mg',
          dosePorKgMinima: 0.015,
          dosePorKgMaxima: 0.1,
          doseMaxima: 1,
          peso: peso,
        ),
        MedicamentoBumetadina._linhaIndicacaoDoseCalculada(
          titulo: 'Edema agudo de pulmão pediátrico',
          descricaoDose: '0,015-0,1 mg/kg/dose IV em bolus lento',
          unidade: 'mg',
          dosePorKgMinima: 0.015,
          dosePorKgMaxima: 0.1,
          doseMaxima: 1,
          peso: peso,
        ),
        MedicamentoBumetadina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca pediátrica',
          descricaoDose: '0,015-0,1 mg/kg/dose VO/IV a cada 6-12h',
          unidade: 'mg',
          dosePorKgMinima: 0.015,
          dosePorKgMaxima: 0.1,
          doseMaxima: 1,
          peso: peso,
        ),
      ];
    }
  }

  static Widget _buildCardBumetadina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Diurético de alça, derivado da sulfonamida'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBumetadina._linhaPreparo('Comprimidos 1 mg e 5 mg', 'Via oral'),
        MedicamentoBumetadina._linhaPreparo('Ampola 0,25 mg/mL - 4 mL (1 mg total)', 'Via IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBumetadina._linhaPreparo('IV bolus: usar direto da ampola', 'Administração em 2 minutos'),
        MedicamentoBumetadina._linhaPreparo('Infusão: diluir 1 mg em 10-50 mL SF 0,9%', 'Infundir em 5-10 minutos'),
        MedicamentoBumetadina._linhaPreparo('VO: comprimidos inteiros', 'Administrar durante o dia'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBumetadina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBumetadina._textoObs('Diurético de alça 40 vezes mais potente que furosemida'),
        MedicamentoBumetadina._textoObs('Inibe cotransportador Na+/K+/2Cl- na alça de Henle'),
        MedicamentoBumetadina._textoObs('Monitorar rigorosamente eletrólitos (K+, Na+, Mg2+, Ca2+)'),
        MedicamentoBumetadina._textoObs('Cuidado com hipovolemia e hipotensão'),
        MedicamentoBumetadina._textoObs('Contraindicado em anúria e hipersensibilidade a sulfonamidas'),
        MedicamentoBumetadina._textoObs('Pode causar ototoxicidade em doses altas'),
        MedicamentoBumetadina._textoObs('Uso pediátrico é off-label, baseado em casos clínicos'),
        MedicamentoBumetadina._textoObs('Ajustar dose em insuficiência renal grave'),
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
      textoDose = '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(1)}–${doseMaxima.toStringAsFixed(1)} $unidade';
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    if (!isAdulto) {
      // Infusão contínua para pediatria
      final opcoesConcentracoes = {
        '0,5 mg em 50 mL SF (0,01 mg/mL)': 0.01,
        '1 mg em 50 mL SF (0,02 mg/mL)': 0.02,
        '1 mg em 100 mL SF (0,01 mg/mL)': 0.01,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoBumetadina._textoObs('Infusão contínua: 0,015-0,1 mg/kg/h (uso off-label)'),
          MedicamentoBumetadina._textoObs('Diluir em SF 0,9% ou SG 5%'),
          MedicamentoBumetadina._textoObs('Monitorizar rigorosamente diurese e eletrólitos'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mg/h',
            doseMin: 0.015,
            doseMax: 0.1,
          ),
        ],
      );
    } else {
      // Adultos - infusão contínua não é modalidade padrão
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoBumetadina._textoObs('Infusão contínua não é modalidade padrão para adultos'),
          MedicamentoBumetadina._textoObs('Usar doses intermitentes conforme necessidade'),
          MedicamentoBumetadina._textoObs('Dose máxima diária: 10 mg/dia'),
          MedicamentoBumetadina._textoObs('Administrar preferencialmente durante o dia'),
        ],
      );
    }
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