import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPilocarpina {
  static const String nome = 'Pilocarpina';
  static const String idBulario = 'pilocarpina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/pilocarpina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Pilocarpina: não usar em neonatos/lactentes
    if (SharedData.faixaEtaria == 'Neonato' || SharedData.faixaEtaria == 'Lactente') {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardPilocarpina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardPilocarpina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPilocarpina._textoObs('Parassimpaticomimético - Agonista colinérgico muscarínico direto'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPilocarpina._linhaPreparo('Colírio 1% (10mg/mL)', 'Frasco 15mL'),
        MedicamentoPilocarpina._linhaPreparo('Colírio 2% (20mg/mL)', 'Frasco 15mL'),
        MedicamentoPilocarpina._linhaPreparo('Colírio 4% (40mg/mL)', 'Frasco 15mL'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPilocarpina._linhaPreparo('Usar solução pronta', 'Não diluir'),
        MedicamentoPilocarpina._linhaPreparo('Instilar 1-2 gotas no saco conjuntival', 'Puxar pálpebra inferior'),
        MedicamentoPilocarpina._linhaPreparo('Comprimir ponto lacrimal 1-2 min', 'Reduz absorção sistêmica'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoPilocarpina._linhaIndicacaoDoseFixa(
            titulo: 'Glaucoma crônico ângulo aberto',
            descricaoDose: '1-2 gotas colírio 1-4% no olho afetado 3-4x/dia',
            doseFixa: '1-2 gotas 3-4x/dia',
          ),
          MedicamentoPilocarpina._linhaIndicacaoDoseFixa(
            titulo: 'Glaucoma ângulo fechado agudo',
            descricaoDose: '1-2 gotas colírio 2-4% a cada 5-10 min até controle PIO',
            doseFixa: '1-2 gotas a cada 5-10 min',
          ),
          MedicamentoPilocarpina._linhaIndicacaoDoseFixa(
            titulo: 'Pós-cirurgia ocular (miose)',
            descricaoDose: '1 gota colírio 1-2% no final da cirurgia',
            doseFixa: '1 gota',
          ),
          MedicamentoPilocarpina._linhaIndicacaoDoseFixa(
            titulo: 'Manutenção glaucoma controlado',
            descricaoDose: '1 gota colírio 1-2% 2-3x/dia',
            doseFixa: '1 gota 2-3x/dia',
          ),
        ] else ...[
          MedicamentoPilocarpina._linhaIndicacaoDoseFixa(
            titulo: 'Glaucoma pediátrico (>2 anos)',
            descricaoDose: '1 gota colírio 1-2% no olho afetado 3-4x/dia',
            doseFixa: '1 gota 3-4x/dia',
          ),
          MedicamentoPilocarpina._linhaIndicacaoDoseFixa(
            titulo: 'Glaucoma congênito (>2 anos)',
            descricaoDose: '1 gota colírio 1% 3x/dia (iniciar concentração baixa)',
            doseFixa: '1 gota 3x/dia',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPilocarpina._textoObs('Miótico potente - reduz pressão intraocular (PIO) 20-30%'),
        MedicamentoPilocarpina._textoObs('Onset: 10-30 min. Pico: 30-90 min. Duração: 4-8 horas'),
        MedicamentoPilocarpina._textoObs('Reduz visão noturna - evitar dirigir à noite'),
        MedicamentoPilocarpina._textoObs('Comprimir ponto lacrimal 1-2 min (reduz absorção sistêmica)'),
        MedicamentoPilocarpina._textoObs('Contraindicado: irite aguda, uveíte anterior, descolamento retina recente'),
        MedicamentoPilocarpina._textoObs('Risco descolamento retina em miopia alta (>-6 dioptrias)'),
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
