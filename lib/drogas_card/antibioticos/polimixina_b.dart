import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPolimixinaB {
  static const String nome = 'Polimixina B';
  static const String idBulario = 'polimixina_b';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/polimixina_b.json');
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
      conteudo: _buildCardContent(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardContent(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardContent(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Polimixina (polipeptídeo catiônico)'),
        _textoObs('Bactericida - desestrutura membrana externa de Gram-'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 500.000 UI liofilizado', ''),
        _linhaPreparo('1 mg = 10.000 UI', 'Conversão'),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir em 5mL água estéril', ''),
        _linhaPreparo('Diluir em 250-500mL SG 5%', ''),
        _linhaPreparo('Infusão em 60-90 min', 'Evitar infusão rápida'),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dose padrão',
            descricaoDose: '15.000-25.000 UI/kg/dia IV dividido 12/12h',
            unidade: 'UI/dia',
            dosePorKgMinima: 15000,
            dosePorKgMaxima: 25000,
            peso: peso,
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dose máxima',
            descricaoDose: '2.000.000 UI/dia (200 mg/dia)',
            doseFixa: '1.000.000 UI 12/12h',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico',
            descricaoDose: '15.000-25.000 UI/kg/dia IV dividido 12/12h',
            unidade: 'UI/dia',
            dosePorKgMinima: 15000,
            dosePorKgMaxima: 25000,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: P. aeruginosa MDR, Acinetobacter, K. pneumoniae KPC'),
        _textoObs('NÃO cobre: Proteus, Serratia, Burkholderia, Gram+'),
        _textoObs('ÚLTIMA LINHA para Gram-negativos multirresistentes'),
        _textoObs('NEFROTOXICIDADE: monitorar creatinina diariamente'),
        _textoObs('NEUROTOXICIDADE: parestesias, bloqueio neuromuscular'),
        _textoObs('NÃO requer ajuste renal (excreção não-renal)'),
        _textoObs('Diferente da colistina: não precisa de dose de ataque'),
        _textoObs('Pode causar hiperpigmentação cutânea'),
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

  static Widget _linhaIndicacaoDoseFixa({required String titulo, required String descricaoDose, required String doseFixa}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange.shade200)),
            child: Text('Máximo: $doseFixa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700, fontSize: 13), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKgMinima, double? dosePorKgMaxima, required double peso}) {
    String? textoDose;
    if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      textoDose = '${(dosePorKgMinima * peso).toStringAsFixed(0)}–${(dosePorKgMaxima * peso).toStringAsFixed(0)} $unidade';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade200)),
              child: Text('Dose calculada: $textoDose', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}
