import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFenilefrina {
  static const String nome = 'Fenilefrina';
  static const String idBulario = 'fenilefrina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/fenilefrina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardFenilefrina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardFenilefrina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenilefrina._textoObs(
            'Agonista alfa-1 seletivo - Vasopressor'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenilefrina._linhaPreparo(
            'Ampola 10mg/mL (1mL)', 'Neosynefrina®, Fenefrin®'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenilefrina._linhaPreparo(
            '10mg em 100mL SF 0,9%', '100 mcg/mL (solução padrão para bolus)'),
        MedicamentoFenilefrina._linhaPreparo(
            '10mg em 250mL SF 0,9%', '40 mcg/mL (infusão)'),
        MedicamentoFenilefrina._linhaPreparo(
            '10mg em 500mL SF 0,9%', '20 mcg/mL (infusão)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoFenilefrina._linhaIndicacaoDoseCalculada(
            titulo:
                'Hipotensão associada à anestesia raquidiana/peridural (bolus)',
            descricaoDose: '50-200 mcg IV, repetir conforme necessário',
            unidade: 'mcg',
            dosePorKgMinima: 50,
            dosePorKgMaxima: 200,
            peso: peso,
            usaDoseFixa: true,
          ),
          MedicamentoFenilefrina._linhaIndicacaoDoseCalculada(
            titulo: 'Choque distributivo (bolus)',
            descricaoDose: '50-200 mcg IV',
            unidade: 'mcg',
            dosePorKgMinima: 50,
            dosePorKgMaxima: 200,
            peso: peso,
            usaDoseFixa: true,
          ),
        ] else ...[
          MedicamentoFenilefrina._linhaIndicacaoDoseCalculada(
            titulo: 'Hipotensão pediátrica (bolus)',
            descricaoDose: '1-5 mcg/kg IV',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenilefrina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenilefrina._textoObs(
            'Início de ação: imediato (menos de 1 minuto)'),
        MedicamentoFenilefrina._textoObs('Pico de efeito: 1-2 minutos'),
        MedicamentoFenilefrina._textoObs('Duração: 5-20 minutos'),
        MedicamentoFenilefrina._textoObs('Vasoconstrição seletiva alfa-1'),
        MedicamentoFenilefrina._textoObs('Pode causar bradicardia reflexa'),
        MedicamentoFenilefrina._textoObs(
            'Não possui efeito beta (sem taquicardia)'),
        MedicamentoFenilefrina._textoObs(
            'Ideal quando se deseja evitar taquicardia'),
        MedicamentoFenilefrina._textoObs('Reduz fluxo esplâncnico e renal'),
        MedicamentoFenilefrina._textoObs(
            'Monitorar PA invasiva preferencialmente'),
        MedicamentoFenilefrina._textoObs(
            'Risco de extravasamento (necrose tecidual)'),
        MedicamentoFenilefrina._textoObs(
            'Preferir acesso venoso central em infusões prolongadas'),
        MedicamentoFenilefrina._textoObs('Contraindicado em hipertensão grave'),
        MedicamentoFenilefrina._textoObs('Contraindicado em feocromocitoma'),
        MedicamentoFenilefrina._textoObs(
            'Cuidado com IMAOs (risco de crise hipertensiva)'),
        MedicamentoFenilefrina._textoObs('Não requer ajuste renal ou hepático'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '10mg em 100mL SF 0,9% (100 mcg/mL)': 100.0, // mcg/mL
      '10mg em 250mL SF 0,9% (40 mcg/mL)': 40.0, // mcg/mL
      '10mg em 500mL SF 0,9% (20 mcg/mL)': 20.0, // mcg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.1,
        doseMax: 1.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.1,
        doseMax: 0.5,
      );
    }
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
    bool usaDoseFixa = false,
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
        // Para doses totais (mg, mcg), calculamos multiplicando pelo peso
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
            '${dosePorKgMinima.toStringAsFixed(1)}–${dosePorKgMaxima.toStringAsFixed(1)} $unidade';
      } else if (usaDoseFixa) {
        // Para doses fixas (não dependem do peso), mostramos o intervalo fixo
        textoDose =
            '${dosePorKgMinima.toStringAsFixed(0)}–${dosePorKgMaxima.toStringAsFixed(0)} $unidade';
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
