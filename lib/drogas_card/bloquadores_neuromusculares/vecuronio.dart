import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoVecuronio {
  static const String nome = 'Vecurônio';
  static const String idBulario = 'vecuronio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/vecuronio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardVecuronio(
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
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardVecuronio(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardVecuronio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Bloqueador neuromuscular não despolarizante', 'Aminoesteroidal - Ação intermediária'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 10 mg liofilizado', 'Norcuron®'),
        _linhaPreparo('Frasco 4 mg liofilizado', 'Norcuron®'),

        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('10 mg + 5 mL SF', '2000 mcg/mL (2 mg/mL)'),
        _linhaPreparo('10 mg + 10 mL SF', '1000 mcg/mL (1 mg/mL)'),
        _linhaPreparo('4 mg + 4 mL SF', '1000 mcg/mL (1 mg/mL)'),
        _textoObs('Para bolus - usar reconstituído'),

        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - caixa azul
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação orotraqueal eletiva',
            descricaoDose: '0,08-0,1 mg/kg IV (IOT em 2,5-3 min)',
            unidade: 'mg',
            dosePorKgMinima: 0.08,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Após succinilcolina',
            descricaoDose: '0,04-0,06 mg/kg IV (dose reduzida)',
            unidade: 'mg',
            dosePorKgMinima: 0.04,
            dosePorKgMaxima: 0.06,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (bolus)',
            descricaoDose: '0,01-0,015 mg/kg IV a cada 12-15 min',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.015,
            peso: peso,
          ),
          // INFUSÃO - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção (infusão contínua)',
            descricaoDose: '0,8-1,2 mcg/kg/min (iniciar 20-40 min após bolus)',
          ),
        ] else ...[
          // PEDIÁTRICO - BOLUS
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação neonato/lactente/criança',
            descricaoDose: '0,1 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKg: 0.1,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (bolus)',
            descricaoDose: '0,03-0,15 mg/kg IV a cada 1-2h',
            unidade: 'mg',
            dosePorKgMinima: 0.03,
            dosePorKgMaxima: 0.15,
            peso: peso,
            doseMaxima: peso * 0.2, // máx 0,2 mg/kg
          ),
          // INFUSÃO - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção (infusão contínua)',
            descricaoDose: '1-3 mcg/kg/min (60-200 mcg/kg/h)',
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
        _textoObs('Início: 2-3 min | Duração: 25-40 min'),
        _textoObs('Monitorar TOF (alvo >0,9 para extubação)'),
        _textoObs('Reversão: sugammadex 2-4 mg/kg ou neostigmina 0,05 mg/kg'),
        _textoObs('Neonatos: sensibilidade AUMENTADA (não reduzir dose)'),
        _textoObs('Acúmulo em hepatopata/IR - metabólito ativo'),
        _textoObs('Potencializado por voláteis, aminoglicosídeos, Mg²⁺'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em mcg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '10mg + 5mL SF (2000 mcg/mL)': 2000.0,
      '10mg + 10mL SF (1000 mcg/mL)': 1000.0,
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: isAdulto ? 0.8 : 1.0,
      doseMax: isAdulto ? 1.2 : 3.0,
      concentracaoEmMcg: true,
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
