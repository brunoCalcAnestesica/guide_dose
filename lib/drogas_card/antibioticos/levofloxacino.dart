import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoLevofloxacino {
  static const String nome = 'Levofloxacino';
  static const String idBulario = 'levofloxacino';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/levofloxacino.json');
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
        _textoObs('Fluoroquinolona respiratória (3ª geração)'),
        _textoObs('Bactericida - inibe DNA girase e topoisomerase IV'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 500mg/100mL solução', 'Levaquin®/Tavanic®'),
        _linhaPreparo('Comprimido 250mg, 500mg, 750mg', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Solução pronta para uso', ''),
        _linhaPreparo('Infusão em 60-90 min', 'Evitar infusão rápida'),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Pneumonia comunitária',
            descricaoDose: '500mg IV/VO 1x/dia por 7-14 dias ou 750mg 1x/dia por 5 dias',
            doseFixa: '500-750mg 1x/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Pneumonia nosocomial',
            descricaoDose: '750mg IV 1x/dia por 7-14 dias',
            doseFixa: '750mg IV 1x/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'ITU complicada / Pielonefrite',
            descricaoDose: '750mg IV/VO 1x/dia por 5-14 dias',
            doseFixa: '750mg 1x/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Prostatite',
            descricaoDose: '500mg IV/VO 1x/dia por 28 dias',
            doseFixa: '500mg 1x/dia',
          ),
        ] else ...[
          _textoObs('USO PEDIÁTRICO RESTRITO'),
          _textoObs('Risco de lesão articular/tendínea em crianças'),
          _textoObs('Usar apenas quando não há alternativa'),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: Gram+, Gram-, atípicos (Legionella, Mycoplasma, Chlamydia)'),
        _textoObs('FLUOROQUINOLONA RESPIRATÓRIA: melhor cobertura pneumococo'),
        _textoObs('BLACK BOX: tendinite/ruptura de tendão (especialmente idosos, corticoides)'),
        _textoObs('BLACK BOX: neuropatia periférica'),
        _textoObs('BLACK BOX: efeitos no SNC'),
        _textoObs('Prolonga QT - evitar com outros medicamentos que prolongam QT'),
        _textoObs('Ajuste renal: ClCr 20-50 → 750mg 48/48h; ClCr <20 → 750mg inicial, depois 500mg 48/48h'),
        _textoObs('Evitar em miastenia gravis'),
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
