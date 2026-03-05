import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoVoriconazol {
  static const String nome = 'Voriconazol';
  static const String idBulario = 'voriconazol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/voriconazol.json');
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
        _textoObs('Antifúngico triazólico de 2ª geração'),
        _textoObs('Fungicida - inibe síntese de ergosterol'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 200mg liofilizado', 'Vfend®'),
        _linhaPreparo('Comprimido 50mg, 200mg', ''),
        _linhaPreparo('Suspensão oral 40mg/mL', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir com 19mL água estéril', '200mg → 10mg/mL'),
        _linhaPreparo('Diluir em SF ou SG 5%', 'Concentração 0,5-5 mg/mL'),
        _linhaPreparo('Infusão em 1-3h', 'Máx 3 mg/kg/h'),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'ATAQUE (1º dia) - IV',
            descricaoDose: '6 mg/kg IV 12/12h (2 doses)',
            unidade: 'mg',
            dosePorKg: 6,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'MANUTENÇÃO - IV',
            descricaoDose: '4 mg/kg IV 12/12h',
            unidade: 'mg',
            dosePorKg: 4,
            peso: peso,
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'MANUTENÇÃO - VO (>40 kg)',
            descricaoDose: '200mg VO 12/12h (pode aumentar para 300mg se necessário)',
            doseFixa: '200mg VO 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'MANUTENÇÃO - VO (<40 kg)',
            descricaoDose: '100mg VO 12/12h',
            doseFixa: '100mg VO 12/12h',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico 2-12 anos - Ataque',
            descricaoDose: '9 mg/kg IV 12/12h (2 doses)',
            unidade: 'mg',
            dosePorKg: 9,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico 2-12 anos - Manutenção',
            descricaoDose: '8 mg/kg IV 12/12h',
            unidade: 'mg',
            dosePorKg: 8,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Monitoramento Terapêutico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Vale sérico (pré-dose): alvo 1-5,5 mcg/mL'),
        _textoObs('Coletar após 5-7 dias (estado de equilíbrio)'),
        _textoObs('Vale <1: risco de falha; Vale >5,5: risco toxicidade'),

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('1ª ESCOLHA para Aspergilose invasiva'),
        _textoObs('Espectro: Aspergillus, Candida, Fusarium, Scedosporium'),
        _textoObs('NÃO cobre: Mucor (zigomicose)'),
        _textoObs('HEPATOTOXICIDADE: monitorar transaminases'),
        _textoObs('DISTÚRBIOS VISUAIS: visão turva, fotofobia (transitório)'),
        _textoObs('FOTOSSENSIBILIDADE: proteção solar rigorosa'),
        _textoObs('Múltiplas interações (CYP2C19, CYP2C9, CYP3A4)'),
        _textoObs('IV contraindicado se ClCr <50 (acúmulo de ciclodextrina)'),
      ],
    );
  }

  static Widget _linhaPreparo(String texto, String marca) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: RichText(text: TextSpan(style: const TextStyle(color: Colors.black87), children: [
          TextSpan(text: texto),
          if (marca.isNotEmpty) ...[const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: marca, style: const TextStyle(fontStyle: FontStyle.italic))],
        ]))),
      ]),
    );
  }

  static Widget _linhaIndicacaoDoseFixa({required String titulo, required String descricaoDose, required String doseFixa}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKg, required double peso}) {
    String? textoDose;
    if (dosePorKg != null) {
      textoDose = '${(dosePorKg * peso).toStringAsFixed(0)} $unidade';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
    ]));
  }
}
