import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMeperidina {
  static const String nome = 'Meperidina';
  static const String idBulario = 'meperidina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/meperidina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMeperidina(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Meperidina tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardMeperidina(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Analgésico Opioide Sintético - Agonista μ-opioide',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMeperidina._linhaPreparo(
            '• Ampola 50 mg/mL (2 mL = 100 mg)'),
        MedicamentoMeperidina._linhaPreparo(
            '• Ampola 100 mg/mL (2 mL = 200 mg)'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMeperidina._linhaPreparo(
            '• IV: diluir em SF 0,9% para infusão'),
        MedicamentoMeperidina._linhaPreparo(
            '• Velocidade máxima: 25 mg/min (lento)'),
        MedicamentoMeperidina._linhaPreparo('• IM/SC: usar direto da ampola'),
        const SizedBox(height: 16),
        const Text('Indicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMeperidina._textoObs(
            '• Evitar uso prolongado (risco de acúmulo de normeperidina)'),
        MedicamentoMeperidina._textoObs(
            '• Contraindicado com IMAOs (intervalo mínimo 14 dias)'),
        MedicamentoMeperidina._textoObs('• Dose máxima: 600 mg/dia (adultos)'),
        MedicamentoMeperidina._textoObs('• Ter naloxona disponível'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(
      String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoMeperidina._linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda pediátrica (IM/SC)',
            descricaoDose: 'Dose: 1-1,5 mg/kg a cada 3-4h (máx 100 mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 1.5,
            peso: peso,
            doseMaxima: 100,
          ),
          MedicamentoMeperidina._linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda pediátrica (IV)',
            descricaoDose: 'Dose: 0,5-1 mg/kg IV lento (máx 50 mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
            doseMaxima: 50,
          ),
        ]);
        break;
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoMeperidina._linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda moderada a grave (IM/SC)',
            descricaoDose: 'Dose: 50-150 mg a cada 3-4h',
            doseFixa: '50-150 mg/dose',
          ),
          MedicamentoMeperidina._linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda (IV)',
            descricaoDose: 'Dose: 50-100 mg IV lento a cada 2-3h',
            doseFixa: '50-100 mg/dose',
          ),
          MedicamentoMeperidina._linhaIndicacaoDoseFixa(
            titulo: 'Analgesia pós-operatória',
            descricaoDose: 'Dose: 50-100 mg IM a cada 3-4h',
            doseFixa: '50-100 mg/dose',
          ),
          MedicamentoMeperidina._linhaIndicacaoDoseFixa(
            titulo: 'Tremores pós-anestésicos',
            descricaoDose: 'Dose: 12,5-25 mg IV lento',
            doseFixa: '12,5-25 mg/dose',
          ),
        ]);
        break;
    }

    return indicacoes;
  }

  static Widget _linhaPreparo(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
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
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            descricaoDose,
            style: const TextStyle(fontSize: 13),
          ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
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
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            descricaoDose,
            style: const TextStyle(fontSize: 13),
          ),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
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

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }
}
