import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMilrinona {
  static const String nome = 'Milrinona';
  static const String idBulario = 'milrinona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/milrinona.json');
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
      conteudo: _buildCardMilrinona(
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

    return _buildCardMilrinona(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardMilrinona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Inodilatador', 'Inibidor da PDE3'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 10mg/10mL', '1 mg/mL | Primacor®'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('20mg + 80mL SF', '200 mcg/mL'),
        _linhaPreparo('10mg + 90mL SF', '100 mcg/mL'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // DOSE DE ATAQUE (BOLUS) - caixa azul calculada
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dose de ataque (opcional)',
            descricaoDose: '50 mcg/kg IV em 10 min (omitir se hipotenso)',
            dosePorKg: 50,
            unidade: 'mcg',
            peso: peso,
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'IC descompensada / Choque cardiogênico',
            descricaoDose: '0,375-0,75 mcg/kg/min IV contínua',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dose de ataque pediátrica',
            descricaoDose: '50-75 mcg/kg IV em 10-60 min',
            dosePorKgMinima: 50,
            dosePorKgMaxima: 75,
            unidade: 'mcg',
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção pediátrica',
            descricaoDose: '0,25-0,75 mcg/kg/min IV contínua',
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
        _textoObs('Início: 5-15min | Meia-vida: 2-3h'),
        _textoObs('Inotrópico + vasodilatador (pós-carga/pré-carga)'),
        _textoObs('HIPOTENSÃO - omitir bolus se PA baixa'),
        _textoObs('Arritmias: monitorar ECG contínuo'),
        _textoObs('Reduzir 25-50% se ClCr <50 mL/min'),
        _textoObs('Pode associar com catecolaminas'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em mcg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '20mg + 80mL SF (200 mcg/mL)': 200.0, // mcg/mL
      '10mg + 90mL SF (100 mcg/mL)': 100.0, // mcg/mL
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: isAdulto ? 0.375 : 0.25,
      doseMax: 0.75,
      concentracaoEmMcg: true,
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseMin.toStringAsFixed(0)}-${doseMax.toStringAsFixed(0)} $unidade';
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
