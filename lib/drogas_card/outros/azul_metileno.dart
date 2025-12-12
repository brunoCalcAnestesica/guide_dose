import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAzulMetileno {
  static const String nome = 'Azul de Metileno';
  static const String idBulario = 'azul_metileno';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/azul_metileno.json');
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
      conteudo: _buildCardAzulMetileno(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Azul de metileno tem indicações para todas as faixas etárias
    // mas pode ser restrito em casos específicos
    switch (faixaEtaria) {
      case 'Recém-nascido':
        // Para RN, usar com extrema cautela devido ao risco de metahemoglobinemia paradoxal
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
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Metahemoglobinemia adquirida/congênita',
          descricaoDose: '1-2 mg/kg IV bolus lento (5-10 min)',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso, // Máximo 7 mg/kg total por episódio
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por nitritos/nitratos/anilinas',
          descricaoDose: '1-2 mg/kg IV bolus lento',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por dapsona/benzocaína/prilocaína',
          descricaoDose: '1-2 mg/kg IV bolus lento',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Corante vital em cirurgia (fístulas/paratireoides)',
          descricaoDose: '1-2 mg/kg IV para identificação de estruturas',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico (tratamento adjuvante)',
          descricaoDose: '1-2 mg/kg IV (uso controverso)',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
      ];
    } else {
      return [
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Metahemoglobinemia pediátrica',
          descricaoDose: '1-2 mg/kg IV bolus lento (5-10 min)',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por nitritos/nitratos pediátrica',
          descricaoDose: '1-2 mg/kg IV bolus lento',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por dapsona/benzocaína pediátrica',
          descricaoDose: '1-2 mg/kg IV bolus lento',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Corante vital em cirurgia pediátrica',
          descricaoDose: '1-2 mg/kg IV para identificação de estruturas',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
        MedicamentoAzulMetileno._linhaIndicacaoDoseCalculada(
          titulo: 'Encefalopatia por ifosfamida pediátrica',
          descricaoDose: '1 mg/kg IV a cada 4-8 horas',
          unidade: 'mg',
          dosePorKg: 1,
          doseMaxima: 7 * peso,
          peso: peso,
        ),
      ];
    }
  }

  static Widget _buildCardAzulMetileno(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Agente redutor - Antídoto para metahemoglobinemia'),
        const SizedBox(height: 16),
        const Text('Apresentações Venosas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAzulMetileno._linhaPreparo('Ampola 10mg/mL (10mL)', 'Solução injetável estéril - Uso IV'),
        MedicamentoAzulMetileno._linhaPreparo('Ampola 50mg/mL (2mL)', 'Solução injetável concentrada - Uso IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAzulMetileno._linhaPreparo('Diluir em SF 0,9% ou SG 5%', 'Concentração conforme indicação'),
        MedicamentoAzulMetileno._linhaPreparo('Para bolus: 1mg/mL', 'Administração lenta IV'),
        const SizedBox(height: 16),
        const Text('Aplicações Venosas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações Venosas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAzulMetileno._textoObs('Administração exclusiva por via IV lenta (5-10 min)'),
        MedicamentoAzulMetileno._textoObs('Diluir em 50-100 mL de SF 0,9% ou SG 5%'),
        MedicamentoAzulMetileno._textoObs('Dose máxima: 7 mg/kg total por episódio'),
        MedicamentoAzulMetileno._textoObs('Contraindicado em deficiência de G6PD (risco de hemólise)'),
        MedicamentoAzulMetileno._textoObs('Monitorar saturação de oxigênio e metahemoglobina seriada'),
        MedicamentoAzulMetileno._textoObs('Efeitos adversos: urina azul-esverdeada (normal), náusea, cefaleia'),
        MedicamentoAzulMetileno._textoObs('Pode interferir com oximetria de pulso (falsamente baixa)'),
        MedicamentoAzulMetileno._textoObs('Proteger da luz durante armazenamento e administração'),
        MedicamentoAzulMetileno._textoObs('Incompatível com soluções alcalinas'),
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
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
      }
      // Aplicar dose máxima silenciosamente se necessário
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null) {
        doseMin = doseMin < doseMinima ? doseMinima : doseMin;
      }
      // Aplicar dose máxima silenciosamente se necessário
      if (doseMaxima != null) {
        if (doseMin > doseMaxima) doseMin = doseMaxima;
        if (doseMax > doseMaxima) doseMax = doseMaxima;
      }
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
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
