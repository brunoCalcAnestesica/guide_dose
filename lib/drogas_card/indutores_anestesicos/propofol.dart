import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPropofol {
  static const String nome = 'Propofol';
  static const String idBulario = 'propofol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/propofol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso' || faixaEtaria == 'Adolescente';
    final isFavorito = favoritos.contains(nome);

    // Propofol não é recomendado em neonatos
    if (faixaEtaria == 'Neonato') {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardPropofol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardPropofol(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anestésico IV', 'Hipnótico-sedativo (alquifenol)'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 200 mg/20 mL', '10 mg/mL (1%) | Diprivan®'),
        _linhaPreparo('Frasco 500 mg/50 mL', '10 mg/mL (1%)'),
        _linhaPreparo('Frasco 1000 mg/100 mL', '10 mg/mL (1%)'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Puro (NÃO diluir)', '10 mg/mL - padrão'),
        _linhaPreparo('Se necessário diluir', 'Somente SG 5% (mín 2 mg/mL)'),
        _textoObs('Emulsão lipídica - técnica asséptica rigorosa'),
        _textoObs('Descartar em 6h após abertura'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - caixa azul (calculadas)
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: '1,5-2,5 mg/kg IV lento (30-60 seg)',
            dosePorKgMinima: 1.5,
            dosePorKgMaxima: 2.5,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Sedação para procedimentos',
            descricaoDose: '0,5-1 mg/kg IV lento, repetir PRN',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            unidade: 'mg',
            peso: peso,
          ),
          // INFUSÃO - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção anestésica (TIVA)',
            descricaoDose: '4-12 mg/kg/h IV contínua',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Sedação UTI',
            descricaoDose: '0,3-4 mg/kg/h IV contínua (titular BIS 40-60)',
          ),
        ] else ...[
          // PEDIÁTRICO (>3 anos)
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica (>3 anos)',
            descricaoDose: '2,5-3,5 mg/kg IV lento',
            dosePorKgMinima: 2.5,
            dosePorKgMaxima: 3.5,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Sedação para procedimentos',
            descricaoDose: '1-2 mg/kg IV lento',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 2.0,
            unidade: 'mg',
            peso: peso,
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção anestésica',
            descricaoDose: '6-15 mg/kg/h IV (procedimentos curtos)',
          ),
          _textoObs('⚠️ EVITAR sedação prolongada em UTI pediátrica (PRIS)'),
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
        _textoObs('Hipotensão + bradicardia dose-dependente'),
        _textoObs('Dor à injeção - lidocaína 20-40 mg IV antes'),
        _textoObs('Contraindicado: alergia ovo/soja/amendoim'),
        _textoObs('⚠️ PRIS: NÃO usar >4 mg/kg/h por >48h'),
        _textoObs('PRIS: acidose, rabdomiólise, arritmias, óbito'),
        _textoObs('Idosos: reduzir 30-50% da dose de indução'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Propofol geralmente é usado PURO (10 mg/mL)
    // Concentrações em mg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      'Puro 10 mg/mL (padrão)': 10.0, // mg/mL
      'Diluído 5 mg/mL': 5.0, // mg/mL
      'Diluído 2 mg/mL': 2.0, // mg/mL
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mg/kg/h',
      doseMin: isAdulto ? 0.3 : 1.0,
      doseMax: isAdulto ? 12.0 : 15.0,
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
