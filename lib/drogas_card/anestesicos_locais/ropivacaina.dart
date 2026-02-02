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
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anestésico local amida', 'Longa duração, isômero S(-)'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola/Frasco 1% (10 mg/mL)', '10mL, 20mL'),
        _linhaPreparo('Ampola/Frasco 0,75% (7,5 mg/mL)', '10mL, 20mL'),
        _linhaPreparo('Ampola/Frasco 0,5% (5 mg/mL)', '10mL, 20mL'),
        _linhaPreparo('Bolsa 0,2% (2 mg/mL)', '100mL, 200mL (infusão)'),

        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('1% puro', '10 mg/mL (bloqueio motor)'),
        _linhaPreparo('0,75% puro', '7,5 mg/mL (cirúrgico)'),
        _linhaPreparo('0,5% puro', '5 mg/mL (bloqueios)'),
        _linhaPreparo('0,2% pronto', '2 mg/mL (infusão/analgesia)'),
        _textoObs('Não diluir - usar soluções prontas'),

        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - caixa azul calculada
          _linhaIndicacaoDoseCalculada(
            titulo: 'Peridural lombar cirúrgica',
            descricaoDose: '15-25 mL de 0,75% (113-188 mg)',
            volumeMin: 15,
            volumeMax: 25,
            unidade: 'mL',
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Bloqueio plexo braquial',
            descricaoDose: '30-40 mL de 0,5-0,75% (150-300 mg)',
            volumeMin: 30,
            volumeMax: 40,
            unidade: 'mL',
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Bloqueio femoral/ciático',
            descricaoDose: '15-30 mL de 0,5-0,75% (75-225 mg)',
            volumeMin: 15,
            volumeMax: 30,
            unidade: 'mL',
          ),
          _linhaIndicacaoDoseCalculadaPorPeso(
            titulo: 'Infiltração local',
            descricaoDose: 'Dose máxima: 3 mg/kg (máx 300 mg)',
            unidade: 'mg',
            dosePorKg: 3.0,
            doseMaxima: 300,
            peso: peso,
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Peridural analgesia (trabalho parto/pós-op)',
            descricaoDose: '6-14 mL/h de 0,2% (12-28 mg/h)',
          ),
        ] else ...[
          // PEDIÁTRICO
          _linhaIndicacaoDoseCalculadaPorPeso(
            titulo: 'Bloqueio caudal',
            descricaoDose: '0,5-1 mL/kg de 0,2% (1-2 mg/kg)',
            unidade: 'mL',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculadaPorPeso(
            titulo: 'Peridural pediátrica',
            descricaoDose: '0,5-0,75 mL/kg de 0,2%',
            unidade: 'mL',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 0.75,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculadaPorPeso(
            titulo: 'Infiltração pediátrica',
            descricaoDose: 'Dose máxima: 2,5 mg/kg',
            unidade: 'mg',
            dosePorKg: 2.5,
            peso: peso,
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Infusão peridural pediátrica',
            descricaoDose: '0,2-0,4 mg/kg/h de 0,2%',
          ),
        ],

        // 5. INFUSÃO CONTÍNUA
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildConversorInfusao(peso, isAdulto),

        // 6. OBSERVAÇÕES (6 mais importantes)
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 10-20 min | Duração: 4-8 horas'),
        _textoObs('Menor cardiotoxicidade que bupivacaína'),
        _textoObs('Bloqueio diferencial: 0,2% = analgesia sem bloqueio motor'),
        _textoObs('Dose máxima 24h: 800 mg (adulto), 400 mg (pediátrico)'),
        _textoObs('ATENÇÃO: Intralipid 20% disponível (1,5 mL/kg se toxicidade)'),
        _textoObs('Injeção fracionada obrigatória (aspirar + 5 mL cada 3-5 seg)'),
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
    // Concentração fixa 0,2% (2 mg/mL) para infusão
    final opcoesConcentracoes = {
      '0,2% (2 mg/mL)': 2.0,
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
      // Pediátrico: 0,2-0,4 mg/kg/h
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.2,
        doseMax: 0.4,
      );
    }
  }

  /// Para doses fixas (volume fixo, não por peso) - usada em bloqueios regionais
  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    required String unidade,
    required double volumeMin,
    required double volumeMax,
  }) {
    final textoDose = '${volumeMin.toStringAsFixed(0)}-${volumeMax.toStringAsFixed(0)} $unidade';

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
              'Volume: $textoDose',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Para doses calculadas por peso (mg/kg ou mL/kg)
  static Widget _linhaIndicacaoDoseCalculadaPorPeso({
    required String titulo,
    required String descricaoDose,
    required String unidade,
    required double peso,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
  }) {
    String? textoDose;
    bool doseLimite = false;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseMin.toStringAsFixed(1)}-${doseMax.toStringAsFixed(1)} $unidade';
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
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Text(
                doseLimite ? 'Dose: $textoDose (máx atingida)' : 'Dose: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoInfusao({
    required String titulo,
    required String descricaoDose,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
