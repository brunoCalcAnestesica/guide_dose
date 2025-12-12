import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMidazolam {
  static const String nome = 'Midazolam';
  static const String idBulario = 'midazolam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/midazolam.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Midazolam tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMidazolam(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardMidazolam(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMidazolam._textoObs(
            'Benzodiazepínico - Sedativo - Ansiolítico - Anticonvulsivante'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMidazolam._linhaPreparo('Ampola 5mg/mL', '2mL, 3mL ou 5mL'),
        MedicamentoMidazolam._linhaPreparo('Ampola 1mg/mL (diluída)', '5mL'),
        MedicamentoMidazolam._linhaPreparo('Solução oral 2mg/mL', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMidazolam._linhaPreparo(
            'Bolus IV', 'Usar ampola 5mg/mL direto ou diluir para 1mg/mL'),
        MedicamentoMidazolam._linhaPreparo(
            'Velocidade', 'Administrar LENTO (>2 minutos)'),
        MedicamentoMidazolam._linhaPreparo('Infusão',
            'Diluir 50mg em 50mL SF 0,9% (1mg/mL) ou 100mg em 100mL'),
        MedicamentoMidazolam._linhaPreparo(
            'Via IM', 'Usar solução 5mg/mL direto'),
        MedicamentoMidazolam._linhaPreparo(
            'Via IN/Bucal', 'Usar solução 5mg/mL'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoMidazolam._linhaIndicacaoDoseFixa(
            titulo: 'Sedação consciente para procedimentos',
            descricaoDose:
                '0,5-2,5mg IV lento, repetir se necessário (máx 5mg)',
            doseFixa: '0,5-2,5 mg',
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: '0,1-0,3 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.3,
            peso: peso,
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseFixa(
            titulo: 'Status epilepticus (IV/IM)',
            descricaoDose: '5-10mg IV lento ou IM',
            doseFixa: '5-10 mg',
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseFixa(
            titulo: 'Status epilepticus (IN/bucal)',
            descricaoDose: '10mg IN ou bucal',
            doseFixa: '10 mg',
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseFixa(
            titulo: 'Pré-medicação anestésica (IM)',
            descricaoDose: '0,07-0,1 mg/kg IM (usual 5mg)',
            doseFixa: '5 mg',
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação em UTI (infusão contínua)',
            descricaoDose: '0,02-0,1 mg/kg/h IV (titular até 0,15 mg/kg/h)',
            unidade: 'mg/kg/h',
            dosePorKgMinima: 0.02,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
        ] else ...[
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação consciente pediátrica',
            descricaoDose: '0,05-0,1 mg/kg IV (máx 2,5mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.1,
            peso: peso,
            doseMaxima: 2.5,
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Via IM pediátrica',
            descricaoDose: '0,1-0,15 mg/kg IM',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.15,
            peso: peso,
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Via oral pediátrica',
            descricaoDose: '0,25-0,5 mg/kg VO (máx 20mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 0.5,
            peso: peso,
            doseMaxima: 20,
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Convulsões (IV)',
            descricaoDose: '0,2 mg/kg IV lento (máx 10mg)',
            unidade: 'mg',
            dosePorKg: 0.2,
            peso: peso,
            doseMaxima: 10,
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Convulsões (IN/bucal)',
            descricaoDose: '0,2-0,3 mg/kg IN ou bucal (máx 10mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.2,
            dosePorKgMaxima: 0.3,
            peso: peso,
            doseMaxima: 10,
          ),
          MedicamentoMidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação em UTI pediátrica (infusão contínua)',
            descricaoDose: '0,06-0,12 mg/kg/h IV (titular até 0,15 mg/kg/h)',
            unidade: 'mg/kg/h',
            dosePorKgMinima: 0.06,
            dosePorKgMaxima: 0.12,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMidazolam._buildInfoInfusao(peso, isAdulto),
      ],
    );
  }

  static Widget _buildInfoInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      'Solução pura (5 mg/mL)': 5.0, // mg/mL - pura
      '50mg em 50mL SF 0,9% (1 mg/mL)': 1.0, // mg/mL - padrão
      '100mg em 100mL SF 0,9% (1 mg/mL)': 1.0, // mg/mL - padrão
      '50mg em 100mL SF 0,9% (0,5 mg/mL)': 0.5, // mg/mL - diluído
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.02,
        doseMax: 0.15,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.06,
        doseMax: 0.15,
      );
    }
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
                    const TextSpan(
                        text: ' | ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: marca,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
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
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
