import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMetoprolol {
  static const String nome = 'Metoprolol';
  static const String idBulario = 'metoprolol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/metoprolol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Metoprolol tem indicações principalmente para adultos
    // Uso pediátrico é muito limitado
    if (!isAdulto) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMetoprolol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardMetoprolol(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetoprolol._textoObs(
            'Betabloqueador cardioseletivo (β1) - Antiarrítmico - Anti-hipertensivo'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetoprolol._linhaPreparo('Ampola 1mg/mL (5mL = 5mg)', ''),
        MedicamentoMetoprolol._linhaPreparo('Comprimido 25mg, 50mg, 100mg', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetoprolol._linhaPreparo(
            'Via IV', 'Administrar direto ou diluir em 10-20mL SF 0,9%'),
        MedicamentoMetoprolol._linhaPreparo(
            'Velocidade máxima', '1-2 mg/min (LENTO)'),
        MedicamentoMetoprolol._linhaPreparo(
            'Via oral', 'Comprimido com ou sem alimentos'),
        MedicamentoMetoprolol._linhaPreparo(
            'Monitorização', 'ECG, PA e FC continuamente'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        MedicamentoMetoprolol._linhaIndicacaoDoseFixa(
          titulo: 'Taquiarritmias supraventriculares',
          descricaoDose: '2,5-5mg IV lento a cada 5min (máx 15mg total)',
          doseFixa: '2,5-5 mg',
        ),
        MedicamentoMetoprolol._linhaIndicacaoDoseFixa(
          titulo: 'Fibrilação atrial com resposta ventricular rápida',
          descricaoDose: '2,5-5mg IV lento a cada 5min (máx 15mg)',
          doseFixa: '2,5-5 mg',
        ),
        MedicamentoMetoprolol._linhaIndicacaoDoseFixa(
          titulo: 'Controle PA e FC no IAM',
          descricaoDose: '5mg IV cada 5min (até 3 doses = 15mg)',
          doseFixa: '5 mg',
        ),
        MedicamentoMetoprolol._linhaIndicacaoDoseFixa(
          titulo: 'Hipertensão perioperatória',
          descricaoDose: '1-5mg IV lento, repetir conforme resposta',
          doseFixa: '1-5 mg',
        ),
        MedicamentoMetoprolol._linhaIndicacaoDoseFixa(
          titulo: 'Taquicardia sinusal sintomática',
          descricaoDose: '2,5-5mg IV lento',
          doseFixa: '2,5-5 mg',
        ),
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
                    const TextSpan(
                        text: ' | ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: marca,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
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

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
