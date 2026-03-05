import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCisatracurio {
  static const String nome = 'Cisatracúrio';
  static const String idBulario = 'cisatracurio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/cisatracurio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
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
      conteudo: _buildCardCisatracurio(
        context,
        peso,
        faixaEtaria,
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

    return _buildCardCisatracurio(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardCisatracurio(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('BNM não despolarizante', 'Ação intermediária'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 10mg/5mL', '2 mg/mL'),
        _linhaPreparo('Ampola 20mg/10mL', '2 mg/mL'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('100mg + 100mL SF', '1000 mcg/mL'),
        _linhaPreparo('50mg + 100mL SF', '500 mcg/mL'),
        _linhaPreparo('20mg + 100mL SF', '200 mcg/mL'),
        _linhaPreparo('Bolus: puro da ampola', 'IV lento 20-30s'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação',
            descricaoDose: '0,15-0,2 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.15,
            dosePorKgMaxima: 0.2,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção bolus',
            descricaoDose: '0,03 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKg: 0.03,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Infusão manutenção',
            descricaoDose: '1-3 mcg/kg/min IV contínua',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica',
            descricaoDose: '0,1-0,15 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.15,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Infusão pediátrica',
            descricaoDose: '1-2 mcg/kg/min IV contínua',
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
        _textoObs('Início: 2-3min | Duração: 40-60min'),
        _textoObs('Degradação por reação de Hofmann (independente de fígado/rim)'),
        _textoObs('NÃO libera histamina - seguro em asmáticos'),
        _textoObs('Monitorização TOF obrigatória'),
        _textoObs('Potencializado por: voláteis, aminoglicosídeos, Mg'),
        _textoObs('Armazenar refrigerado (2-8°C)'),
      ],
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
    required String unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKg != null) {
      double dose = dosePorKg * peso;
      if (dose < 1) {
        textoDose = '${dose.toStringAsFixed(2)} $unidade';
      } else {
        textoDose = '${dose.toStringAsFixed(1)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMin < 1 && doseMax < 1) {
        textoDose = '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
      } else {
        textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em mcg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '100mg + 100mL SF (1000 mcg/mL)': 1000.0, // mcg/mL
      '50mg + 100mL SF (500 mcg/mL)': 500.0, // mcg/mL
      '20mg + 100mL SF (200 mcg/mL)': 200.0, // mcg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 1.0,
        doseMax: 3.0,
        concentracaoEmMcg: true,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 1.0,
        doseMax: 2.0,
        concentracaoEmMcg: true,
      );
    }
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