import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoVitaminaK {
  static const String nome = 'Vitamina K';
  static const String idBulario = 'vitamina_k';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/vitamina_k.json');
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
      conteudo: _buildCardVitaminaK(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardVitaminaK(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardVitaminaK(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Vitamina lipossolúvel', 'Fitomenadiona (K1)'),
        _linhaPreparo('Antídoto', 'Reversão de anticoagulantes cumarínicos'),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 10 mg/mL', '1 mL'),
        _linhaPreparo('Comprimido 10 mg', 'Via oral'),
        _linhaPreparo('Gotas 20 mg/mL', 'Via oral'),

        // PREPARO
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('IV: diluir em 50 mL SF ou SG 5%', ''),
        _linhaPreparo('Infundir LENTAMENTE (>30 min)', 'Risco de anafilaxia'),
        _linhaPreparo('VO: preferir quando possível', 'Mais seguro'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'INR elevado sem sangramento (INR 4,5-10)',
            descricaoDose: 'Suspender warfarina, monitorar',
            doseFixa: 'Considerar 1-2,5 mg VO',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'INR >10 sem sangramento',
            descricaoDose: '2,5-5 mg VO',
            doseFixa: '2,5-5 mg VO',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Sangramento significativo',
            descricaoDose: '5-10 mg IV lento + PFC ou CCP',
            doseFixa: '5-10 mg IV',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia grave/risco de vida',
            descricaoDose: '10 mg IV lento + CCP 4 fatores',
            doseFixa: '10 mg IV + CCP',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Pré-procedimento (INR elevado)',
            descricaoDose: '1-2,5 mg VO 24h antes',
            doseFixa: '1-2,5 mg VO',
          ),
        ] else ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Pediátrico - Reversão warfarina',
            descricaoDose: '0,5-5 mg IV/VO conforme gravidade',
            doseFixa: '0,5-5 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Neonato - Profilaxia DHRN',
            descricaoDose: '0,5-1 mg IM ao nascimento',
            doseFixa: '0,5-1 mg IM',
          ),
        ],

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('INÍCIO DE AÇÃO IV: 1-2h (INR normaliza em 12-24h)'),
        _textoObs('INÍCIO DE AÇÃO VO: 6-10h'),
        _textoObs('Via IV: RISCO DE ANAFILAXIA - infundir lento'),
        _textoObs('Preferir via ORAL quando possível'),
        _textoObs('NÃO reverte DOACs (dabigatrana, rivaroxabana, etc.)'),
        _textoObs('Doses altas podem dificultar re-anticoagulação'),
        _textoObs('Em sangramento grave: associar CCP ou PFC'),
        _textoObs('Monitorar INR a cada 6-12h após dose'),
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
