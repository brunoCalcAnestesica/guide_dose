import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoWarfarina {
  static const String nome = 'Warfarina';
  static const String idBulario = 'warfarina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/warfarina.json');
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
      conteudo: _buildCardWarfarina(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardWarfarina(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardWarfarina(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anticoagulante oral', 'Antagonista da vitamina K'),
        _linhaPreparo('Derivado cumarínico', ''),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 1 mg', 'Rosa'),
        _linhaPreparo('Comprimido 2,5 mg', 'Verde'),
        _linhaPreparo('Comprimido 5 mg', 'Amarelo'),
        _linhaPreparo('Comprimido 7,5 mg', ''),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Dose inicial (adulto saudável)',
            descricaoDose: '5-10 mg VO 1x/dia nos primeiros 2 dias',
            doseFixa: '5-10 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dose inicial (idoso/baixo peso/hepatopata)',
            descricaoDose: '2,5-5 mg VO 1x/dia',
            doseFixa: '2,5-5 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'FA não valvar',
            descricaoDose: 'Alvo INR 2-3',
            doseFixa: 'INR 2,0 - 3,0',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'TVP/TEP',
            descricaoDose: 'Alvo INR 2-3 por ≥3 meses',
            doseFixa: 'INR 2,0 - 3,0',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Prótese valvar mecânica (mitral)',
            descricaoDose: 'Alvo INR 2,5-3,5',
            doseFixa: 'INR 2,5 - 3,5',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Prótese valvar mecânica (aórtica)',
            descricaoDose: 'Alvo INR 2-3',
            doseFixa: 'INR 2,0 - 3,0',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Dose inicial',
            descricaoDose: '0,1-0,2 mg/kg/dia VO (máx 10 mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.2,
            doseMaxima: 10,
            peso: peso,
          ),
        ],

        // MONITORAMENTO
        const SizedBox(height: 16),
        const Text('Monitoramento INR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: INR diário até estabilizar'),
        _textoObs('Depois: INR 2-3x/semana por 1-2 semanas'),
        _textoObs('Manutenção: INR mensal quando estável'),
        _textoObs('Ajustar dose 10-20% conforme INR'),

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('INÍCIO DE AÇÃO: 2-7 dias (efeito antitrombótico pleno)'),
        _textoObs('Fazer ponte com heparina até INR terapêutico por 24h'),
        _textoObs('REVERSÃO: Vitamina K + PFC ou CCP'),
        _textoObs('CONTRAINDICADO na gestação (teratogênico)'),
        _textoObs('MÚLTIPLAS INTERAÇÕES medicamentosas e alimentares'),
        _textoObs('Alimentos ricos em vit K reduzem efeito'),
        _textoObs('Polimorfismos genéticos afetam dose (CYP2C9, VKORC1)'),
        _textoObs('Tomar sempre no mesmo horário'),
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
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;
    bool doseLimite = false;

    if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseMin.toStringAsFixed(1)}-${doseMax.toStringAsFixed(1)} $unidade';
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
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                  fontSize: 13,
                ),
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
              'Alvo: $doseFixa',
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
