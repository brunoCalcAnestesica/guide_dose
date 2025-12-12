import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoEsmolol {
  static const String nome = 'Esmolol';
  static const String idBulario = 'esmolol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/esmolol.json');
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
      conteudo: _buildCardEsmolol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardEsmolol(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEsmolol._textoObs(
            'Beta-bloqueador cardioseletivo de ação ultra-curta'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEsmolol._linhaPreparo(
            'Ampola 100mg/10mL (10mg/mL)', 'Brevibloc®, Esmolol®'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEsmolol._linhaPreparo(
            '100mg em 100mL SG 5%', '1mg/mL (1000 mcg/mL) - padrão'),
        MedicamentoEsmolol._linhaPreparo(
            '200mg em 100mL SG 5%', '2mg/mL (2000 mcg/mL) - alternativo'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoEsmolol._linhaIndicacaoDoseCalculada(
            titulo: 'Taquicardia supraventricular (bolus)',
            descricaoDose: '500 mcg/kg IV em 1 minuto',
            unidade: 'mg',
            dosePorKg: 0.5,
            peso: peso,
          ),
          MedicamentoEsmolol._linhaIndicacaoDoseCalculada(
            titulo: 'Fibrilação atrial com resposta ventricular rápida (bolus)',
            descricaoDose: '500 mcg/kg IV em 1 minuto',
            unidade: 'mg',
            dosePorKg: 0.5,
            peso: peso,
          ),
          MedicamentoEsmolol._linhaIndicacaoDoseCalculada(
            titulo: 'Crise hipertensiva com taquicardia',
            descricaoDose: '80 mcg/kg/min IV contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 80,
            dosePorKgMaxima: 80,
            peso: peso,
          ),
          MedicamentoEsmolol._linhaIndicacaoDoseCalculada(
            titulo: 'Taquicardia perioperatória',
            descricaoDose: '50-200 mcg/kg/min IV contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 50,
            dosePorKgMaxima: 200,
            peso: peso,
          ),
        ] else ...[
          MedicamentoEsmolol._linhaIndicacaoDoseCalculada(
            titulo: 'Taquicardia supraventricular pediátrica (bolus)',
            descricaoDose: '500 mcg/kg IV em 1 minuto',
            unidade: 'mg',
            dosePorKg: 0.5,
            peso: peso,
          ),
          MedicamentoEsmolol._linhaIndicacaoDoseCalculada(
            titulo: 'Controle de frequência cardíaca pediátrica',
            descricaoDose: '50-200 mcg/kg/min IV contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 50,
            dosePorKgMaxima: 200,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEsmolol._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEsmolol._textoObs('Início de ação: 1-2 minutos'),
        MedicamentoEsmolol._textoObs('Pico de efeito: 5-10 minutos'),
        MedicamentoEsmolol._textoObs('Meia-vida: 9 minutos (ação ultra-curta)'),
        MedicamentoEsmolol._textoObs(
            'Metabolização rápida por esterases plasmáticas'),
        MedicamentoEsmolol._textoObs('Dose máxima: 200 mcg/kg/min'),
        MedicamentoEsmolol._textoObs(
            'Usar exclusivamente com bomba de infusão'),
        MedicamentoEsmolol._textoObs('Monitorar ECG, PA e FC continuamente'),
        MedicamentoEsmolol._textoObs('Contraindicado em IC descompensada'),
        MedicamentoEsmolol._textoObs('Contraindicado em choque cardiogênico'),
        MedicamentoEsmolol._textoObs('Contraindicado em BAV 2º ou 3º grau'),
        MedicamentoEsmolol._textoObs(
            'Não requer ajuste em disfunção renal ou hepática'),
        MedicamentoEsmolol._textoObs('Risco de bradicardia e hipotensão'),
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
      '100mg em 100mL SG 5% (1000 mcg/mL)': 1000.0, // mcg/mL
      '200mg em 100mL SG 5% (2000 mcg/mL)': 2000.0, // mcg/mL
    };

    // Ambos adultos e pediátricos usam a mesma faixa: 50-200 mcg/kg/min
    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: 50.0,
      doseMax: 200.0,
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
        textoDose = '${dosePorKg.toStringAsFixed(0)} $unidade';
      } else {
        // Para doses totais (mg, mcg), calculamos multiplicando pelo peso
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
            '${dosePorKgMinima.toStringAsFixed(0)}–${dosePorKgMaxima.toStringAsFixed(0)} $unidade';
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
