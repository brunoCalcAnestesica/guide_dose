import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAnfotericinab {
  static const String nome = 'Anfotericina B';
  static const String idBulario = 'anfotericina_b';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/anfotericina_b.json');
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
        _textoObs('Antifúngico poliênico'),
        _textoObs('Fungicida - liga-se ao ergosterol e forma poros'),

        const SizedBox(height: 16),
        const Text('Formulações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('LIPOSSOMAL (AmBisome)', 'Menos nefrotóxica - PREFERIDA'),
        _linhaPreparo('DEOXICOLATO (convencional)', 'Mais nefrotóxica'),
        _linhaPreparo('Complexo lipídico (Abelcet)', ''),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Lipossomal: Frasco 50mg liofilizado', 'AmBisome®'),
        _linhaPreparo('Deoxicolato: Frasco 50mg liofilizado', 'Fungizone®'),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Lipossomal: reconstituir com água estéril', ''),
        _linhaPreparo('Diluir APENAS em SG 5%', 'NÃO usar SF'),
        _linhaPreparo('Infusão em 2h (lipossomal) ou 4-6h (deoxicolato)', ''),
        _linhaPreparo('Proteger da luz durante infusão', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'LIPOSSOMAL - Aspergilose invasiva',
            descricaoDose: '3-5 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKgMinima: 3,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'LIPOSSOMAL - Candidemia/Candida invasiva',
            descricaoDose: '3-5 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKgMinima: 3,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'LIPOSSOMAL - Meningite criptocócica',
            descricaoDose: '4-6 mg/kg IV 1x/dia (+ flucitosina)',
            unidade: 'mg',
            dosePorKgMinima: 4,
            dosePorKgMaxima: 6,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'LIPOSSOMAL - Mucormicose',
            descricaoDose: '5-10 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 10,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'DEOXICOLATO - Dose padrão',
            descricaoDose: '0,5-1 mg/kg IV 1x/dia (iniciar 0,25 mg/kg como teste)',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1,
            peso: peso,
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Lipossomal',
            descricaoDose: '3-5 mg/kg IV 1x/dia',
            unidade: 'mg',
            dosePorKgMinima: 3,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro AMPLO: Candida, Aspergillus, Cryptococcus, Mucor, Histoplasma'),
        _textoObs('NEFROTOXICIDADE: principal limitação (hidratação prévia ajuda)'),
        _textoObs('Reações de infusão: febre, calafrios, rigidez (pré-medicar)'),
        _textoObs('Hipocalemia e hipomagnesemia: repor eletrólitos'),
        _textoObs('Monitorar: creatinina, K+, Mg2+ 2-3x/semana'),
        _textoObs('NÃO diluir em SF (precipita)'),
        _textoObs('Pré-medicação: paracetamol + difenidramina ± hidrocortisona'),
        _textoObs('LIPOSSOMAL preferida: menor nefrotoxicidade, doses maiores'),
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

  static Widget _linhaIndicacaoDoseCalculada({required String titulo, required String descricaoDose, String? unidade, double? dosePorKgMinima, double? dosePorKgMaxima, required double peso}) {
    String? textoDose;
    if (dosePorKgMinima != null && dosePorKgMaxima != null) {
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
