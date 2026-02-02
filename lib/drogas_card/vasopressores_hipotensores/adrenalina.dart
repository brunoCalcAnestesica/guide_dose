import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAdrenalina {
  static const String nome = 'Adrenalina';
  static const String idBulario = 'adrenalina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/adrenalina.json');
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
      conteudo: _buildCardAdrenalina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAdrenalina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoSimples('Vasopressor - Simpatomimético alfa e beta-adrenérgico'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 1mg/mL (1mL)', '1:1000'),
        _linhaPreparo('Ampola 1mg/10mL', '1:10.000 - para uso IV'),
        _linhaPreparo('Auto-injetor 0,3mg', 'Adulto - anafilaxia'),
        _linhaPreparo('Auto-injetor 0,15mg', 'Pediátrico - anafilaxia'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('1mg + 50mL SF', '20 mcg/mL'),
        _linhaPreparo('1mg + 100mL SF', '10 mcg/mL'),
        _linhaPreparo('1mg + 250mL SF', '4 mcg/mL'),
        _linhaPreparo('Push dose: 1mg + 100mL', '10 mcg/mL (bolus 0,5-2mL)'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'PCR (ACLS)',
            descricaoDose: '1mg IV/IO a cada 3-5 min',
            doseFixa: '1 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Anafilaxia',
            descricaoDose: '0,3-0,5mg IM face lateral da coxa',
            doseFixa: '0,3-0,5 mg IM',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Bradicardia sintomática',
            descricaoDose: '2-10 mcg/min IV infusão',
            doseFixa: '2-10 mcg/min',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Choque (vasopressor)',
            descricaoDose: '0,01-0,5 mcg/kg/min - titular conforme PAM',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'PCR (PALS)',
            descricaoDose: '0,01mg/kg IV/IO a cada 3-5 min (máx 1mg)',
            unidade: 'mg',
            dosePorKg: 0.01,
            doseMaxima: 1.0,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Anafilaxia pediátrica',
            descricaoDose: '0,01mg/kg IM (máx 0,3mg)',
            unidade: 'mg',
            dosePorKg: 0.01,
            doseMaxima: 0.3,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Choque pediátrico',
            descricaoDose: '0,05-0,3 mcg/kg/min IV contínua',
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
        _textoObs('Primeira linha em PCR e anafilaxia'),
        _textoObs('Meia-vida ultracurta: 2-3 minutos'),
        _textoObs('Usar preferencialmente via central (risco de necrose)'),
        _textoObs('Monitorizar ECG contínuo (risco de arritmias)'),
        _textoObs('Dose de anafilaxia: sempre IM, nunca IV em bolus'),
        _textoObs('Incompatível com bicarbonato na mesma via'),
      ],
    );
  }

  static Widget _textoSimples(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
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

  /// Widget para indicações de infusão contínua (sem cálculo - o cálculo fica no slider)
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '1mg em 50mL SF 0,9% (20 mcg/mL)': 20.0, // mcg/mL
      '1mg em 100mL SF 0,9% (10 mcg/mL)': 10.0, // mcg/mL
      '1mg em 250mL SF 0,9% (4 mcg/mL)': 4.0, // mcg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 0.5,
        concentracaoEmMcg: true, // Concentração já em mcg/mL
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 0.3,
        concentracaoEmMcg: true, // Concentração já em mcg/mL
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

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
