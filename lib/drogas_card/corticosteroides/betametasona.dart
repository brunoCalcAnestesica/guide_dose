import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoBetametasona {
  static const String nome = 'Betametasona';
  static const String idBulario = 'betametasona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/betametasona.json');
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
      conteudo: _buildCardBetametasona(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Betametasona tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
        // Para RN, usar com extrema cautela devido ao risco de supressão adrenal
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
    final faixaEtaria = SharedData.faixaEtaria;
    
    if (faixaEtaria == 'Recém-nascido') {
      return [
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia doença da membrana hialina',
          descricaoDose: '0,1-0,2 mg/kg IV ou IM (uso excepcional)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMinima: 0.5, // Dose mínima absoluta para RN
          doseMaxima: 2, // Dose máxima para RN
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral neonatal',
          descricaoDose: '0,1-0,2 mg/kg IV ou IM (uso excepcional)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMinima: 0.5,
          doseMaxima: 2,
          peso: peso,
        ),
      ];
    } else if (isAdulto) {
      return [
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '6-12 mg IV ou IM a cada 6 horas (manutenção 24-48h)',
          unidade: 'mg',
          doseMinima: 6,
          doseMaxima: 12,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Asma grave/DPOC/Anafilaxia',
          descricaoDose: '4-8 mg IV ou IM a cada 6-12 horas',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'COVID-19 grave',
          descricaoDose: '6 mg IV ou IM 1x/dia por até 10 dias',
          unidade: 'mg',
          doseFixa: 6,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Crises autoimunes (LES, vasculites)',
          descricaoDose: '4-8 mg IV ou IM a cada 6-12 horas',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico refratário',
          descricaoDose: '4-8 mg IV ou IM (uso excepcional)',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia prematuridade',
          descricaoDose: '12 mg IM, duas doses com intervalo de 24h',
          unidade: 'mg',
          doseFixa: 12,
          peso: peso,
        ),
      ];
    } else {
      return [
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral pediátrico',
          descricaoDose: '0,1-0,2 mg/kg IV ou IM a cada 6-24 horas',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 8, // Máximo 8 mg por dose
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Asma grave pediátrica',
          descricaoDose: '0,1-0,2 mg/kg IV ou IM a cada 6-12 horas',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Crupe (laringotraqueobronquite)',
          descricaoDose: '0,1-0,2 mg/kg IV ou IM a cada 6-12 horas',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Anafilaxia pediátrica',
          descricaoDose: '0,1-0,2 mg/kg IV ou IM (após adrenalina)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoBetametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Exacerbações alérgicas graves',
          descricaoDose: '0,1-0,2 mg/kg IV ou IM a cada 6-12 horas',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 8,
          peso: peso,
        ),
      ];
    }
  }

  static Widget _buildCardBetametasona(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Corticosteroide sistêmico - Glicocorticoide de longa duração'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBetametasona._linhaPreparo('Ampola 4mg/mL (1mL e 2mL)', 'Solução injetável - Uso IV/IM'),
        MedicamentoBetametasona._linhaPreparo('Ampola 6mg/mL (1mL)', 'Solução injetável - Uso IV/IM'),
        MedicamentoBetametasona._linhaPreparo('Diprospan® (fosfato + acetato)', 'Liberação imediata e prolongada IM'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBetametasona._linhaPreparo('Uso direto IV ou IM da ampola', 'Administração lenta IV (2-5 min)'),
        MedicamentoBetametasona._linhaPreparo('Para infusão: diluir 4-8mg em 50-100mL SF ou SG5%', 'Concentração conforme indicação'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBetametasona._textoObs('Corticosteroide de longa duração (36-72h)'),
        MedicamentoBetametasona._textoObs('Monitorar glicemia, eletrólitos (Na+, K+) e pressão arterial'),
        MedicamentoBetametasona._textoObs('Usar menor dose eficaz pelo menor tempo possível'),
        MedicamentoBetametasona._textoObs('Risco de supressão do eixo HHA em uso prolongado'),
        MedicamentoBetametasona._textoObs('Contraindicado em infecções fúngicas sistêmicas não tratadas'),
        MedicamentoBetametasona._textoObs('Efeitos adversos: hiperglicemia, insônia, agitação, hipocalemia'),
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
    String? observacaoDose;

    if (doseFixa != null) {
      textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
        observacaoDose = 'Dose mínima aplicada';
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        observacaoDose = 'Dose máxima aplicada';
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null) {
        if (doseMin < doseMinima) {
          doseMin = doseMinima;
          observacaoDose = 'Dose mínima aplicada';
        }
      }
      if (doseMaxima != null) {
        if (doseMin > doseMaxima) {
          doseMin = doseMaxima;
          observacaoDose = 'Dose máxima aplicada';
        }
        if (doseMax > doseMaxima) {
          doseMax = doseMaxima;
          observacaoDose = 'Dose máxima aplicada';
        }
      }
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Dose calculada: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (observacaoDose != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      observacaoDose,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.orange.shade700,
                        fontSize: 11,
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
