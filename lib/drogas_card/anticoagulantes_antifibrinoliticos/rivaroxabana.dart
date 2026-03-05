import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRivaroxabana {
  static const String nome = 'Rivaroxabana';
  static const String idBulario = 'rivaroxabana';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/rivaroxabana.json');
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
      conteudo: _buildCardRivaroxabana(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardRivaroxabana(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardRivaroxabana(BuildContext context, double peso, bool isAdulto) {
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
        _linhaPreparo('Comprimido 10 mg', 'Profilaxia cirúrgica'),
        _linhaPreparo('Comprimido 15 mg', 'TVP/TEP inicial'),
        _linhaPreparo('Comprimido 20 mg', 'FA, TVP/TEP manutenção'),
        _linhaPreparo('Comprimido 2,5 mg', 'Dose vascular'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar (ClCr ≥50)',
            descricaoDose: '20 mg VO 1x/dia com alimento',
            doseFixa: '20 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar (ClCr 15-50)',
            descricaoDose: '15 mg VO 1x/dia com alimento',
            doseFixa: '15 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Tratamento inicial',
            descricaoDose: '15 mg VO 12/12h por 21 dias',
            doseFixa: '15 mg 12/12h x 21 dias',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Manutenção',
            descricaoDose: '20 mg VO 1x/dia',
            doseFixa: '20 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia TVP cirúrgica',
            descricaoDose: '10 mg VO 1x/dia por 12-35 dias',
            doseFixa: '10 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dose vascular (SCA/DAP)',
            descricaoDose: '2,5 mg VO 12/12h (+ AAS)',
            doseFixa: '2,5 mg 12/12h',
          ),
        ] else ...[
          _textoObs('Uso pediátrico: dados limitados'),
          _textoObs('Formulação pediátrica disponível em alguns países'),
        ],

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('TOMAR COM ALIMENTO (doses 15 e 20 mg)'),
        _textoObs('CONTRAINDICADO: ClCr <15 mL/min'),
        _textoObs('Sem necessidade de monitoramento de rotina'),
        _textoObs('Anti-Xa calibrado pode avaliar atividade'),
        _textoObs('REVERSÃO: Andexanet alfa'),
        _textoObs('Suspender 24h antes de cirurgia (ClCr normal)'),
        _textoObs('Evitar com inibidores/indutores CYP3A4 e P-gp'),
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
