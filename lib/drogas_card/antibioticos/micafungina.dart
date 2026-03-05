import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMicafungina {
  static const String nome = 'Micafungina';
  static const String idBulario = 'micafungina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/micafungina.json');
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
        _textoObs('Equinocandina'),
        _textoObs('Fungicida - inibe síntese de 1,3-beta-D-glucana'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 50mg liofilizado', 'Mycamine®'),
        _linhaPreparo('Frasco 100mg liofilizado', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir com 5mL SF ou SG 5%', ''),
        _linhaPreparo('Diluir em 100mL SF ou SG 5%', ''),
        _linhaPreparo('Infusão em 1h', ''),
        _linhaPreparo('Proteger da luz', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(titulo: 'Candidemia / Candida invasiva', descricaoDose: '100mg IV 1x/dia', doseFixa: '100mg IV/dia'),
          _linhaIndicacaoDoseFixa(titulo: 'Candidíase esofágica', descricaoDose: '150mg IV 1x/dia', doseFixa: '150mg IV/dia'),
          _linhaIndicacaoDoseFixa(titulo: 'Profilaxia (transplante/neutropenia)', descricaoDose: '50mg IV 1x/dia', doseFixa: '50mg IV/dia'),
        ] else ...[
          _linhaIndicacaoDoseCalculada(titulo: 'Pediátrico ≤40 kg - Candidemia', descricaoDose: '2 mg/kg IV 1x/dia (máx 100mg)', unidade: 'mg', dosePorKg: 2, doseMaxima: 100, peso: peso),
          _linhaIndicacaoDoseCalculada(titulo: 'Pediátrico ≤40 kg - Profilaxia', descricaoDose: '1 mg/kg IV 1x/dia (máx 50mg)', unidade: 'mg', dosePorKg: 1, doseMaxima: 50, peso: peso),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: Candida (incluindo C. glabrata, C. krusei), Aspergillus'),
        _textoObs('NÃO cobre: Cryptococcus, Mucor, Fusarium'),
        _textoObs('NÃO penetra no LCR'),
        _textoObs('Não requer ajuste renal ou hepático leve-moderado'),
        _textoObs('Mínimas interações medicamentosas'),
        _textoObs('Bem tolerada - poucos efeitos adversos'),
        _textoObs('Considerar para Candida em pacientes com IR ou em uso de nefrotóxicos'),
      ],
    );
  }

  static Widget _linhaPreparo(String texto, String marca) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: RichText(text: TextSpan(style: const TextStyle(color: Colors.black87), children: [TextSpan(text: texto), if (marca.isNotEmpty) ...[const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: marca, style: const TextStyle(fontStyle: FontStyle.italic))]]))),
    ]));
  }

  static Widget _linhaIndicacaoDoseFixa({required String titulo, required String descricaoDose, required String doseFixa}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(descricaoDose, style: const TextStyle(fontSize: 13)), const SizedBox(height: 4),
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade200)),
        child: Text('Dose: $doseFixa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center)),
    ]));
  }

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKg, double? doseMaxima, required double peso}) {
    double dose = (dosePorKg ?? 0) * peso;
    if (doseMaxima != null && dose > doseMaxima) dose = doseMaxima;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(descricaoDose, style: const TextStyle(fontSize: 13)), const SizedBox(height: 4),
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade200)),
        child: Text('Dose calculada: ${dose.toStringAsFixed(0)} $unidade', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center)),
    ]));
  }

  static Widget _textoObs(String texto) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(texto, style: const TextStyle(fontSize: 13)))]));
  }
}
