import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMilrinona {
  static const String nome = 'Milrinona';
  static const String idBulario = 'milrinona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/milrinona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Milrinona tem indicações para todas as faixas etárias
    // Card sempre visível (adultos e pediatria)
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMilrinona(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardMilrinona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMilrinona._textoObs(
            'Inibidor da fosfodiesterase tipo 3 (PDE3) - Inodilatador'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMilrinona._linhaPreparo('Frasco 10mg/10mL (1 mg/mL)', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMilrinona._linhaPreparo(
            '10mg em 50mL SF 0,9%', '200 mcg/mL (padrão)'),
        MedicamentoMilrinona._linhaPreparo(
            '10mg em 100mL SF 0,9%', '100 mcg/mL (diluído)'),
        MedicamentoMilrinona._linhaPreparo(
            '20mg em 100mL SF 0,9%', '200 mcg/mL (alternativo)'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Dose de ataque',
            descricaoDose: '50 mcg/kg IV em 10 minutos',
            unidade: 'mcg',
            dosePorKg: 50,
            peso: peso,
          ),
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Insuficiência cardíaca aguda descompensada',
            descricaoDose: 'Dose de ataque seguida de infusão contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.375,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Choque cardiogênico',
            descricaoDose: 'Dose de ataque seguida de infusão contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.375,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Pós-operatório cirurgia cardíaca (síndrome baixo débito)',
            descricaoDose: 'Dose de ataque seguida de infusão contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.375,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Hipertensão pulmonar',
            descricaoDose: 'Dose de ataque seguida de infusão contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.375,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
        ] else ...[
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Dose de ataque pediátrica',
            descricaoDose: '50-75 mcg/kg IV em 10-60 minutos',
            unidade: 'mcg',
            dosePorKgMinima: 50,
            dosePorKgMaxima: 75,
            peso: peso,
          ),
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Insuficiência cardíaca pediátrica',
            descricaoDose: 'Dose de ataque seguida de infusão contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Pós-operatório cirurgia cardíaca pediátrica',
            descricaoDose: 'Dose de ataque seguida de infusão contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
          MedicamentoMilrinona._linhaIndicacaoDoseCalculada(
            titulo: 'Hipertensão pulmonar pediátrica',
            descricaoDose: 'Dose de ataque seguida de infusão contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMilrinona._buildConversorInfusao(peso, isAdulto),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '10mg em 50mL SF 0,9% (200 mcg/mL)': 200.0, // mcg/mL - padrão
      '10mg em 100mL SF 0,9% (100 mcg/mL)': 100.0, // mcg/mL - diluído
      '20mg em 100mL SF 0,9% (200 mcg/mL)': 200.0, // mcg/mL - alternativo
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.375,
        doseMax: 0.75,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.25,
        doseMax: 0.75,
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
        textoDose = '${dosePorKg.toStringAsFixed(3)} $unidade';
      } else {
        // Para doses totais (mcg), calculamos multiplicando pelo peso
        doseCalculada = dosePorKg * peso;
        if (doseMaxima != null && doseCalculada > doseMaxima) {
          doseCalculada = doseMaxima;
        }
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/min, mostramos apenas o intervalo
        textoDose =
            '${dosePorKgMinima.toStringAsFixed(3)}–${dosePorKgMaxima.toStringAsFixed(3)} $unidade';
      } else {
        // Para doses totais, calculamos multiplicando pelo peso
        double doseMin = dosePorKgMinima * peso;
        double doseMax = dosePorKgMaxima * peso;
        if (doseMaxima != null) {
          doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
        }
        textoDose =
            '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
