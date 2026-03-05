import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAnidulafungina {
  static const String nome = 'Anidulafungina';
  static const String idBulario = 'anidulafungina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/anidulafungina.json');
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
        _linhaPreparo('Frasco 100mg liofilizado', 'Ecalta®/Eraxis®'),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir com 30mL água estéril', '3,33 mg/mL'),
        _linhaPreparo('Diluir: 200mg em 200mL ou 100mg em 100mL', ''),
        _linhaPreparo('Infusão: máx 1,1 mg/min', ''),
        _linhaPreparo('200mg → ~3h de infusão; 100mg → ~1,5h', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(titulo: 'ATAQUE (1º dia)', descricaoDose: '200mg IV dose única', doseFixa: '200mg IV'),
          _linhaIndicacaoDoseFixa(titulo: 'MANUTENÇÃO (a partir do 2º dia)', descricaoDose: '100mg IV 1x/dia', doseFixa: '100mg IV/dia'),
        ] else ...[
          _textoObs('Pediátrico: dados limitados'),
          _textoObs('Dose off-label: 1,5 mg/kg ataque, 0,75 mg/kg manutenção'),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: Candida (incluindo C. glabrata, C. krusei)'),
        _textoObs('NÃO cobre: Cryptococcus, Mucor, Aspergillus (atividade limitada)'),
        _textoObs('NÃO penetra no LCR'),
        _textoObs('NÃO requer ajuste renal'),
        _textoObs('NÃO requer ajuste hepático'),
        _textoObs('SEM interações significativas (não metabolizada por CYP)'),
        _textoObs('Degradação química (não enzimática)'),
        _textoObs('Infusão lenta obrigatória (reações histaminoides se rápida)'),
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
    final bool isAtaque = titulo.contains('ATAQUE');
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(descricaoDose, style: const TextStyle(fontSize: 13)), const SizedBox(height: 4),
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
        decoration: BoxDecoration(color: isAtaque ? Colors.orange.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: isAtaque ? Colors.orange.shade200 : Colors.blue.shade200)),
        child: Text('Dose: $doseFixa', style: TextStyle(fontWeight: FontWeight.bold, color: isAtaque ? Colors.orange.shade700 : Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center)),
    ]));
  }

  static Widget _textoObs(String texto) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(texto, style: const TextStyle(fontSize: 13)))]));
  }
}
