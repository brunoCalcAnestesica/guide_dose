import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoOctreotida {
  static const String nome = 'Octreotida';
  static const String idBulario = 'octreotida';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/octreotida.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    // Verificar se há indicações para a faixa etária selecionada
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardOctreotida(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Octreotida tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardOctreotida(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Análogo de Somatostatina', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOctreotida._linhaPreparo('Ampola 0,05 mg/mL (1 mL)'),
        MedicamentoOctreotida._linhaPreparo('Ampola 0,1 mg/mL (1 mL)'),
        MedicamentoOctreotida._linhaPreparo('Ampola 0,5 mg/mL (1 mL)'),
        MedicamentoOctreotida._linhaPreparo('Pó para suspensão 10 mg'),
        MedicamentoOctreotida._linhaPreparo('Pó para suspensão 20 mg'),
        MedicamentoOctreotida._linhaPreparo('Pó para suspensão 30 mg'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOctreotida._linhaPreparo(
            '• Infusão contínua: diluir 500 mcg em 60 mL de SF 0,9%'),
        MedicamentoOctreotida._linhaPreparo(
            '• Injetável: reconstituir conforme instruções do fabricante'),
        const SizedBox(height: 16),
        const Text('Indicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOctreotida._buildConversorInfusao(peso, faixaEtaria),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOctreotida._textoObs('• Monitorar glicemia regularmente'),
        MedicamentoOctreotida._textoObs('• Avaliar função hepática e renal'),
        MedicamentoOctreotida._textoObs(
            '• Cuidado em pacientes com cálculos biliares'),
        MedicamentoOctreotida._textoObs(
            '• Ajustar dose em insuficiência hepática/renal'),
        MedicamentoOctreotida._textoObs(
            '• Dose inicial baixa com aumento gradual'),
        MedicamentoOctreotida._textoObs(
            '• Interromper se icterícia ou dor abdominal intensa'),
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
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Diarreia Secretora Grave',
            descricaoDose: 'Dose: 1-2 mcg/kg',
            unidade: 'mcg',
            dosePorKg: 1.5,
            peso: peso,
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Hiperinsulinismo Congênito',
            descricaoDose: 'Dose: 2-10 mcg/kg',
            unidade: 'mcg',
            dosePorKg: 5.0,
            peso: peso,
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Hipoglicemia por Sulfonilureias',
            descricaoDose: 'Dose: 1-5 mcg/kg',
            unidade: 'mcg',
            dosePorKg: 3.0,
            peso: peso,
          ),
        ]);
        break;
      case 'Adolescente':
        indicacoes.addAll([
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Acromegalia',
            descricaoDose: 'Dose: 50-100 mcg',
            unidade: 'mcg',
            doseFixa: '50-100',
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Tumores Neuroendócrinos',
            descricaoDose: 'Dose: 50-200 mcg',
            unidade: 'mcg',
            doseFixa: '50-200',
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Diarreia Refratária',
            descricaoDose: 'Dose: 50-100 mcg',
            unidade: 'mcg',
            doseFixa: '50-100',
          ),
        ]);
        break;
      case 'Adulto':
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Acromegalia',
            descricaoDose: 'Dose: 50-100 mcg',
            unidade: 'mcg',
            doseFixa: '50-100',
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Tumores Neuroendócrinos (GEP-NETs)',
            descricaoDose: 'Dose: 50-200 mcg',
            unidade: 'mcg',
            doseFixa: '50-200',
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Diarreia Refratária (AIDS)',
            descricaoDose: 'Dose: 50-100 mcg',
            unidade: 'mcg',
            doseFixa: '50-100',
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Complicações Pós-Cirurgia Pancreática',
            descricaoDose: 'Dose: 50-100 mcg',
            unidade: 'mcg',
            doseFixa: '50-100',
          ),
          MedicamentoOctreotida._linhaIndicacaoDoseCalculada(
            titulo: 'Hemorragia por Varizes Gastroesofágicas',
            descricaoDose: 'Dose: 25-50 mcg/h',
            unidade: 'mcg/h',
            doseFixa: '25-50',
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

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    String? doseFixa,
    double? peso,
  }) {
    String? textoDose;

    if (dosePorKg != null && peso != null) {
      final doseCalculada = dosePorKg * peso;
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (doseFixa != null) {
      textoDose = '$doseFixa $unidade';
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
                'Dose: $textoDose',
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

  static Widget _buildConversorInfusao(double peso, String faixaEtaria) {
    final opcoesConcentracoes = {
      '500 mcg em 500mL SF 0,9% (1 mcg/mL)': 1.0,
      '1000 mcg em 500mL SF 0,9% (2 mcg/mL)': 2.0,
      '2000 mcg em 500mL SF 0,9% (4 mcg/mL)': 4.0,
    };

    double doseMin;
    double doseMax;

    switch (faixaEtaria) {
      case 'Neonato':
      case 'Lactente':
      case 'Criança':
        doseMin = 0.5;
        doseMax = 2.0;
        break;
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        doseMin = 1.0;
        doseMax = 4.0;
        break;
      default:
        doseMin = 1.0;
        doseMax = 4.0;
    }

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/h',
      doseMin: doseMin,
      doseMax: doseMax,
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }
}
