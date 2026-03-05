import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFluconazol {
  static const String nome = 'Fluconazol';
  static const String idBulario = 'fluconazol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/fluconazol.json');
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
        _textoObs('Antifúngico triazólico'),
        _textoObs('Fungistático - inibe síntese de ergosterol'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 200mg/100mL solução IV', 'Diflucan®'),
        _linhaPreparo('Frasco 400mg/200mL solução IV', ''),
        _linhaPreparo('Cápsula 50mg, 100mg, 150mg, 200mg', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Solução pronta para uso IV', ''),
        _linhaPreparo('Infusão em 1-2h (máx 200mg/h)', ''),
        _linhaPreparo('Biodisponibilidade oral ~90%', 'IV = VO'),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Candidemia - Dose de ataque',
            descricaoDose: '800mg (12 mg/kg) IV no 1º dia',
            unidade: 'mg',
            dosePorKg: 12,
            doseMaxima: 800,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Candidemia - Manutenção',
            descricaoDose: '400mg (6 mg/kg) IV/VO 1x/dia',
            unidade: 'mg',
            dosePorKg: 6,
            doseMaxima: 400,
            peso: peso,
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Candidíase orofaríngea',
            descricaoDose: '200mg no 1º dia, depois 100-200mg/dia por 7-14 dias',
            doseFixa: '100-200mg VO/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Candidíase esofágica',
            descricaoDose: '200-400mg/dia por 14-21 dias',
            doseFixa: '200-400mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Meningite criptocócica (manutenção)',
            descricaoDose: '400-800mg/dia',
            doseFixa: '400-800mg/dia',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Candidíase invasiva',
            descricaoDose: '12 mg/kg ataque, 6-12 mg/kg/dia manutenção',
            unidade: 'mg',
            dosePorKgMinima: 6,
            dosePorKgMaxima: 12,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: Candida albicans, C. parapsilosis, C. tropicalis, Cryptococcus'),
        _textoObs('NÃO cobre: C. krusei (intrínseco), C. glabrata (frequente)'),
        _textoObs('NÃO cobre: Aspergillus, Mucor'),
        _textoObs('Excelente penetração no LCR'),
        _textoObs('Prolonga QT - evitar com outros medicamentos que prolongam QT'),
        _textoObs('Ajuste renal: ClCr <50 → 50% da dose'),
        _textoObs('Múltiplas interações (inibe CYP2C9, CYP2C19, CYP3A4)'),
        _textoObs('Hepatotoxicidade: monitorar transaminases'),
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

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKg, double? dosePorKgMinima, double? dosePorKgMaxima, double? doseMaxima, required double peso}) {
    String? textoDose;
    if (dosePorKg != null) {
      double dose = dosePorKg * peso;
      if (doseMaxima != null && dose > doseMaxima) dose = doseMaxima;
      textoDose = '${dose.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      textoDose = '${(dosePorKgMinima * peso).toStringAsFixed(0)}–${(dosePorKgMaxima * peso).toStringAsFixed(0)} $unidade';
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
