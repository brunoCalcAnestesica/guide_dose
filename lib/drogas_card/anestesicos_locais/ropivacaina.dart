import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRopivacaina {
  static const String nome = 'Ropivacaína';
  static const String idBulario = 'ropivacaina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ropivacaina.json');
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
      conteudo: _buildCardRopivacaina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardRopivacaina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRopivacaina._textoObs('Anestésico local tipo amida de longa duração - Bloqueador canais sódio'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRopivacaina._linhaPreparo('Ampola 2mg/mL (10mL, 20mL, 100mL, 200mL)', 'Analgesia/baixa concentração'),
        MedicamentoRopivacaina._linhaPreparo('Ampola 7,5mg/mL (10mL, 20mL)', 'Anestesia cirúrgica'),
        MedicamentoRopivacaina._linhaPreparo('Ampola 10mg/mL (10mL, 20mL)', 'Anestesia cirúrgica densa'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRopivacaina._linhaPreparo('Usar solução pronta (não diluir)', 'Concentrações disponíveis 0,2-1%'),
        MedicamentoRopivacaina._linhaPreparo('Pode diluir 0,75-1% em SF 0,9%', 'Para obter 0,2-0,5% analgesia'),
        MedicamentoRopivacaina._linhaPreparo('Infusão peridural: bolsa 0,2% (100-200mL)', 'Bomba elastomérica/precisão'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoRopivacaina._linhaIndicacaoDoseFixa(
            titulo: 'Peridural cirúrgica',
            descricaoDose: '15-30 mL de 0,75-1% (113-300 mg)',
            doseFixa: '15-30 mL (113-300 mg)',
          ),
          MedicamentoRopivacaina._linhaIndicacaoDoseFixa(
            titulo: 'Cesariana (peridural)',
            descricaoDose: '15-20 mL de 0,75% (113-150 mg)',
            doseFixa: '15-20 mL (113-150 mg)',
          ),
          MedicamentoRopivacaina._linhaIndicacaoDoseFixa(
            titulo: 'Raquianestesia',
            descricaoDose: '2-4 mL de 0,5-0,75% (10-30 mg) ± opioide',
            doseFixa: '2-4 mL (10-30 mg)',
          ),
          MedicamentoRopivacaina._linhaIndicacaoDoseFixa(
            titulo: 'Bloqueio plexo braquial',
            descricaoDose: '30-40 mL de 0,5-0,75% (150-300 mg)',
            doseFixa: '30-40 mL (150-300 mg)',
          ),
          MedicamentoRopivacaina._linhaIndicacaoDoseFixa(
            titulo: 'Bloqueio femoral/ciático',
            descricaoDose: '20-30 mL de 0,5-0,75% (100-225 mg)',
            doseFixa: '20-30 mL (100-225 mg)',
          ),
          MedicamentoRopivacaina._linhaIndicacaoDoseCalculada(
            titulo: 'Infiltração local',
            descricaoDose: 'Dose máxima: 3 mg/kg (até 200 mg total)',
            unidade: 'mg',
            dosePorKg: 3.0,
            doseMaxima: 200,
            peso: peso,
          ),
        ] else ...[
          MedicamentoRopivacaina._linhaIndicacaoDoseCalculada(
            titulo: 'Bloqueio caudal pediátrico',
            descricaoDose: '1-2 mL/kg de 0,2% (2-4 mg/kg)',
            unidade: 'mL',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 2.0,
            peso: peso,
          ),
          MedicamentoRopivacaina._linhaIndicacaoDoseCalculada(
            titulo: 'Peridural pediátrica',
            descricaoDose: '0,5-1 mL/kg de 0,2% (1-2 mg/kg)',
            unidade: 'mL',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          MedicamentoRopivacaina._linhaIndicacaoDoseCalculada(
            titulo: 'Infiltração pediátrica',
            descricaoDose: 'Dose máxima: 3 mg/kg',
            unidade: 'mg',
            dosePorKg: 3.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua em Cateter de Bloqueio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRopivacaina._textoObs('Indicações: Analgesia peridural pós-op, bloqueios periféricos contínuos, analgesia obstétrica'),
        const SizedBox(height: 8),
        MedicamentoRopivacaina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 8),
        MedicamentoRopivacaina._textoObs('Slider ajusta volume (mL/h) - concentração fixa 0,2% (2 mg/mL)'),
        MedicamentoRopivacaina._textoObs('Adulto: 6-14 mL/h (equivale 12-28 mg/h)'),
        MedicamentoRopivacaina._textoObs('Pediátrico: 0,2-0,4 mL/kg/h (Ex: 20kg → 4-8 mL/h)'),
        MedicamentoRopivacaina._textoObs('Dose máxima total: 800 mg/24h (adultos), 400 mg/24h (pediátrico)'),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRopivacaina._textoObs('Anestésico local longa duração - isômero levógiro puro'),
        MedicamentoRopivacaina._textoObs('Menor cardiotoxicidade que bupivacaína (25-50% mais seguro)'),
        MedicamentoRopivacaina._textoObs('Bloqueio diferencial: baixas concentrações (0,2%) analgesia sem bloqueio motor'),
        MedicamentoRopivacaina._textoObs('Doses máximas: 3 mg/kg dose única (máx 300 mg), 800 mg/24h'),
        MedicamentoRopivacaina._textoObs('ATENÇÃO: Ter emulsão lipídica 20% disponível (antídoto toxicidade - 1,5 mL/kg IV)'),
        MedicamentoRopivacaina._textoObs('Sinais toxicidade: gosto metálico, tontura, zumbido, confusão, convulsões'),
        MedicamentoRopivacaina._textoObs('Injeção lenta fracionada obrigatória (5 mL a cada 3-5 min)'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Para ropivacaína: concentração fixa 0,2% (2 mg/mL)
    // Slider ajusta VOLUME (mL/h), não dose mg/h
    final opcoesConcentracoes = {
      'Ropivacaína 0,2% (2 mg/mL)': 2.0,
    };

    if (isAdulto) {
      // Adulto: 6-14 mL/h de 0,2% = 12-28 mg/h
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mL/h',
        doseMin: 6.0,
        doseMax: 14.0,
      );
    } else {
      // Pediátrico: 0,2-0,4 mL/kg/h
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mL/kg/h',
        doseMin: 0.2,
        doseMax: 0.4,
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
