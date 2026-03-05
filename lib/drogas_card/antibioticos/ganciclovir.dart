import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoGanciclovir {
  static const String nome = 'Ganciclovir';
  static const String idBulario = 'ganciclovir';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ganciclovir.json');
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
        _textoObs('Antiviral - análogo de nucleosídeo'),
        _textoObs('Virostático - inibe DNA polimerase viral (CMV)'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 500mg liofilizado', 'Cymevene®'),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir 500mg em 10mL água estéril', '50 mg/mL'),
        _linhaPreparo('Diluir em 100mL SF ou SG 5%', 'Máx 10 mg/mL'),
        _linhaPreparo('Infusão em 1h', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(titulo: 'INDUÇÃO (CMV ativo)', descricaoDose: '5 mg/kg IV 12/12h por 14-21 dias', unidade: 'mg', dosePorKg: 5, peso: peso),
          _linhaIndicacaoDoseCalculada(titulo: 'MANUTENÇÃO (profilaxia secundária)', descricaoDose: '5 mg/kg IV 1x/dia ou 6 mg/kg 5x/semana', unidade: 'mg', dosePorKg: 5, peso: peso),
          _linhaIndicacaoDoseFixa(titulo: 'Profilaxia transplante (valganciclovir VO)', descricaoDose: '900mg VO 1x/dia', doseFixa: '900mg VO/dia'),
        ] else ...[
          _linhaIndicacaoDoseCalculada(titulo: 'Pediátrico - CMV congênito sintomático', descricaoDose: '6 mg/kg IV 12/12h por 6 semanas', unidade: 'mg', dosePorKg: 6, peso: peso),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('DROGA DE ESCOLHA para CMV'),
        _textoObs('Espectro: CMV, HSV, VZV, HHV-6'),
        _textoObs('MIELOTOXICIDADE: neutropenia (30-40%), trombocitopenia'),
        _textoObs('Monitorar hemograma 2-3x/semana na indução'),
        _textoObs('Ajuste renal OBRIGATÓRIO:'),
        _textoObs('  ClCr 50-69: 2,5 mg/kg 12/12h'),
        _textoObs('  ClCr 25-49: 2,5 mg/kg 24/24h'),
        _textoObs('  ClCr 10-24: 1,25 mg/kg 24/24h'),
        _textoObs('Valganciclovir: pró-droga oral (900mg = 5 mg/kg IV)'),
        _textoObs('TERATOGÊNICO - contracepção obrigatória'),
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

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKg, required double peso}) {
    String? textoDose;
    if (dosePorKg != null) textoDose = '${(dosePorKg * peso).toStringAsFixed(0)} $unidade';
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(descricaoDose, style: const TextStyle(fontSize: 13)),
      if (textoDose != null) ...[const SizedBox(height: 4), Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade200)),
        child: Text('Dose calculada: $textoDose', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center))],
    ]));
  }

  static Widget _textoObs(String texto) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(texto, style: const TextStyle(fontSize: 13)))]));
  }
}
