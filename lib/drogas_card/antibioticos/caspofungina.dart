import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCaspofungina {
  static const String nome = 'Caspofungina';
  static const String idBulario = 'caspofungina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/caspofungina.json');
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
        _linhaPreparo('Frasco 50mg liofilizado', 'Cancidas®'),
        _linhaPreparo('Frasco 70mg liofilizado', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir com 10,8mL água estéril', ''),
        _linhaPreparo('Diluir em 250mL SF ou SG 5%', ''),
        _linhaPreparo('Infusão em 1h', ''),
        _linhaPreparo('NÃO misturar com soluções com glicose concentrada', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(titulo: 'ATAQUE (1º dia)', descricaoDose: '70mg IV dose única', doseFixa: '70mg IV'),
          _linhaIndicacaoDoseFixa(titulo: 'MANUTENÇÃO (a partir do 2º dia)', descricaoDose: '50mg IV 1x/dia', doseFixa: '50mg IV/dia'),
          _linhaIndicacaoDoseFixa(titulo: 'Manutenção se peso >80kg', descricaoDose: '70mg IV 1x/dia', doseFixa: '70mg IV/dia'),
          _linhaIndicacaoDoseFixa(titulo: 'Hepatopatia moderada (Child-Pugh 7-9)', descricaoDose: '35mg IV 1x/dia (após ataque 70mg)', doseFixa: '35mg IV/dia'),
        ] else ...[
          _linhaIndicacaoDoseCalculada(titulo: 'Pediátrico 3 meses - 17 anos', descricaoDose: '70 mg/m² no 1º dia (máx 70mg), depois 50 mg/m²/dia (máx 70mg)', unidade: 'mg/m²', dosePorKg: 0, peso: peso),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: Candida (incluindo C. glabrata, C. krusei), Aspergillus'),
        _textoObs('NÃO cobre: Cryptococcus, Mucor, Fusarium'),
        _textoObs('NÃO penetra no LCR'),
        _textoObs('Não requer ajuste renal'),
        _textoObs('AJUSTE HEPÁTICO: Child-Pugh B (7-9) → 35mg/dia'),
        _textoObs('Interação com ciclosporina (pode aumentar transaminases)'),
        _textoObs('Interação com rifampicina, fenitoína, carbamazepina (aumentar dose)'),
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

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKg, required double peso}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(descricaoDose, style: const TextStyle(fontSize: 13)), const SizedBox(height: 4),
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade200)),
        child: Text('Dose baseada em superfície corporal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center)),
    ]));
  }

  static Widget _textoObs(String texto) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(texto, style: const TextStyle(fontSize: 13)))]));
  }
}
