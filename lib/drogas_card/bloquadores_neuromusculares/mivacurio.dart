import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMivacurio {
  static const String nome = 'Mivacúrio';
  static const String idBulario = 'mivacurio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/mivacurio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Mivacúrio tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMivacurio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardMivacurio(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMivacurio._textoObs(
            'Bloqueador neuromuscular não despolarizante - Ação curta'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMivacurio._linhaPreparo('Ampola 2mg/mL (5mL = 10mg)', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMivacurio._linhaPreparo(
            'Bolus', 'Pronto para uso (2 mg/mL)'),
        MedicamentoMivacurio._linhaPreparo('Infusão contínua',
            '20mg em 50mL SF 0,9% = 0,4 mg/mL (400 mcg/mL)'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoMivacurio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação orotraqueal',
            descricaoDose: '0,15-0,25 mg/kg IV bolus lento (20-30 seg)',
            unidade: 'mg',
            dosePorKgMinima: 0.15,
            dosePorKgMaxima: 0.25,
            peso: peso,
          ),
          MedicamentoMivacurio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção do bloqueio (bolus)',
            descricaoDose: '0,1 mg/kg IV conforme necessário',
            unidade: 'mg',
            dosePorKg: 0.1,
            peso: peso,
          ),
          MedicamentoMivacurio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção do bloqueio (infusão)',
            descricaoDose: '3-10 mcg/kg/min IV contínuo',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 3,
            dosePorKgMaxima: 10,
            peso: peso,
          ),
        ] else ...[
          MedicamentoMivacurio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação neonatal (<2 meses)',
            descricaoDose: '0,15 mg/kg IV bolus lento',
            unidade: 'mg',
            dosePorKg: 0.15,
            peso: peso,
          ),
          MedicamentoMivacurio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica (2 meses a 12 anos)',
            descricaoDose: '0,2 mg/kg IV bolus lento',
            unidade: 'mg',
            dosePorKg: 0.2,
            peso: peso,
          ),
          MedicamentoMivacurio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção pediátrica (infusão)',
            descricaoDose: '5-8 mcg/kg/min IV contínuo',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 8,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMivacurio._buildConversorInfusao(peso, isAdulto),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '20mg em 50mL SF 0,9% (400 mcg/mL)': 400.0, // mcg/mL - padrão
      '20mg em 100mL SF 0,9% (200 mcg/mL)': 200.0, // mcg/mL - diluído
      '10mg em 50mL SF 0,9% (200 mcg/mL)': 200.0, // mcg/mL - alternativo
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 3.0,
        doseMax: 10.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 5.0,
        doseMax: 8.0,
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

    // Se a unidade contém "/kg", não multiplicamos pelo peso (a dose já é por kg)
    bool isDosePorKg = unidade?.contains('/kg') ?? false;

    if (dosePorKg != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/min, mostramos apenas o valor
        textoDose = '${dosePorKg.toStringAsFixed(1)} $unidade';
      } else {
        // Para doses totais (mg), calculamos multiplicando pelo peso
        doseCalculada = dosePorKg * peso;
        if (doseMaxima != null && doseCalculada > doseMaxima) {
          doseCalculada = doseMaxima;
        }
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/min, mostramos apenas o intervalo
        textoDose =
            '${dosePorKgMinima.toStringAsFixed(1)}–${dosePorKgMaxima.toStringAsFixed(1)} $unidade';
      } else {
        // Para doses totais, calculamos multiplicando pelo peso
        double doseMin = dosePorKgMinima * peso;
        double doseMax = dosePorKgMaxima * peso;
        if (doseMaxima != null) {
          doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
        }
        textoDose =
            '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
      }
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
