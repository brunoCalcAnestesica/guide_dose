import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRemidazolam {
  static const String nome = 'Remidazolam';
  static const String idBulario = 'remidazolam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/remidazolam.json');
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
      conteudo: _buildCardRemidazolam(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardRemidazolam(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemidazolam._textoObs('Benzodiazepínico de ação ultra-curta - Sedativo-hipnótico GABA-A'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemidazolam._linhaPreparo('Frasco-ampola 20mg/2,5mL (8mg/mL)', 'Solução pronta'),
        MedicamentoRemidazolam._linhaPreparo('Pó liofilizado 20mg', 'Reconstituir em 2,5mL'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemidazolam._linhaPreparo('Solução pronta: usar direto (8mg/mL)', 'Não diluir para bolus'),
        MedicamentoRemidazolam._linhaPreparo('Pó: reconstituir 20mg em 2,5mL diluente', '8 mg/mL'),
        MedicamentoRemidazolam._linhaPreparo('Infusão: 100mg em 100mL SF 0,9%', '1 mg/mL'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoRemidazolam._linhaIndicacaoDoseFixa(
            titulo: 'Sedação consciente procedimentos (ASA I-III)',
            descricaoDose: 'Bolus inicial 5mg IV em 1min. Aguardar 2min. Incrementos 2,5mg se necessário (máx 3x)',
            doseFixa: '5-12,5 mg total',
          ),
          MedicamentoRemidazolam._linhaIndicacaoDoseFixa(
            titulo: 'Sedação consciente (Idosos/ASA III-IV)',
            descricaoDose: 'Bolus inicial 2,5-3,5mg IV. Incrementos 1,25-2,5mg',
            doseFixa: '2,5-8 mg total',
          ),
          MedicamentoRemidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: '0,2-0,3 mg/kg IV em 1min',
            unidade: 'mg',
            dosePorKgMinima: 0.2,
            dosePorKgMaxima: 0.3,
            peso: peso,
          ),
          MedicamentoRemidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica (Idosos)',
            descricaoDose: '0,15-0,2 mg/kg IV (redução 25-30%)',
            unidade: 'mg',
            dosePorKgMinima: 0.15,
            dosePorKgMaxima: 0.2,
            peso: peso,
          ),
        ] else ...[
          MedicamentoRemidazolam._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação pediátrica (investigacional)',
            descricaoDose: '0,1-0,2 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.2,
            peso: peso,
          ),
          const SizedBox(height: 8),
          MedicamentoRemidazolam._textoObs('ATENÇÃO: Uso pediátrico ainda investigacional - dados limitados'),
          MedicamentoRemidazolam._textoObs('Preferir midazolam em pediatria (mais estudos, aprovação estabelecida)'),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemidazolam._textoObs('Indicações: Manutenção sedação procedimentos, manutenção anestesia geral, sedação UTI (investigacional)'),
        const SizedBox(height: 8),
        MedicamentoRemidazolam._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 8),
        MedicamentoRemidazolam._textoObs('• Manutenção sedação consciente: 0,5-1 mg/kg/h (30-70 mg/h adulto 70kg)'),
        MedicamentoRemidazolam._textoObs('• Manutenção anestésica: 1-3 mg/kg/h (70-210 mg/h adulto 70kg)'),
        MedicamentoRemidazolam._textoObs('• Titular conforme BIS/RASS - meta: BIS 40-60 (anestesia), RASS -3/-4 (sedação)'),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRemidazolam._textoObs('Benzodiazepínico ultra-curto - recuperação 5-10 min (vs 2-4h midazolam)'),
        MedicamentoRemidazolam._textoObs('Metabolismo por esterases teciduais (NÃO CYP450) - sem acúmulo'),
        MedicamentoRemidazolam._textoObs('NÃO requer ajuste dose renal ou hepática (vantagem vs midazolam)'),
        MedicamentoRemidazolam._textoObs('ATENÇÃO: Administrar bolus em 1 min (não mais rápido)'),
        MedicamentoRemidazolam._textoObs('Onset: 1-3 min. Duração: 5-15 min. Alta: 30-60 min'),
        MedicamentoRemidazolam._textoObs('Reversível por flumazenil 0,2-1 mg IV (antagonista específico)'),
        MedicamentoRemidazolam._textoObs('Monitorar SpO2, PA, FC continuamente - ter O2 e flumazenil disponíveis'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '100mg em 100mL SF 0,9% (1 mg/mL)': 1.0,
      '200mg em 200mL SF 0,9% (1 mg/mL)': 1.0,
      '100mg em 50mL SF 0,9% (2 mg/mL)': 2.0,
      '50mg em 50mL SF 0,9% (1 mg/mL)': 1.0,
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 3.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.3,
        doseMax: 2.0,
      );
    }
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
