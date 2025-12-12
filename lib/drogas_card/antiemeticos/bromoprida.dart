import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoBromoprida {
  static const String nome = 'Bromoprida';
  static const String idBulario = 'bromoprida';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/bromoprida.json');
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
      conteudo: _buildCardBromoprida(
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
    // Bromoprida tem indicações para todas as faixas etárias acima de 1 ano
    switch (faixaEtaria) {
      case 'Recém-nascido':
        return false; // Contraindicado em menores de 1 ano
      case 'Lactente':
        // Apenas lactentes acima de 1 ano
        return true;
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
        MedicamentoBromoprida._linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas e vômitos pós-operatórios',
          descricaoDose: '10-20 mg VO/IM/IV a cada 8h',
          unidade: 'mg',
          doseMinima: 10,
          doseMaxima: 20,
          peso: peso,
        ),
        MedicamentoBromoprida._linhaIndicacaoDoseCalculada(
          titulo: 'Gastroparesia diabética',
          descricaoDose: '10-20 mg VO/IM/IV a cada 8h',
          unidade: 'mg',
          doseMinima: 10,
          doseMaxima: 20,
          peso: peso,
        ),
        MedicamentoBromoprida._linhaIndicacaoDoseCalculada(
          titulo: 'Refluxo gastroesofágico',
          descricaoDose: '10-20 mg VO antes das refeições',
          unidade: 'mg',
          doseMinima: 10,
          doseMaxima: 20,
          peso: peso,
        ),
        MedicamentoBromoprida._linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas por quimioterapia',
          descricaoDose: '10-20 mg IV a cada 8h',
          unidade: 'mg',
          doseMinima: 10,
          doseMaxima: 20,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria (acima de 1 ano)
      return [
        MedicamentoBromoprida._linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas e vômitos pós-operatórios',
          descricaoDose: '0,1-0,15 mg/kg/dose VO/IM/IV a cada 8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.15,
          doseMaxima: 20,
          peso: peso,
        ),
        MedicamentoBromoprida._linhaIndicacaoDoseCalculada(
          titulo: 'Gastroenterite aguda',
          descricaoDose: '0,1-0,15 mg/kg/dose VO a cada 8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.15,
          doseMaxima: 20,
          peso: peso,
        ),
        MedicamentoBromoprida._linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas por enxaqueca',
          descricaoDose: '0,1-0,15 mg/kg/dose VO/IM a cada 8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.15,
          doseMaxima: 20,
          peso: peso,
        ),
      ];
    }
  }

  static Widget _buildCardBromoprida(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antiemético, agente procinético gastrointestinal, antagonista dopaminérgico D2'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBromoprida._linhaPreparo('Comprimidos 10 mg', 'Via oral'),
        MedicamentoBromoprida._linhaPreparo('Ampola 10 mg/2 mL (5 mg/mL)', 'Via IM/IV'),
        MedicamentoBromoprida._linhaPreparo('Solução oral 1-4 mg/mL', 'Via oral pediátrica'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBromoprida._linhaPreparo('IV direta: 10-20 mg em pelo menos 2 minutos', 'Administração lenta'),
        MedicamentoBromoprida._linhaPreparo('Infusão: diluir em 50-100 mL SF 0,9% ou SG 5%', 'Infundir em 15-30 minutos'),
        MedicamentoBromoprida._linhaPreparo('IM: aplicar sem diluição, profundamente', 'Via intramuscular'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBromoprida._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBromoprida._textoObs('Antagonista seletivo dos receptores dopaminérgicos D2 central e periférico'),
        MedicamentoBromoprida._textoObs('Contraindicado em crianças menores de 1 ano (risco de depressão respiratória)'),
        MedicamentoBromoprida._textoObs('Monitorar reações extrapiramidais, especialmente em pediatria e idosos'),
        MedicamentoBromoprida._textoObs('Pode causar sedação, sonolência e efeitos anticolinérgicos'),
        MedicamentoBromoprida._textoObs('Incompatível com bicarbonato de sódio e soluções alcalinas'),
        MedicamentoBromoprida._textoObs('Ajustar dose em insuficiência renal e hepática'),
        MedicamentoBromoprida._textoObs('Efeitos adversos: sedação, reações extrapiramidais, hiperprolactinemia'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    if (!isAdulto) {
      // Infusão contínua para pediatria
      final opcoesConcentracoes = {
        '10 mg em 100 mL SF (0,1 mg/mL)': 0.1,
        '20 mg em 100 mL SF (0,2 mg/mL)': 0.2,
        '10 mg em 50 mL SF (0,2 mg/mL)': 0.2,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoBromoprida._textoObs('Infusão contínua: 0,1-0,15 mg/kg/h'),
          MedicamentoBromoprida._textoObs('Diluir em SF 0,9% ou SG 5%'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mg/h',
            doseMin: 0.1,
            doseMax: 0.15,
          ),
        ],
      );
    } else {
      // Adultos não têm infusão contínua padrão
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoBromoprida._textoObs('Infusão contínua não é modalidade padrão para adultos'),
          MedicamentoBromoprida._textoObs('Usar doses intermitentes conforme necessidade'),
          MedicamentoBromoprida._textoObs('Dose máxima diária: 80 mg/dia'),
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