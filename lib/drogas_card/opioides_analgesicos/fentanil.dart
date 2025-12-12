import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFentanil {
  static const String nome = 'Fentanil';
  static const String idBulario = 'fentanil';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/fentanil.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Fentanil tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardFentanil(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardFentanil(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFentanil._textoObs(
            'Opioide sintético - Agonista μ-opioide de ação rápida'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFentanil._linhaPreparo('Ampola 50mcg/mL (2mL = 100mcg)', ''),
        MedicamentoFentanil._linhaPreparo('Ampola 50mcg/mL (5mL = 250mcg)', ''),
        MedicamentoFentanil._linhaPreparo(
            'Ampola 50mcg/mL (10mL = 500mcg)', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFentanil._linhaPreparo(
            'Bolus IV', 'Administrar em bolus lento (≥60 segundos)'),
        MedicamentoFentanil._linhaPreparo('Infusão contínua',
            'Diluir em SF 0,9% (concentração 10-50 mcg/mL)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoFentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: '1-5 mcg/kg IV em bolus lento',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
          MedicamentoFentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Analgesia procedimentos (intubação, punção)',
            descricaoDose: '1-2 mcg/kg IV em bolus lento',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
          ),
          MedicamentoFentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Suplemento analgésico intraoperatório',
            descricaoDose: '1-3 mcg/kg IV em bolus',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 3,
            peso: peso,
          ),
        ] else ...[
          MedicamentoFentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Analgesia procedimentos pediátricos',
            descricaoDose: '1-3 mcg/kg IV em bolus lento',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 3,
            peso: peso,
          ),
          MedicamentoFentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica pediátrica',
            descricaoDose: '1-3 mcg/kg IV em bolus lento',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 3,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFentanil._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFentanil._textoObs('Início de ação: 1-2 minutos'),
        MedicamentoFentanil._textoObs('Pico de efeito: 3-5 minutos'),
        MedicamentoFentanil._textoObs('Duração: 30-60 minutos (bolus único)'),
        MedicamentoFentanil._textoObs(
            'Meia-vida: 3,5-6 horas (contexto-dependente)'),
        MedicamentoFentanil._textoObs(
            'Potência: 80-100x mais potente que morfina'),
        MedicamentoFentanil._textoObs(
            'Agonista seletivo de receptores μ-opioides'),
        MedicamentoFentanil._textoObs(
            'Alta lipossolubilidade (rápida penetração no SNC)'),
        MedicamentoFentanil._textoObs(
            'Menor liberação de histamina que morfina'),
        MedicamentoFentanil._textoObs('Menor risco de hipotensão que morfina'),
        MedicamentoFentanil._textoObs('Ideal para analgesia de procedimentos'),
        MedicamentoFentanil._textoObs(
            'SEMPRE administrar bolus lento (≥60 segundos)'),
        MedicamentoFentanil._textoObs(
            'Risco de rigidez torácica (wooden chest)'),
        MedicamentoFentanil._textoObs(
            'Rigidez torácica mais comum em bolus rápidos >5 mcg/kg'),
        MedicamentoFentanil._textoObs(
            'Prevenir rigidez: administração lenta ou benzodiazepínico'),
        MedicamentoFentanil._textoObs(
            'Efeito acumulativo em infusões prolongadas'),
        MedicamentoFentanil._textoObs(
            'Despertar prolongado após infusão contínua'),
        MedicamentoFentanil._textoObs(
            'Monitorar FR, saturação, PA, FC continuamente'),
        MedicamentoFentanil._textoObs(
            'Ter naloxona e suporte ventilatório disponíveis'),
        MedicamentoFentanil._textoObs('Risco de depressão respiratória'),
        MedicamentoFentanil._textoObs(
            'Efeitos adversos: náusea, prurido, bradicardia'),
        MedicamentoFentanil._textoObs(
            'Potencializa sedação com benzodiazepínicos'),
        MedicamentoFentanil._textoObs(
            'Inibidores CYP3A4 aumentam risco de toxicidade'),
        MedicamentoFentanil._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoFentanil._textoObs('Incompatível com soluções alcalinas'),
        MedicamentoFentanil._textoObs('Ajustar dose em hepatopatia grave'),
        MedicamentoFentanil._textoObs('Categoria C na gravidez'),
        MedicamentoFentanil._textoObs(
            'Pode causar depressão respiratória neonatal'),
        MedicamentoFentanil._textoObs(
            'Contraindicado sem suporte ventilatório'),
        MedicamentoFentanil._textoObs(
            'Uso exclusivo em ambiente hospitalar monitorado'),
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
      'Solução pura (50 mcg/mL)': 50.0, // mcg/mL
      '100mcg em 100mL SF 0,9% (1 mcg/mL)': 1.0, // mcg/mL
      '500mcg em 100mL SF 0,9% (5 mcg/mL)': 5.0, // mcg/mL
      '500mcg em 50mL SF 0,9% (10 mcg/mL)': 10.0, // mcg/mL
      '1000mcg em 100mL SF 0,9% (10 mcg/mL)': 10.0, // mcg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/h',
        doseMin: 0.5,
        doseMax: 5.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/h',
        doseMin: 0.5,
        doseMax: 2.0,
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
  }) {
    double? doseCalculada;
    String? textoDose;

    // Se a unidade contém "/kg", não multiplicamos pelo peso (a dose já é por kg)
    bool isDosePorKg = unidade?.contains('/kg') ?? false;

    if (dosePorKg != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/h, mostramos apenas o valor
        textoDose = '${dosePorKg.toStringAsFixed(1)} $unidade';
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
        // Para doses do tipo mcg/kg/h, mostramos apenas o intervalo
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
