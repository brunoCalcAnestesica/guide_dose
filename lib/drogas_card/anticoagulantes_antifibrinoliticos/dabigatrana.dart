import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDabigatrana {
  static const String nome = 'Dabigatrana';
  static const String idBulario = 'dabigatrana';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/dabigatrana.json');
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
      conteudo: _buildCardDabigatrana(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardDabigatrana(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardDabigatrana(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('DOAC', 'Anticoagulante oral direto'),
        _linhaPreparo('Inibidor direto da trombina (fator IIa)', ''),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Cápsula 75 mg', 'Dose reduzida'),
        _linhaPreparo('Cápsula 110 mg', 'Dose intermediária'),
        _linhaPreparo('Cápsula 150 mg', 'Dose padrão'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar - Dose padrão',
            descricaoDose: '150 mg VO 12/12h',
            doseFixa: '150 mg 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar - Dose reduzida',
            descricaoDose: '110 mg VO 12/12h (idade ≥80, alto risco sangramento, verapamil)',
            doseFixa: '110 mg 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Tratamento',
            descricaoDose: '150 mg VO 12/12h (após 5-10 dias de anticoagulante parenteral)',
            doseFixa: '150 mg 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia TVP cirúrgica',
            descricaoDose: '110 mg 1-4h pós-op, depois 220 mg/dia',
            doseFixa: '220 mg/dia',
          ),
        ] else ...[
          _textoObs('Uso pediátrico: dados limitados'),
        ],

        // CRITÉRIOS DOSE REDUZIDA
        const SizedBox(height: 16),
        const Text('Critérios para Dose 110 mg (FA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('• Idade ≥80 anos'),
        _textoObs('• Uso concomitante de verapamil'),
        _textoObs('• Alto risco de sangramento'),
        _textoObs('• ClCr 30-50 mL/min (considerar)'),

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('NÃO abrir, triturar ou mastigar cápsulas'),
        _textoObs('ALTA EXCREÇÃO RENAL (80%)'),
        _textoObs('CONTRAINDICADO: ClCr <30 mL/min'),
        _textoObs('ÚNICO DOAC DIALISÁVEL'),
        _textoObs('REVERSÃO ESPECÍFICA: Idarucizumab (Praxbind)'),
        _textoObs('Dispepsia frequente (IBP pode ajudar)'),
        _textoObs('Suspender 24-48h antes cirurgia'),
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
