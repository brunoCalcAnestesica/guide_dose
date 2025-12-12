import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAmiodarona {
  static const String nome = 'Amiodarona';
  static const String idBulario = 'amiodarona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/amiodarona.json');
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
      conteudo: _buildCardAmiodarona(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAmiodarona(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAmiodarona._textoObs('• Antiarrítmico classe III - Bloqueador de canais de potássio'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAmiodarona._linhaPreparo('Ampola 150mg/3mL', 'Solução injetável'),
        MedicamentoAmiodarona._linhaPreparo('Comprimidos 200mg', 'Via oral'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAmiodarona._linhaPreparo('150mg em 250mL SG 5%', '0,6 mg/mL para infusão'),
        MedicamentoAmiodarona._linhaPreparo('300mg em 250mL SG 5%', '1,2 mg/mL para infusão'),
        MedicamentoAmiodarona._linhaPreparo('Usar apenas SG 5%', 'Não usar SF 0,9%'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAmiodarona._linhaIndicacaoDoseCalculada(
            titulo: 'Dose de ataque IV',
            descricaoDose: '5 mg/kg IV em 20-60min',
            unidade: 'mg',
            dosePorKg: 5,
            peso: peso,
          ),
          MedicamentoAmiodarona._linhaIndicacaoDoseCalculada(
            titulo: 'Dose de manutenção IV',
            descricaoDose: '10-20 mg/kg/dia IV contínua',
            unidade: 'mg/dia',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 20,
            peso: peso,
          ),
          MedicamentoAmiodarona._linhaIndicacaoDoseFixa(
            titulo: 'Dose de ataque VO',
            descricaoDose: '400-1200 mg/dia dividido',
            doseFixa: '400-1200 mg/dia',
          ),
          MedicamentoAmiodarona._linhaIndicacaoDoseFixa(
            titulo: 'Dose de manutenção VO',
            descricaoDose: '100-400 mg/dia',
            doseFixa: '100-400 mg/dia',
          ),
        ] else ...[
          MedicamentoAmiodarona._linhaIndicacaoDoseCalculada(
            titulo: 'Dose inicial pediátrica IV',
            descricaoDose: '5 mg/kg IV em 20-60min (máx 300mg)',
            unidade: 'mg',
            dosePorKg: 5,
            doseMaxima: 300,
            peso: peso,
          ),
          MedicamentoAmiodarona._linhaIndicacaoDoseCalculada(
            titulo: 'Dose de manutenção pediátrica IV',
            descricaoDose: '5-15 mcg/kg/min IV contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 15,
            peso: peso,
          ),
          if (peso < 1) ...[
            MedicamentoAmiodarona._linhaIndicacaoDoseCalculada(
              titulo: 'Neonatos - Dose inicial',
              descricaoDose: '5 mg/kg IV (máx 15 mg/kg)',
              unidade: 'mg',
              dosePorKg: 5,
              doseMaxima: 15,
              peso: peso,
            ),
          ],
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAmiodarona._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAmiodarona._textoObs('• Antiarrítmico de amplo espectro para arritmias graves'),
        MedicamentoAmiodarona._textoObs('• Meia-vida longa (40-55 dias) - efeito cumulativo'),
        MedicamentoAmiodarona._textoObs('• Monitorar função tireoidiana e hepática'),
        MedicamentoAmiodarona._textoObs('• Risco de toxicidade pulmonar com uso prolongado'),
        MedicamentoAmiodarona._textoObs('• Interage com digoxina, warfarina e outros antiarrítmicos'),
        MedicamentoAmiodarona._textoObs('• Contraindicado em bradicardia sinusal, bloqueio AV'),
        MedicamentoAmiodarona._textoObs('• Usar apenas SG 5% para diluição'),
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
      '150mg em 250mL SG 5% (0,6 mg/mL)': 0.6, // mg/mL
      '300mg em 250mL SG 5% (1,2 mg/mL)': 1.2, // mg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.4, // 10 mg/kg/dia ÷ 24h = 0.42 mg/kg/h
        doseMax: 0.8, // 20 mg/kg/dia ÷ 24h = 0.83 mg/kg/h
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 5.0,
        doseMax: 15.0,
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
