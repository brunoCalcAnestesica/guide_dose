import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDaptomicina {
  static const String nome = 'Daptomicina';
  static const String idBulario = 'daptomicina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/daptomicina.json');
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
        _textoObs('Lipopeptídeo cíclico'),
        _textoObs('Bactericida concentração-dependente - despolariza membrana'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 350mg liofilizado', 'Cubicin®'),
        _linhaPreparo('Frasco 500mg liofilizado', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir com 7mL (350mg) ou 10mL (500mg) SF', ''),
        _linhaPreparo('Concentração final: 50 mg/mL', ''),
        _linhaPreparo('Infusão em 30 min ou bolus 2 min', ''),
        _linhaPreparo('NÃO diluir em soluções com glicose', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Bacteremia / Endocardite direita por S. aureus',
            descricaoDose: '6-10 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKgMinima: 6,
            dosePorKgMaxima: 10,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Infecções de pele e tecidos moles',
            descricaoDose: '4 mg/kg IV 1x/dia por 7-14 dias',
            unidade: 'mg',
            dosePorKg: 4,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Osteomielite / Artrite séptica',
            descricaoDose: '8-10 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKgMinima: 8,
            dosePorKgMaxima: 10,
            peso: peso,
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico 1-6 anos',
            descricaoDose: '10 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKg: 10,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico 7-17 anos',
            descricaoDose: '7 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKg: 7,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: MRSA, VRSA, VRE, Streptococcus, Enterococcus'),
        _textoObs('NÃO USAR EM PNEUMONIA - inativado pelo surfactante'),
        _textoObs('Monitorar CPK semanalmente (miopatia)'),
        _textoObs('Suspender se CPK >10x LSN ou sintomas musculares'),
        _textoObs('Evitar uso concomitante com estatinas'),
        _textoObs('Ajuste renal: ClCr <30 → dose padrão 48/48h'),
        _textoObs('Bacteremia persistente pode indicar necessidade de dose maior'),
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
