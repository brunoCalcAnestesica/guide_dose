import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMorfina {
  static const String nome = 'Morfina';
  static const String idBulario = 'morfina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/morfina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Morfina tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMorfina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardMorfina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMorfina._textoObs('Analgésico opioide - Agonista μ-opioide'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMorfina._linhaPreparo('Solução injetável 10mg/mL', ''),
        MedicamentoMorfina._linhaPreparo('Solução injetável 20mg/mL', ''),
        MedicamentoMorfina._linhaPreparo('Solução injetável 50mg/mL', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMorfina._linhaPreparo(
            'Bolus IV', 'Diluir em 10mL SF 0,9% e administrar LENTO (≥2 min)'),
        MedicamentoMorfina._linhaPreparo(
            'Infusão contínua', 'Diluir em SF 0,9% ou SG 5%'),
        MedicamentoMorfina._linhaPreparo(
            'Via IM/SC', 'Pode usar solução sem diluição'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoMorfina._linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda intensa (IV)',
            descricaoDose: '2,5-5mg IV lento a cada 3-4h',
            doseFixa: '2,5-5 mg',
          ),
          MedicamentoMorfina._linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda intensa (IM/SC)',
            descricaoDose: '5-10mg IM ou SC a cada 4h',
            doseFixa: '5-10 mg',
          ),
          MedicamentoMorfina._linhaIndicacaoDoseFixa(
            titulo: 'Edema agudo de pulmão',
            descricaoDose: '2-5mg IV lento (efeito vasodilatador)',
            doseFixa: '2-5 mg',
          ),
          MedicamentoMorfina._linhaIndicacaoDoseFixa(
            titulo: 'PCA (analgesia controlada)',
            descricaoDose: '1mg IV/dose, bloqueio 6-10 min',
            doseFixa: '1 mg/dose',
          ),
          MedicamentoMorfina._linhaIndicacaoDoseCalculada(
            titulo: 'Infusão contínua (dor oncológica/cuidados paliativos)',
            descricaoDose:
                'Iniciar 0,007-0,014 mg/kg/h IV (~0,5-1 mg/h), titular conforme resposta',
            unidade: 'mg/kg/h',
            dosePorKgMinima: 0.007,
            dosePorKgMaxima: 0.014,
            peso: peso,
          ),
        ] else ...[
          MedicamentoMorfina._linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda pediátrica (IV)',
            descricaoDose: '0,05-0,1 mg/kg IV a cada 4h',
            unidade: 'mg',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
          MedicamentoMorfina._linhaIndicacaoDoseCalculada(
            titulo: 'Infusão contínua pediátrica',
            descricaoDose: '0,01-0,04 mg/kg/h IV, titular conforme resposta',
            unidade: 'mg/kg/h',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.04,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMorfina._buildConversorInfusao(peso, isAdulto),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '50mg em 50mL SF 0,9% (1 mg/mL)': 1.0, // mg/mL - padrão
      '100mg em 100mL SF 0,9% (1 mg/mL)': 1.0, // mg/mL - padrão
      '50mg em 100mL SF 0,9% (0,5 mg/mL)': 0.5, // mg/mL - diluído
      '100mg em 50mL SF 0,9% (2 mg/mL)': 2.0, // mg/mL - concentrado
    };

    if (isAdulto) {
      // Para adultos: 0,5-10 mg/h para 70kg = 0,007-0,14 mg/kg/h
      // Mas é mais intuitivo mostrar como mg/kg/h
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.007,
        doseMax: 0.14,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.01,
        doseMax: 0.1,
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

    // Se a unidade contém "/kg", não multiplicamos pelo peso (a dose já é por kg)
    bool isDosePorKg = unidade?.contains('/kg') ?? false;

    if (dosePorKg != null) {
      if (isDosePorKg) {
        // Para doses do tipo mg/kg/h, mostramos apenas o valor
        textoDose = '${dosePorKg.toStringAsFixed(2)} $unidade';
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
        // Para doses do tipo mg/kg/h, mostramos apenas o intervalo
        textoDose =
            '${dosePorKgMinima.toStringAsFixed(2)}–${dosePorKgMaxima.toStringAsFixed(2)} $unidade';
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
