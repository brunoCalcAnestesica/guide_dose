import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRocuronio {
  static const String nome = 'Rocurônio';
  static const String idBulario = 'rocuronio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/rocuronio.json');
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
      conteudo: _buildCardRocuronio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardRocuronio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRocuronio._textoObs('Bloqueador neuromuscular não despolarizante (aminosteroide) - Relaxante muscular'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRocuronio._linhaPreparo('Ampola 10mg/mL (5mL = 50mg)', 'Solução injetável'),
        MedicamentoRocuronio._linhaPreparo('Ampola 10mg/mL (10mL = 100mg)', 'Solução injetável'),
        MedicamentoRocuronio._linhaPreparo('Frasco 50mg/5mL (10mg/mL)', 'Uso hospitalar'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRocuronio._linhaPreparo('Bolus: usar direto da ampola', '10 mg/mL'),
        MedicamentoRocuronio._linhaPreparo('Infusão: 50mg em 50mL SF 0,9%', '1 mg/mL = 1000 mcg/mL'),
        MedicamentoRocuronio._linhaPreparo('Infusão: 100mg em 100mL SF 0,9%', '1 mg/mL'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoRocuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação sequência rápida (RSI)',
            descricaoDose: '0,6-1,2 mg/kg IV bolus (intubação em 60 seg)',
            unidade: 'mg',
            dosePorKgMinima: 0.6,
            dosePorKgMaxima: 1.2,
            peso: peso,
          ),
          MedicamentoRocuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação eletiva',
            descricaoDose: '0,45-0,6 mg/kg IV bolus (intubação em 90-120 seg)',
            unidade: 'mg',
            dosePorKgMinima: 0.45,
            dosePorKgMaxima: 0.6,
            peso: peso,
          ),
          MedicamentoRocuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção cirúrgica (doses incrementais)',
            descricaoDose: '0,1-0,15 mg/kg IV a cada 20-30 min',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.15,
            peso: peso,
          ),
        ] else ...[
          MedicamentoRocuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica (neonatos)',
            descricaoDose: '0,45-0,6 mg/kg IV (sensibilidade variável)',
            unidade: 'mg',
            dosePorKgMinima: 0.45,
            dosePorKgMaxima: 0.6,
            peso: peso,
          ),
          MedicamentoRocuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica (lactentes/crianças)',
            descricaoDose: '0,6-0,8 mg/kg IV (maior clearance)',
            unidade: 'mg',
            dosePorKgMinima: 0.6,
            dosePorKgMaxima: 0.8,
            peso: peso,
          ),
          MedicamentoRocuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção pediátrica',
            descricaoDose: '0,1-0,2 mg/kg IV a cada 15-25 min',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.2,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRocuronio._textoObs('Indicações: Manutenção bloqueio neuromuscular cirurgias prolongadas, ventilação controlada UTI'),
        const SizedBox(height: 8),
        MedicamentoRocuronio._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 8),
        MedicamentoRocuronio._textoObs('Manutenção anestésica: 0,3-0,6 mg/kg/h (5-10 mcg/kg/min)'),
        MedicamentoRocuronio._textoObs('UTI bloqueio prolongado: 0,6-1,2 mg/kg/h'),
        MedicamentoRocuronio._textoObs('Meta TOF: 1-2 respostas durante cirurgia/ventilação'),
        MedicamentoRocuronio._textoObs('Ajustar conforme monitorização neuromuscular'),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRocuronio._textoObs('Bloqueador de ação rápida - onset 60-90 seg (RSI)'),
        MedicamentoRocuronio._textoObs('Duração intermediária: 30-40 min (vs 60-90 min pancurônio)'),
        MedicamentoRocuronio._textoObs('OBRIGATÓRIO: Monitorização neuromuscular TOF contínua'),
        MedicamentoRocuronio._textoObs('Reversão específica: sugamadex 2-4 mg/kg IV (gold standard)'),
        MedicamentoRocuronio._textoObs('Reversão tradicional: neostigmina 40-70 mcg/kg + atropina'),
        MedicamentoRocuronio._textoObs('Não libera histamina - estabilidade hemodinâmica'),
        MedicamentoRocuronio._textoObs('Usar somente sob anestesia/sedação profunda'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '50mg em 50mL SF 0,9% (1 mg/mL)': 1.0,
      '100mg em 100mL SF 0,9% (1 mg/mL)': 1.0,
      '50mg em 25mL SF 0,9% (2 mg/mL)': 2.0,
      '200mg em 200mL SF 0,9% (1 mg/mL)': 1.0,
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.3,
        doseMax: 1.2,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.4,
        doseMax: 1.0,
      );
    }
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
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
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
