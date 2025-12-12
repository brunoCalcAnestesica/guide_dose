import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPentazocina {
  static const String nome = 'Pentazocina';
  static const String idBulario = 'pentazocina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/pentazocina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardPentazocina(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Pentazocina não é recomendada para pediatria
    return faixaEtaria == 'Adolescente' ||
        faixaEtaria == 'Adulto' ||
        faixaEtaria == 'Idoso';
  }

  static Widget _buildCardPentazocina(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Analgésico Opioide Agonista-Antagonista',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPentazocina._linhaPreparo(
            '• Solução injetável: 30 mg/mL (ampola 1 mL)'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPentazocina._linhaPreparo(
            '• IV: diluir 30 mg em 10-20 mL de SF 0,9%'),
        MedicamentoPentazocina._linhaPreparo('• Administrar lentamente'),
        MedicamentoPentazocina._linhaPreparo('• IM/SC: administrar puro'),
        const SizedBox(height: 16),
        const Text('Indicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPentazocina._textoObs(
            '• Dose máxima: 600 mg/dia VO, 360 mg/dia parenteral'),
        MedicamentoPentazocina._textoObs(
            '• Contraindicado em uso com outros opioides'),
        MedicamentoPentazocina._textoObs(
            '• Risco de efeitos psicomiméticos (disforia, confusão)'),
        MedicamentoPentazocina._textoObs('• Ter naloxona disponível'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(
      String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoPentazocina._linhaIndicacaoDoseFixa(
            titulo: 'Dor moderada a intensa (VO)',
            descricaoDose: 'Dose: 50-100 mg a cada 3-4h',
            doseFixa: '50-100 mg/dose',
          ),
          MedicamentoPentazocina._linhaIndicacaoDoseFixa(
            titulo: 'Dor moderada a intensa (IM/SC)',
            descricaoDose: 'Dose: 30-60 mg a cada 3-4h',
            doseFixa: '30-60 mg/dose',
          ),
          MedicamentoPentazocina._linhaIndicacaoDoseFixa(
            titulo: 'Dor intensa (IV)',
            descricaoDose: 'Dose: 30 mg a cada 3-4h IV lento',
            doseFixa: '30 mg/dose',
          ),
        ]);
        break;
    }

    return indicacoes;
  }

  static Widget _linhaPreparo(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
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
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }
}
