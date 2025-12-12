import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAtracurio {
  static const String nome = 'Atracúrio';
  static const String idBulario = 'atracurio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/atracurio.json');
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
      conteudo: _buildCardAtracurio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAtracurio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtracurio._textoObs('• Bloqueador neuromuscular não despolarizante - Aminosteróide'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtracurio._linhaPreparo('Ampola 10mg/mL (5mL)', 'Solução injetável'),
        MedicamentoAtracurio._linhaPreparo('Ampola 10mg/mL (2,5mL)', 'Solução injetável'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtracurio._linhaPreparo('Pode ser administrado sem diluição', 'Direto da ampola para bolus'),
        MedicamentoAtracurio._linhaPreparo('Para infusão: diluir em SF 0,9% ou SG 5%', 'Concentração 1-2 mg/mL'),
        MedicamentoAtracurio._linhaPreparo('100mg em 100mL SF 0,9%', '1 mg/mL para infusão contínua'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAtracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Dose inicial - Adultos',
            descricaoDose: '0,4-0,5 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.4,
            dosePorKgMaxima: 0.5,
            peso: peso,
          ),
          MedicamentoAtracurio._linhaIndicacaoDoseFixa(
            titulo: 'Infusão contínua - Adultos',
            descricaoDose: '5-10 mcg/kg/min IV contínua',
            doseFixa: '5-10 mcg/kg/min',
          ),
        ] else ...[
          if (peso >= 1) ...[
            MedicamentoAtracurio._linhaIndicacaoDoseCalculada(
              titulo: 'Dose inicial pediátrica',
              descricaoDose: '0,3-0,5 mg/kg IV bolus',
              unidade: 'mg',
              dosePorKgMinima: 0.3,
              dosePorKgMaxima: 0.5,
              peso: peso,
            ),
            MedicamentoAtracurio._linhaIndicacaoDoseFixa(
              titulo: 'Infusão contínua pediátrica',
              descricaoDose: '5-8 mcg/kg/min IV contínua',
              doseFixa: '5-8 mcg/kg/min',
            ),
          ] else ...[
            MedicamentoAtracurio._textoObs('• Não recomendado para neonatos (<1kg)'),
            MedicamentoAtracurio._textoObs('• Imaturidade dos sistemas enzimáticos'),
          ],
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto || peso >= 1) ...[
          MedicamentoAtracurio._buildConversorInfusao(peso, isAdulto),
        ] else ...[
          MedicamentoAtracurio._textoObs('• Infusão contínua não recomendada para neonatos'),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtracurio._textoObs('• Bloqueador neuromuscular para relaxamento muscular'),
        MedicamentoAtracurio._textoObs('• Duração de ação intermediária (20-35 minutos)'),
        MedicamentoAtracurio._textoObs('• Monitorar função respiratória e cardiovascular'),
        MedicamentoAtracurio._textoObs('• Pode liberar histamina (hipotensão, rubor)'),
        MedicamentoAtracurio._textoObs('• Administrar lentamente para minimizar efeitos'),
        MedicamentoAtracurio._textoObs('• Ajustar dose em disfunção hepática/renal'),
        MedicamentoAtracurio._textoObs('• Usar monitor de bloqueio neuromuscular'),
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

  static Widget _linhaIndicacaoDoseFixa({
    required String titulo,
    required String descricaoDose,
    required String doseFixa,
  }) {
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
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '50mg em 50mL SF 0,9% (1000 mcg/mL)': 1000.0, // mcg/mL
      '100mg em 50mL SF 0,9% (2000 mcg/mL)': 2000.0, // mcg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 5.0,
        doseMax: 10.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 5.0,
        doseMax: 8.0,
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
