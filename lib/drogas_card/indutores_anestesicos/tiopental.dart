import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTiopental {
  static const String nome = 'Tiopental';
  static const String idBulario = 'tiopental';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/tiopental.json');
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
      conteudo: _buildCardTiopental(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardTiopental(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiopental._textoObs('• Anestésico geral IV - Barbitúrico ação ultracurta - Neuroprotetor'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiopental._linhaPreparo('Frasco-ampola 0,5g liofilizado', 'Pentotal® / Thiopentax®'),
        MedicamentoTiopental._linhaPreparo('Frasco-ampola 1g liofilizado', 'Pentotal® / Thiopentax®'),
        MedicamentoTiopental._linhaPreparo('Frasco-ampola 2,5g liofilizado', 'Trapanal®'),
        MedicamentoTiopental._linhaPreparo('Início: 20-40 segundos | Pico: 1 min', 'Ação ultracurta'),
        MedicamentoTiopental._linhaPreparo('Duração bolus: 5-10 min', 'Redistribuição rápida'),
        MedicamentoTiopental._linhaPreparo('Meia-vida eliminação: 6-46h', 'Prolongada infusão contínua'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiopental._linhaPreparo('Reconstituir 1g em 20mL água/SF/SG', 'Concentração 50mg/mL'),
        MedicamentoTiopental._linhaPreparo('Para infusão: diluir 10-25mg/mL', 'Em SF 0,9% ou SG 5%'),
        MedicamentoTiopental._linhaPreparo('Usar imediatamente ou 24h 2-8°C', 'Descartar se turva/precipitado'),
        MedicamentoTiopental._linhaPreparo('Incompatível: bicarbonato, soluções ácidas', 'Via exclusiva'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoTiopental._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: '3-5 mg/kg IV em bolus lento (30-60 seg)',
            unidade: 'mg',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 5.0,
            peso: peso,
          ),
          MedicamentoTiopental._linhaIndicacaoDoseCalculada(
            titulo: 'Indução idoso/instável',
            descricaoDose: '2-3 mg/kg IV em bolus lento',
            unidade: 'mg',
            dosePorKgMinima: 2.0,
            dosePorKgMaxima: 3.0,
            peso: peso,
          ),
          MedicamentoTiopental._linhaIndicacaoDoseCalculada(
            titulo: 'Status convulsivo (bolus inicial)',
            descricaoDose: '3-5 mg/kg IV, repetir conforme necessário',
            unidade: 'mg',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 5.0,
            peso: peso,
          ),
          MedicamentoTiopental._linhaIndicacaoDoseCalculada(
            titulo: 'Neuroproteção/Hipertensão intracraniana (bolus)',
            descricaoDose: '3-5 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 5.0,
            peso: peso,
          ),
        ] else ...[
          MedicamentoTiopental._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica pediátrica',
            descricaoDose: '2-7 mg/kg IV em bolus lento (30-60 seg)',
            unidade: 'mg',
            dosePorKgMinima: 2.0,
            dosePorKgMaxima: 7.0,
            peso: peso,
          ),
          MedicamentoTiopental._linhaIndicacaoDoseCalculada(
            titulo: 'Status convulsivo pediátrico (bolus)',
            descricaoDose: '3-5 mg/kg IV, repetir se necessário',
            unidade: 'mg',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 5.0,
            peso: peso,
          ),
          MedicamentoTiopental._linhaIndicacaoDoseCalculada(
            titulo: 'Neuroproteção pediátrica (bolus)',
            descricaoDose: '3-5 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 5.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiopental._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiopental._textoObs('• Barbitúrico - agonista GABA-A, hiperpolariza neurônio, inibe SNC'),
        MedicamentoTiopental._textoObs('• Neuroprotetor potente - reduz PIC, CMRO2, fluxo cerebral'),
        MedicamentoTiopental._textoObs('• Induz burst-suppression EEG (monitorar BIS/EEG)'),
        MedicamentoTiopental._textoObs('• NÃO tem efeito analgésico - pode causar hiperalgesia'),
        MedicamentoTiopental._textoObs('• ATENÇÃO: Depressor respiratório potente - apneia imediata após bolus'),
        MedicamentoTiopental._textoObs('• ATENÇÃO: Hipotensão severa - vasodilatação + depressão miocárdica'),
        MedicamentoTiopental._textoObs('• ATENÇÃO: Broncoespasmo em asmáticos - evitar'),
        MedicamentoTiopental._textoObs('• ATENÇÃO: Extravasamento causa necrose tecidual - acesso central preferível'),
        MedicamentoTiopental._textoObs('• Contraindicado: porfiria aguda (precipita crise), asma ativa, choque'),
        MedicamentoTiopental._textoObs('• Monitorar: PA, FC, ECG, SpO2, capnografia, BIS/EEG (burst-suppression)'),
        MedicamentoTiopental._textoObs('• Via aérea avançada e drogas vasoativas disponíveis'),
        MedicamentoTiopental._textoObs('• Ajustar dose em hepatopatas/insuficiência renal (acúmulo)'),
        MedicamentoTiopental._textoObs('• Infusão prolongada: risco imunossupressão, rabdomiólise, acidose'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Para status convulsivo, neuroproteção (burst-suppression) e sedação UTI',
          style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        ConversaoInfusaoSlider(
          peso: peso,
          opcoesConcentracoes: {
            '500mg em 50mL (10mg/mL)': 10.0,
            '1g em 50mL (20mg/mL)': 20.0,
            '1g em 40mL (25mg/mL)': 25.0,
          },
          doseMin: 0.5,
          doseMax: 5.0,
          unidade: 'mg/kg/h',
        ),
        const SizedBox(height: 8),
        const Text(
          'Status convulsivo: 0,5-5 mg/kg/h | Neuroproteção: 1-4 mg/kg/h | Sedação UTI: 0,5-3 mg/kg/h',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
        ),
      ],
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
