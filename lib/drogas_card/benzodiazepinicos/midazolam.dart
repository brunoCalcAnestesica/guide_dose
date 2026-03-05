import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMidazolam {
  static const String nome = 'Midazolam';
  static const String idBulario = 'midazolam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/midazolam.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMidazolam(
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
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return _buildCardMidazolam(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardMidazolam(BuildContext context, double peso,
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
            'Benzodiazepínico', 'Sedativo, ansiolítico, anticonvulsivante'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 5mg/mL', '3mL ou 10mL | Dormonid®'),
        _linhaPreparo('Ampola 1mg/mL', '5mL (diluída)'),
        _linhaPreparo('Solução oral', '2 mg/mL'),

        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Puro (sem diluir)', '5 mg/mL'),
        _linhaPreparo('50mg + 40mL SF', '1 mg/mL'),
        _linhaPreparo('15mg + 27mL SF', '0,5 mg/mL'),
        _textoObs('Bolus: administrar LENTO (>2 min)'),

        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - doses fixas (caixa verde) ou calculadas (caixa azul)
          _linhaIndicacaoDoseFixa(
            titulo: 'Sedação procedimentos',
            descricaoDose: '1-2,5 mg IV lento, repetir até máx 5 mg',
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: '0,15-0,3 mg/kg IV',
            dosePorKgMinima: 0.15,
            dosePorKgMaxima: 0.3,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Status epilepticus',
            descricaoDose: '5-10 mg IV/IM ou 10 mg IN/bucal',
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Sedação UTI',
            descricaoDose: '0,02-0,1 mg/kg/h IV contínua',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Sedação pediátrica',
            descricaoDose: '0,05-0,1 mg/kg IV (máx 2,5 mg)',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.1,
            doseMaxima: 2.5,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Convulsões',
            descricaoDose: '0,2 mg/kg IV/IN (máx 10 mg)',
            dosePorKg: 0.2,
            doseMaxima: 10,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Sedação UTI pediátrica',
            descricaoDose: '0,06-0,12 mg/kg/h IV contínua',
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
        _textoObs('Início IV: 1-3min | Duração: 30-60min'),
        _textoObs('DEPRESSÃO RESPIRATÓRIA - ter flumazenil disponível'),
        _textoObs('Potencializa opioides - reduzir doses'),
        _textoObs('Amnésia anterógrada - avisar paciente'),
        _textoObs('Idoso: reduzir dose 30-50%'),
        _textoObs('Metabolismo hepático - ajustar em hepatopatia'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em mg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      'Puro (5 mg/mL)': 5.0, // mg/mL
      '50mg + 40mL SF (1 mg/mL)': 1.0, // mg/mL
      '15mg + 27mL SF (0,5 mg/mL)': 0.5, // mg/mL
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mg/kg/h',
      doseMin: isAdulto ? 0.02 : 0.06,
      doseMax: 0.15,
      concentracaoEmMcg: false,
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

  static Widget _linhaIndicacaoDoseFixa({
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
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.green.shade700,
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
            child: Text(
              texto,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
