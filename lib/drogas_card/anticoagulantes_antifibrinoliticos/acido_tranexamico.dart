import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAcidoTranexamico {
  static const String nome = 'Ácido Tranexâmico';
  static const String idBulario = 'acido_tranexamico';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/acido_tranexamico.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAcidoTranexamico(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAcidoTranexamico(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antifibrinolítico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAcidoTranexamico._linhaPreparo('Ampola 500mg/5mL', 'Solução injetável 100mg/mL'),
        MedicamentoAcidoTranexamico._linhaPreparo('Comprimidos 250mg e 500mg', 'Via oral'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAcidoTranexamico._linhaPreparo('500mg em 100mL SF 0,9%', '5 mg/mL para bolus'),
        MedicamentoAcidoTranexamico._linhaPreparo('1g em 250mL SF 0,9%', '4 mg/mL para infusão contínua'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAcidoTranexamico._linhaIndicacaoDoseCalculada(
            titulo: 'Hemorragia ativa',
            descricaoDose: '10–15 mg/kg IV lento (máx 1g)',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
          MedicamentoAcidoTranexamico._linhaIndicacaoDoseCalculada(
            titulo: 'Cirurgia cardíaca',
            descricaoDose: '10–15 mg/kg IV antes da cirurgia',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
          MedicamentoAcidoTranexamico._linhaIndicacaoDoseCalculada(
            titulo: 'Hemorragia contínua (infusão)',
            descricaoDose: '1–2 mg/kg/h IV contínua',
            unidade: 'mg/kg/h',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
          ),
          MedicamentoAcidoTranexamico._linhaIndicacaoDoseCalculada(
            titulo: 'Menorragia',
            descricaoDose: '1–1,5g/dia VO dividido em 3–4 doses',
            unidade: 'g/dia',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 1.5,
            peso: peso,
          ),
        ] else ...[
          MedicamentoAcidoTranexamico._linhaIndicacaoDoseCalculada(
            titulo: 'Hemorragia ativa pediátrica',
            descricaoDose: '10–15 mg/kg IV lento (máx 1g)',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
          MedicamentoAcidoTranexamico._linhaIndicacaoDoseCalculada(
            titulo: 'Cirurgia pediátrica',
            descricaoDose: '10–15 mg/kg IV antes da cirurgia',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
          MedicamentoAcidoTranexamico._linhaIndicacaoDoseCalculada(
            titulo: 'Hemorragia contínua pediátrica (infusão)',
            descricaoDose: '0,5–1,5 mg/kg/h IV contínua',
            unidade: 'mg/kg/h',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.5,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAcidoTranexamico._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAcidoTranexamico._textoObs('Antifibrinolítico para controle de hemorragia'),
        MedicamentoAcidoTranexamico._textoObs('Contraindicado em trombose ativa ou história de trombose'),
        MedicamentoAcidoTranexamico._textoObs('Ajustar dose em insuficiência renal'),
        MedicamentoAcidoTranexamico._textoObs('Evitar uso prolongado (risco tromboembólico)'),
        MedicamentoAcidoTranexamico._textoObs('Monitorar função renal durante o tratamento'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Para ácido tranexâmico, a infusão contínua é tipicamente mg/kg/h, não mg/kg/dia
    final opcoesConcentracoes = {
      '1g em 250mL SF 0,9% (4 mg/mL)': 4.0, // mg/mL
      '500mg em 100mL SF 0,9% (5 mg/mL)': 5.0, // mg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 1.0,
        doseMax: 2.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 1.5,
      );
    }
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
    double? doseMaxima,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
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
