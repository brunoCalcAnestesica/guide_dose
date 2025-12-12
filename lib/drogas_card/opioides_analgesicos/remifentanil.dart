import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRemifentanil {
  static const String nome = 'Remifentanil';
  static const String idBulario = 'remifentanil';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/remifentanil.json');
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
      conteudo: _buildCardRemifentanil(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardRemifentanil(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemifentanil._textoObs('Analgésico opioide sintético ultra-curto - Agonista μ-opioide'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemifentanil._linhaPreparo('Frasco-ampola 1mg (pó liofilizado)', 'Reconstituir antes uso'),
        MedicamentoRemifentanil._linhaPreparo('Frasco-ampola 2mg (pó liofilizado)', 'Reconstituir antes uso'),
        MedicamentoRemifentanil._linhaPreparo('Frasco-ampola 5mg (pó liofilizado)', 'Reconstituir antes uso'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemifentanil._linhaPreparo('Reconstituir 1mg em 1mL água estéril', '1 mg/mL (solução estoque)'),
        MedicamentoRemifentanil._linhaPreparo('Diluir 1mg em 50mL SF 0,9%', '20 mcg/mL (infusão padrão)'),
        MedicamentoRemifentanil._linhaPreparo('Diluir 2mg em 50mL SF 0,9%', '40 mcg/mL (concentração alta)'),
        MedicamentoRemifentanil._linhaPreparo('Diluir 5mg em 250mL SF 0,9%', '20 mcg/mL (volume grande)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoRemifentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica (bolus)',
            descricaoDose: '1 mcg/kg IV em 30-60 segundos (antes propofol/etomidato)',
            unidade: 'mcg',
            dosePorKg: 1.0,
            peso: peso,
          ),
          MedicamentoRemifentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação (bolus único)',
            descricaoDose: '2-4 mcg/kg IV em 30-60 seg (facilita IOT sem bloqueador)',
            unidade: 'mcg',
            dosePorKgMinima: 2.0,
            dosePorKgMaxima: 4.0,
            peso: peso,
          ),
          MedicamentoRemifentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação consciente procedimentos (bolus)',
            descricaoDose: '0,5-1 mcg/kg IV em 30-60 seg',
            unidade: 'mcg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
        ] else ...[
          MedicamentoRemifentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica pediátrica',
            descricaoDose: '0,5-1 mcg/kg IV em 30-60 seg',
            unidade: 'mcg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          MedicamentoRemifentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica',
            descricaoDose: '1-3 mcg/kg IV (doses menores que adultos)',
            unidade: 'mcg',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 3.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemifentanil._textoObs('Indicações: Manutenção analgesia intraoperatória, sedoanalgesia UTI, procedimentos prolongados'),
        const SizedBox(height: 8),
        MedicamentoRemifentanil._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 8),
        MedicamentoRemifentanil._textoObs('Manutenção anestésica padrão: 0,1-0,5 mcg/kg/min'),
        MedicamentoRemifentanil._textoObs('Cirurgia cardíaca/neurocirurgia: 0,5-2 mcg/kg/min'),
        MedicamentoRemifentanil._textoObs('Sedoanalgesia consciente: 0,025-0,1 mcg/kg/min'),
        MedicamentoRemifentanil._textoObs('Titular conforme resposta hemodinâmica e profundidade anestésica'),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemifentanil._textoObs('Opioide ultra-curto - meia-vida 3-10 min (vs 3-4h fentanil)'),
        MedicamentoRemifentanil._textoObs('Metabolismo por esterases plasmáticas/teciduais - sem acúmulo'),
        MedicamentoRemifentanil._textoObs('Recuperação rápida 5-10 min - ideal cirurgias ambulatoriais'),
        MedicamentoRemifentanil._textoObs('ATENÇÃO: Dor aguda pós-op comum - analgesia multimodal obrigatória'),
        MedicamentoRemifentanil._textoObs('NÃO requer ajuste dose renal ou hepática'),
        MedicamentoRemifentanil._textoObs('Depressão respiratória intensa - ventilar mecanicamente'),
        MedicamentoRemifentanil._textoObs('Bradicardia dose-dependente - ter atropina disponível'),
        MedicamentoRemifentanil._textoObs('Reversível por naloxona 0,04-0,4 mg IV (antagonista opioide)'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '1mg em 50mL SF 0,9% (20 mcg/mL)': 20.0,
      '2mg em 50mL SF 0,9% (40 mcg/mL)': 40.0,
      '5mg em 250mL SF 0,9% (20 mcg/mL)': 20.0,
      '2mg em 100mL SF 0,9% (20 mcg/mL)': 20.0,
      '5mg em 100mL SF 0,9% (50 mcg/mL)': 50.0,
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.025,
        doseMax: 2.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 1.5,
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
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
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
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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
