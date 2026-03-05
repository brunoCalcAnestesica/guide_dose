import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoEdoxabana {
  static const String nome = 'Edoxabana';
  static const String idBulario = 'edoxabana';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/edoxabana.json');
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
      conteudo: _buildCardEdoxabana(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardEdoxabana(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardEdoxabana(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('DOAC', 'Anticoagulante oral direto'),
        _linhaPreparo('Inibidor direto do fator Xa', ''),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 15 mg', 'Dose reduzida'),
        _linhaPreparo('Comprimido 30 mg', 'Dose reduzida'),
        _linhaPreparo('Comprimido 60 mg', 'Dose padrão'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar - Dose padrão',
            descricaoDose: '60 mg VO 1x/dia',
            doseFixa: '60 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar - Dose reduzida',
            descricaoDose: '30 mg VO 1x/dia (se ClCr 15-50, peso ≤60 kg, ou uso inibidor P-gp)',
            doseFixa: '30 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Tratamento',
            descricaoDose: '60 mg VO 1x/dia (após ≥5 dias de anticoagulante parenteral)',
            doseFixa: '60 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Dose reduzida',
            descricaoDose: '30 mg VO 1x/dia (se critérios)',
            doseFixa: '30 mg/dia',
          ),
        ] else ...[
          _textoObs('Uso pediátrico: dados limitados'),
        ],

        // CRITÉRIOS DOSE REDUZIDA
        const SizedBox(height: 16),
        const Text('Critérios para Dose 30 mg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('• ClCr 15-50 mL/min'),
        _textoObs('• Peso ≤60 kg'),
        _textoObs('• Uso de inibidores P-gp (ciclosporina, dronedarona, eritromicina, cetoconazol)'),

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('UMA DOSE DIÁRIA (vantagem de adesão)'),
        _textoObs('Pode tomar com ou sem alimento'),
        _textoObs('ATENÇÃO: ClCr >95 → eficácia reduzida em FA'),
        _textoObs('CONTRAINDICADO: ClCr <15 mL/min'),
        _textoObs('Sem necessidade de monitoramento de rotina'),
        _textoObs('REVERSÃO: Andexanet alfa'),
        _textoObs('Requer anticoagulação parenteral prévia para TVP/TEP'),
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
