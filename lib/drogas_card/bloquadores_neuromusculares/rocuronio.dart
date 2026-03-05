import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRocuronio {
  static const String nome = 'Rocurônio';
  static const String idBulario = 'rocuronio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/rocuronio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardRocuronio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardRocuronio(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardRocuronio(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo(
            'BNM não despolarizante', 'Aminoesteroide, ação intermediária'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 50mg/5mL', '10 mg/mL'),
        _linhaPreparo('Ampola 100mg/10mL', '10 mg/mL'),

        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Bolus: puro da ampola', '10 mg/mL (10.000 mcg/mL)'),
        _linhaPreparo('200mg + 100mL SF', '2000 mcg/mL'),
        _linhaPreparo('100mg + 100mL SF', '1000 mcg/mL'),
        _linhaPreparo('50mg + 100mL SF', '500 mcg/mL'),

        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - caixa azul calculada
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação sequência rápida (RSI)',
            descricaoDose: '0,9-1,2 mg/kg IV bolus (onset 60 seg)',
            dosePorKgMinima: 0.9,
            dosePorKgMaxima: 1.2,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação eletiva',
            descricaoDose: '0,6 mg/kg IV bolus (onset 1-2 min)',
            dosePorKg: 0.6,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (bolus)',
            descricaoDose: '0,1-0,2 mg/kg IV quando T1 25% (duração 12-24 min)',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.2,
            unidade: 'mg',
            peso: peso,
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Infusão contínua',
            descricaoDose: '4-16 mcg/kg/min IV (inicial: 10-12 mcg/kg/min)',
          ),
        ] else ...[
          // PEDIÁTRICO
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação (≥3 meses)',
            descricaoDose: '0,6 mg/kg IV bolus (onset 30-60 seg)',
            dosePorKg: 0.6,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação neonatos/lactentes',
            descricaoDose: '0,5 mg/kg IV bolus (maior sensibilidade)',
            dosePorKg: 0.5,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (bolus)',
            descricaoDose: '0,075-0,125 mg/kg IV SN',
            dosePorKgMinima: 0.075,
            dosePorKgMaxima: 0.125,
            unidade: 'mg',
            peso: peso,
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Infusão pediátrica',
            descricaoDose: '7-12 mcg/kg/min IV contínua',
          ),
        ],

        // 5. INFUSÃO CONTÍNUA
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildConversorInfusao(peso, isAdulto),

        // 6. OBSERVAÇÕES (6 mais importantes)
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 60-90 seg | Duração: 30-40 min'),
        _textoObs('NÃO libera histamina - estabilidade cardiovascular'),
        _textoObs('Monitorização TOF obrigatória (meta: 1-2 respostas)'),
        _textoObs(
            'Reversão: sugamadex 2-4 mg/kg (imediata) ou 16 mg/kg (emergência)'),
        _textoObs('Potencializado por: voláteis, aminoglicosídeos, Mg'),
        _textoObs('Eliminação hepática - cautela em hepatopatia'),
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
    // Concentrações em mcg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '200mg + 100mL SF (2000 mcg/mL)': 2000.0,
      '100mg + 100mL SF (1000 mcg/mL)': 1000.0,
      '50mg + 100mL SF (500 mcg/mL)': 500.0,
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: 4.0,
      doseMax: isAdulto ? 16.0 : 12.0,
      concentracaoEmMcg: true,
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
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
      textoDose =
          '${doseMin.toStringAsFixed(1)}-${doseMax.toStringAsFixed(1)} $unidade';
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
                  color: doseLimite
                      ? Colors.orange.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Text(
                doseLimite
                    ? 'Dose: $textoDose (máx atingida)'
                    : 'Dose: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: doseLimite
                      ? Colors.orange.shade700
                      : Colors.blue.shade700,
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
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
