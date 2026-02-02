import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCetamina {
  static const String nome = 'Cetamina';
  static const String idBulario = 'cetamina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/cetamina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Verificar se há indicações para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink(); // Não exibe o card se não há indicações
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardCetamina(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Cetamina tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
      case 'Lactente':
      case 'Criança':
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        return true;
      default:
        return false;
    }
  }

  static Widget _buildCardCetamina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anestésico dissociativo', 'Antagonista NMDA'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 500mg/10mL', '50 mg/mL'),
        _linhaPreparo('Ampola 100mg/2mL', '50 mg/mL'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('100mg + 50mL SF', '2 mg/mL'),
        _linhaPreparo('50mg + 50mL SF', '1 mg/mL'),
        _linhaPreparo('50mg + 100mL SF', '0,5 mg/mL'),
        _linhaPreparo('Bolus: puro da ampola', 'IV lento, IM ou SC'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica IV',
            descricaoDose: '1-2 mg/kg IV lento',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica IM',
            descricaoDose: '4-6 mg/kg IM',
            unidade: 'mg',
            dosePorKgMinima: 4,
            dosePorKgMaxima: 6,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Sedação procedimentos',
            descricaoDose: '0,25-0,5 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 0.5,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Infusão manutenção',
            descricaoDose: '0,5-2 mg/kg/h IV contínua',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução pediátrica IV',
            descricaoDose: '1-2 mg/kg IV lento',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução pediátrica IM',
            descricaoDose: '4-6 mg/kg IM',
            unidade: 'mg',
            dosePorKgMinima: 4,
            dosePorKgMaxima: 6,
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Infusão pediátrica',
            descricaoDose: '0,5-1,5 mg/kg/h IV contínua',
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
        _textoObs('Mantém reflexos de VA, PA e drive respiratório'),
        _textoObs('Início IV: 30-60s | IM: 3-5min | Duração: 10-20min'),
        _textoObs('Emergence delirium - considerar BZD profilático'),
        _textoObs('Hipersalivação - considerar atropina'),
        _textoObs('CI: HAS severa, PIC elevada, glaucoma, psicose'),
        _textoObs('Broncodilatador - útil em asma/broncoespasmo'),
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
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKg != null) {
      double dose = dosePorKg * peso;
      if (doseMaxima != null && dose > doseMaxima) dose = doseMaxima;
      textoDose = '${dose.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) doseMax = doseMaxima;
      if (doseMin > doseMax) doseMin = doseMax;
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
    // Ordenar da maior para menor concentração
    final opcoesConcentracoes = {
      '100mg + 50mL SF (2 mg/mL)': 2.0, // mg/mL
      '50mg + 50mL SF (1 mg/mL)': 1.0, // mg/mL
      '50mg + 100mL SF (0,5 mg/mL)': 0.5, // mg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 2.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 1.5,
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