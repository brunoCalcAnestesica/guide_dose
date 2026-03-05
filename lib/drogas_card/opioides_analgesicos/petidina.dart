import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPetidina {
  static const String nome = 'Petidina';
  static const String idBulario = 'petidina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/petidina.json');
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
      conteudo: _buildCardPetidina(
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

    return _buildCardPetidina(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardPetidina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Opioide sintético', 'Agonista μ (meperidina)'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 100 mg/2 mL', '50 mg/mL | Dolantina®'),
        _linhaPreparo('Ampola 50 mg/mL', '1 mL'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Puro (sem diluir)', '50 mg/mL'),
        _linhaPreparo('100mg + 10mL SF', '10 mg/mL (IV lento)'),
        _linhaPreparo('100mg + 100mL SF', '1 mg/mL (infusão)'),
        _textoObs('Administrar IV LENTO (máx 25 mg/min)'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - caixa verde (doses fixas)
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda moderada/grave',
            descricaoDose: '25-100 mg IV lento ou 50-150 mg IM/SC a cada 3-4h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Tremores pós-anestésicos',
            descricaoDose: '12,5-25 mg IV lento (efeito antitremor)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Analgesia obstétrica',
            descricaoDose: '50-100 mg IM (trabalho de parto)',
          ),
          // INFUSÃO - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Infusão contínua (evitar)',
            descricaoDose: '10-35 mg/h IV (máx 48h - risco normeperidina)',
          ),
        ] else ...[
          // PEDIÁTRICO - dose calculada
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda pediátrica IV',
            descricaoDose: '0,5-1 mg/kg IV lento (máx 50 mg/dose)',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            doseMaxima: 50,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda pediátrica IM/SC',
            descricaoDose: '1-1,5 mg/kg a cada 3-4h (máx 100 mg/dose)',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 1.5,
            doseMaxima: 100,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Infusão contínua pediátrica',
            descricaoDose: '0,5-1 mg/kg/h IV (evitar uso prolongado)',
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
        _textoObs('Potência: 1/10 da morfina (100mg = 10mg morfina)'),
        _textoObs('⚠️ EVITAR uso >48h (acúmulo normeperidina → convulsões)'),
        _textoObs('CONTRAINDICADO com IMAOs (intervalo mínimo 14 dias)'),
        _textoObs('Dose máxima: 600 mg/dia adulto | 8-10 mg/kg/dia pediátrico'),
        _textoObs('Reversão: naloxona 0,4-2 mg IV disponível'),
        _textoObs('Preferir outros opioides para analgesia prolongada'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em mg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '100mg + 10mL SF (10 mg/mL)': 10.0, // mg/mL
      '200mg + 100mL SF (2 mg/mL)': 2.0, // mg/mL
      '100mg + 100mL SF (1 mg/mL)': 1.0, // mg/mL
    };

    // Adulto: mg/h (dose fixa)
    // Pediátrico: mg/kg/h
    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/h',
        doseMin: 10.0,
        doseMax: 35.0,
        concentracaoEmMcg: false,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 1.0,
        concentracaoEmMcg: false,
      );
    }
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
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
  }) {
    String? textoDose;

    if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Dose: $textoDose',
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
