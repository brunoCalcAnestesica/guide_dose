import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAztreonam {
  static const String nome = 'Aztreonam';
  static const String idBulario = 'aztreonam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/aztreonam.json');
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
        _textoObs('Monobactâmico'),
        _textoObs('Bactericida - SOMENTE GRAM-NEGATIVOS aeróbios'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 500mg liofilizado', 'Azactam®'),
        _linhaPreparo('Frasco 1g liofilizado', ''),
        _linhaPreparo('Frasco 2g liofilizado', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir em 6-10mL água/SF', ''),
        _linhaPreparo('Diluir em 50-100mL SF ou SG 5%', ''),
        _linhaPreparo('Infusão em 20-60 min', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Infecções moderadas',
            descricaoDose: '1-2g IV a cada 8-12h',
            doseFixa: '1-2g IV 8/8-12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Infecções graves / Pseudomonas',
            descricaoDose: '2g IV a cada 6-8h (máx 8g/dia)',
            doseFixa: '2g IV 6/6-8/8h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'ITU não complicada',
            descricaoDose: '500mg-1g IV a cada 8-12h',
            doseFixa: '500mg-1g IV 8/8-12/12h',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico',
            descricaoDose: '90-120 mg/kg/dia IV dividido 6/6-8/8h',
            unidade: 'mg/dia',
            dosePorKgMinima: 90,
            dosePorKgMaxima: 120,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('SOMENTE GRAM-NEGATIVOS AERÓBIOS'),
        _textoObs('Cobre: Pseudomonas, Enterobactérias'),
        _textoObs('NÃO cobre: Gram+, anaeróbios, Acinetobacter'),
        _textoObs('SEGURO em alergia a penicilinas (sem reação cruzada)'),
        _textoObs('Opção em alérgicos para cobertura Gram-'),
        _textoObs('Ajuste renal: ClCr 10-30 → dose inicial, depois 50%'),
        _textoObs('Geralmente associado a vancomicina/metronidazol'),
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
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade200)),
            child: Text('Dose: $doseFixa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center),
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
