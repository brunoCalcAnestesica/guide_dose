import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAAS {
  static const String nome = 'AAS';
  static const String idBulario = 'aas';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/aas.json');
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
      conteudo: _buildCardAAS(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardAAS(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardAAS(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Antiagregante plaquetário', 'Inibidor COX-1 irreversível'),
        _linhaPreparo('Ácido Acetilsalicílico', 'Aspirina'),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 100 mg', 'Infantil/Cardio'),
        _linhaPreparo('Comprimido 325 mg', ''),
        _linhaPreparo('Comprimido 500 mg', 'Adulto'),
        _linhaPreparo('Comprimido tamponado/revestido', 'Menor irritação gástrica'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'SCA/IAM - Dose de ataque',
            descricaoDose: '160-325 mg VO mastigado',
            doseFixa: '300 mg mastigado',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Manutenção cardiovascular',
            descricaoDose: '75-100 mg VO 1x/dia',
            doseFixa: '100 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'AVC isquêmico agudo',
            descricaoDose: '160-300 mg VO nas primeiras 48h',
            doseFixa: '300 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Pós-ICP/Stent',
            descricaoDose: '75-100 mg/dia (+ inibidor P2Y12)',
            doseFixa: '100 mg/dia + DAPT',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Prevenção primária (alto risco)',
            descricaoDose: '75-100 mg VO 1x/dia',
            doseFixa: '100 mg/dia',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Kawasaki (fase aguda)',
            descricaoDose: '80-100 mg/kg/dia VO dividido 6/6h',
            unidade: 'mg/dia',
            dosePorKgMinima: 80,
            dosePorKgMaxima: 100,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Kawasaki (manutenção)',
            descricaoDose: '3-5 mg/kg/dia VO 1x/dia',
            unidade: 'mg/dia',
            dosePorKgMinima: 3,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
        ],

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('INÍCIO DE AÇÃO: 15-30 min (mastigado mais rápido)'),
        _textoObs('Efeito IRREVERSÍVEL - dura vida da plaqueta (7-10 dias)'),
        _textoObs('Suspender 7 dias antes de cirurgias eletivas'),
        _textoObs('CONTRAINDICADO: alergia, úlcera ativa, sangramento'),
        _textoObs('EVITAR em dengue (risco de sangramento)'),
        _textoObs('Interação: ibuprofeno pode bloquear efeito'),
        _textoObs('Gastroproteção com IBP se alto risco GI'),
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

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      textoDose = '${doseMin.toStringAsFixed(0)}-${doseMax.toStringAsFixed(0)} $unidade';
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
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseFixa({
    required String titulo,
    required String descricaoDose,
    required String doseFixa,
  }) {
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
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
