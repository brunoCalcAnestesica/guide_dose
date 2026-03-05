import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoColistina {
  static const String nome = 'Colistina';
  static const String idBulario = 'colistina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/colistina.json');
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
        _textoObs('Polimixina E (colistimetato de sódio - pró-droga)'),
        _textoObs('Bactericida - desestrutura membrana externa de Gram-'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 1.000.000 UI (CMS)', ''),
        _linhaPreparo('Frasco 4.500.000 UI (CMS)', ''),
        _linhaPreparo('Conversão: 1 milhão UI CMS ≈ 80 mg CMS ≈ 30 mg CBA', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir em água estéril', ''),
        _linhaPreparo('Diluir em 100-250mL SF', ''),
        _linhaPreparo('Infusão em 30-60 min', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'DOSE DE ATAQUE (obrigatória)',
            descricaoDose: '9 milhões UI IV dose única',
            doseFixa: '9.000.000 UI IV',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Manutenção (função renal normal)',
            descricaoDose: '4,5 milhões UI IV 12/12h (iniciar 12h após ataque)',
            doseFixa: '4.500.000 UI 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Ajuste ClCr 50-89',
            descricaoDose: '4,5 milhões UI IV 12/12h',
            doseFixa: '4.500.000 UI 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Ajuste ClCr 30-49',
            descricaoDose: '3,5 milhões UI IV 12/12h',
            doseFixa: '3.500.000 UI 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Ajuste ClCr 10-29',
            descricaoDose: '2,5 milhões UI IV 12/12h',
            doseFixa: '2.500.000 UI 12/12h',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico',
            descricaoDose: '75.000-150.000 UI/kg/dia dividido 8/8h',
            unidade: 'UI/dia',
            dosePorKgMinima: 75000,
            dosePorKgMaxima: 150000,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('DOSE DE ATAQUE É OBRIGATÓRIA (pró-droga lenta)'),
        _textoObs('Espectro: P. aeruginosa MDR, Acinetobacter, Klebsiella KPC'),
        _textoObs('NÃO cobre: Proteus, Serratia, Burkholderia, Gram+'),
        _textoObs('NEFROTOXICIDADE: 30-60% (ajustar por função renal)'),
        _textoObs('NEUROTOXICIDADE: parestesias, bloqueio neuromuscular'),
        _textoObs('Diferente da Polimixina B: REQUER ajuste renal'),
        _textoObs('Pode ser usada inalatória (pneumonia VAP)'),
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
    final bool isAtaque = titulo.contains('ATAQUE');
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
            decoration: BoxDecoration(
              color: isAtaque ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isAtaque ? Colors.red.shade200 : Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(fontWeight: FontWeight.bold, color: isAtaque ? Colors.red.shade700 : Colors.blue.shade700, fontSize: 13),
              textAlign: TextAlign.center,
            ),
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
