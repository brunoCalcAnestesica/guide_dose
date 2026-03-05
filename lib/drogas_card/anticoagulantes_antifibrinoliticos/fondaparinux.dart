import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFondaparinux {
  static const String nome = 'Fondaparinux';
  static const String idBulario = 'fondaparinux';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/fondaparinux.json');
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
      conteudo: _buildCardFondaparinux(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardFondaparinux(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardFondaparinux(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anticoagulante', 'Inibidor indireto do fator Xa'),
        _linhaPreparo('Pentassacarídeo sintético', ''),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Seringa preenchida 2,5 mg/0,5 mL', 'Profilaxia'),
        _linhaPreparo('Seringa preenchida 5 mg/0,4 mL', 'Tratamento'),
        _linhaPreparo('Seringa preenchida 7,5 mg/0,6 mL', 'Tratamento'),
        _linhaPreparo('Seringa preenchida 10 mg/0,8 mL', 'Tratamento'),

        // ADMINISTRAÇÃO
        const SizedBox(height: 16),
        const Text('Administração', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Via subcutânea APENAS', ''),
        _linhaPreparo('Alternar locais de aplicação', 'Abdome, coxa'),
        _linhaPreparo('Não expulsar bolha de ar', ''),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia TVP/TEP',
            descricaoDose: '2,5 mg SC 1x/dia',
            doseFixa: '2,5 mg SC/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Tratamento TVP/TEP (<50 kg)',
            descricaoDose: '5 mg SC 1x/dia',
            doseFixa: '5 mg SC/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Tratamento TVP/TEP (50-100 kg)',
            descricaoDose: '7,5 mg SC 1x/dia',
            doseFixa: '7,5 mg SC/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Tratamento TVP/TEP (>100 kg)',
            descricaoDose: '10 mg SC 1x/dia',
            doseFixa: '10 mg SC/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'SCA sem supra ST (IAMSSST)',
            descricaoDose: '2,5 mg SC 1x/dia por até 8 dias',
            doseFixa: '2,5 mg SC/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'IAM com supra ST (IAMCSST)',
            descricaoDose: '2,5 mg IV seguido de 2,5 mg SC/dia',
            doseFixa: '2,5 mg IV → 2,5 mg SC/dia',
          ),
        ] else ...[
          _textoObs('Uso pediátrico: dados limitados'),
          _textoObs('Não recomendado em < 17 anos'),
        ],

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('NÃO causa HIT (não interage com PF4)'),
        _textoObs('Alternativa em pacientes com história de HIT'),
        _textoObs('Meia-vida longa: 17-21 horas'),
        _textoObs('Excreção renal - CONTRAINDICADO se ClCr <30'),
        _textoObs('Não monitorar TTPa (não altera)'),
        _textoObs('Anti-Xa pode ser usado se necessário'),
        _textoObs('NÃO tem antídoto específico'),
        _textoObs('Protamina NÃO reverte'),
        _textoObs('Iniciar profilaxia 6-8h após cirurgia'),
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
