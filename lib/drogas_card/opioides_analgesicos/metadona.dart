import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMetadona {
  static const String nome = 'Metadona';
  static const String idBulario = 'metadona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/metadona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Metadona tem indicações principalmente para adultos
    // Uso pediátrico é muito restrito e especializado
    if (!isAdulto) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMetadona(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardMetadona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetadona._textoObs(
            'Opioide sintético - Analgésico narcótico - Agonista μ-opioide - Antagonista NMDA'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetadona._linhaPreparo('Ampola 10mg/mL (1mL)', ''),
        MedicamentoMetadona._linhaPreparo('Comprimido 5mg, 10mg, 40mg', ''),
        MedicamentoMetadona._linhaPreparo('Solução oral 1mg/mL, 2mg/mL', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetadona._linhaPreparo(
            'Via IV', 'Diluir em SF 0,9% ou usar direto'),
        MedicamentoMetadona._linhaPreparo(
            'Velocidade máxima', '1 mg/min (administração lenta)'),
        MedicamentoMetadona._linhaPreparo('Via IM', 'Usar direto da ampola'),
        MedicamentoMetadona._linhaPreparo(
            'Via oral', 'Comprimido ou solução (preferencial)'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        MedicamentoMetadona._linhaIndicacaoDoseFixa(
          titulo: 'Dor crônica moderada a grave',
          descricaoDose: '2,5-10mg VO a cada 6-8h (titular lentamente)',
          doseFixa: '2,5-10 mg',
        ),
        MedicamentoMetadona._linhaIndicacaoDoseFixa(
          titulo: 'Dor oncológica',
          descricaoDose: '5-10mg VO/IM/IV a cada 6-8h',
          doseFixa: '5-10 mg',
        ),
        MedicamentoMetadona._linhaIndicacaoDoseFixa(
          titulo: 'Dor neuropática refratária',
          descricaoDose: '5-10mg VO a cada 8h',
          doseFixa: '5-10 mg',
        ),
        MedicamentoMetadona._linhaIndicacaoDoseFixa(
          titulo: 'Tratamento de dependência opioide',
          descricaoDose: '20-120mg/dia VO (dose única diária)',
          doseFixa: '20-120 mg/dia',
        ),
        MedicamentoMetadona._linhaIndicacaoDoseFixa(
          titulo: 'Analgesia pós-operatória (uso limitado)',
          descricaoDose: '5-10mg IM/IV a cada 6-8h',
          doseFixa: '5-10 mg',
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
