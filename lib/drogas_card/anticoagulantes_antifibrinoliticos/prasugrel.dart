import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPrasugrel {
  static const String nome = 'Prasugrel';
  static const String idBulario = 'prasugrel';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/prasugrel.json');
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
      conteudo: _buildCardPrasugrel(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardPrasugrel(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardPrasugrel(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Antiagregante plaquetário', 'Inibidor P2Y12 irreversível'),
        _linhaPreparo('Tienopiridina de 3ª geração', 'Pró-droga'),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 5 mg', 'Manutenção (<60 kg)'),
        _linhaPreparo('Comprimido 10 mg', 'Manutenção (≥60 kg)'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'SCA (ICP planejada) - Dose de ataque',
            descricaoDose: '60 mg VO',
            doseFixa: '60 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Manutenção (≥60 kg)',
            descricaoDose: '10 mg VO 1x/dia (+ AAS)',
            doseFixa: '10 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Manutenção (<60 kg)',
            descricaoDose: '5 mg VO 1x/dia (+ AAS)',
            doseFixa: '5 mg/dia',
          ),
        ] else ...[
          _textoObs('NÃO indicado em pediatria'),
        ],

        // CONTRAINDICAÇÕES
        const SizedBox(height: 16),
        const Text('Contraindicações Específicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('AVC ou AIT prévio (QUALQUER tipo)'),
        _textoObs('Idade ≥75 anos (benefício não estabelecido)'),
        _textoObs('Peso <60 kg (maior risco sangramento)'),

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('INÍCIO DE AÇÃO: 15-30 min (ataque)'),
        _textoObs('Mais potente que clopidogrel'),
        _textoObs('Ativação mais rápida e consistente'),
        _textoObs('Menor variabilidade de resposta'),
        _textoObs('Efeito IRREVERSÍVEL - suspender 7 dias antes CRM'),
        _textoObs('NÃO indicado em IAMSSST conservador'),
        _textoObs('Preferido em diabéticos com SCA'),
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
