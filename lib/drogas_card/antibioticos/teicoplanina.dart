import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTeicoplanina {
  static const String nome = 'Teicoplanina';
  static const String idBulario = 'teicoplanina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/teicoplanina.json');
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
        _textoObs('Glicopeptídeo (similar à vancomicina)'),
        _textoObs('Bactericida - inibe síntese da parede celular'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 200mg liofilizado', 'Targocid®'),
        _linhaPreparo('Frasco 400mg liofilizado', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir lentamente com diluente próprio', ''),
        _linhaPreparo('IV direto em 3-5 min ou diluir em 50mL', ''),
        _linhaPreparo('IM: pode ser administrado', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dose de ataque (infecções moderadas-graves)',
            descricaoDose: '6 mg/kg IV/IM 12/12h × 3 doses',
            unidade: 'mg',
            dosePorKg: 6,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (infecções moderadas)',
            descricaoDose: '6 mg/kg IV/IM 1x/dia',
            unidade: 'mg',
            dosePorKg: 6,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Infecções graves (endocardite, osteomielite)',
            descricaoDose: '12 mg/kg IV 12/12h × 3-5 doses, depois 12 mg/kg 1x/dia',
            unidade: 'mg',
            dosePorKg: 12,
            peso: peso,
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Ataque',
            descricaoDose: '10 mg/kg IV 12/12h × 3 doses',
            unidade: 'mg',
            dosePorKg: 10,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Manutenção',
            descricaoDose: '6-10 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKgMinima: 6,
            dosePorKgMaxima: 10,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: MRSA, Enterococcus (exceto VRE), cocos Gram+'),
        _textoObs('Vantagens vs vancomicina: 1x/dia, pode dar IM, menos nefrotóxico'),
        _textoObs('Meia-vida LONGA: 100-170h (permite dose única diária)'),
        _textoObs('Vale sérico alvo: 15-30 mcg/mL (infecções graves: 30-40)'),
        _textoObs('Ajuste renal: ClCr <40 → dose normal por 3 dias, depois 50% ou alternar dias'),
        _textoObs('Monitorar função renal e auditiva'),
        _textoObs('Menor risco de síndrome do homem vermelho'),
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

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKg, double? dosePorKgMinima, double? dosePorKgMaxima, required double peso}) {
    String? textoDose;
    if (dosePorKg != null) {
      textoDose = '${(dosePorKg * peso).toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
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
