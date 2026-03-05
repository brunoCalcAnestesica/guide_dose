import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoApixabana {
  static const String nome = 'Apixabana';
  static const String idBulario = 'apixabana';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/apixabana.json');
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
      conteudo: _buildCardApixabana(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardApixabana(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardApixabana(BuildContext context, double peso, bool isAdulto) {
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
        _linhaPreparo('Comprimido 2,5 mg', 'Dose reduzida'),
        _linhaPreparo('Comprimido 5 mg', 'Dose padrão'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar - Dose padrão',
            descricaoDose: '5 mg VO 12/12h',
            doseFixa: '5 mg 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar - Dose reduzida',
            descricaoDose: '2,5 mg VO 12/12h (se 2 de: idade ≥80, peso ≤60 kg, Cr ≥1,5)',
            doseFixa: '2,5 mg 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Tratamento inicial',
            descricaoDose: '10 mg VO 12/12h por 7 dias',
            doseFixa: '10 mg 12/12h x 7 dias',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Manutenção',
            descricaoDose: '5 mg VO 12/12h',
            doseFixa: '5 mg 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP - Prevenção prolongada',
            descricaoDose: '2,5 mg VO 12/12h (após 6 meses)',
            doseFixa: '2,5 mg 12/12h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia TVP cirúrgica',
            descricaoDose: '2,5 mg VO 12/12h por 12-35 dias',
            doseFixa: '2,5 mg 12/12h',
          ),
        ] else ...[
          _textoObs('Uso pediátrico: dados limitados'),
        ],

        // CRITÉRIOS DOSE REDUZIDA
        const SizedBox(height: 16),
        const Text('Critérios para Dose Reduzida (FA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Usar 2,5 mg 12/12h se ≥2 critérios:'),
        _textoObs('  • Idade ≥80 anos'),
        _textoObs('  • Peso ≤60 kg'),
        _textoObs('  • Creatinina ≥1,5 mg/dL'),

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Pode tomar com ou sem alimento'),
        _textoObs('Menor excreção renal dos DOACs (27%)'),
        _textoObs('Opção em IR moderada a grave'),
        _textoObs('Sem necessidade de monitoramento de rotina'),
        _textoObs('REVERSÃO: Andexanet alfa'),
        _textoObs('Suspender 48h antes de cirurgia alto risco'),
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
