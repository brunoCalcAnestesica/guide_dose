import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoNitroglicerina {
  static const String nome = 'Nitroglicerina';
  static const String idBulario = 'nitroglicerina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/nitroglicerina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardNitroglicerina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardNitroglicerina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Vasodilatador', 'Nitrato orgânico (doador de NO)'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 5mg/mL', '10mL (50mg) | Tridil®'),
        _linhaPreparo('Ampola 5mg/mL', '5mL (25mg)'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('100mg + 150mL SG5%', '400 mcg/mL'),
        _linhaPreparo('50mg + 200mL SG5%', '200 mcg/mL'),
        _linhaPreparo('25mg + 225mL SG5%', '100 mcg/mL'),
        _textoObs('Usar frasco de vidro ou equipo sem PVC'),
        
        // 4. INDICAÇÕES CLÍNICAS (TODAS infusão contínua - caixa laranja)
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoInfusao(
            titulo: 'Angina instável / SCA',
            descricaoDose: '5-200 mcg/min IV contínua (iniciar 5 mcg/min)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'IC aguda / EAP',
            descricaoDose: '10-200 mcg/min IV contínua (reduz pré-carga)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Emergência hipertensiva',
            descricaoDose: '5-100 mcg/min IV contínua (titular PA)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Hipotensão controlada',
            descricaoDose: '0,5-5 mcg/kg/min IV contínua',
          ),
        ] else ...[
          _linhaIndicacaoInfusao(
            titulo: 'Hipertensão pulmonar',
            descricaoDose: '0,5-5 mcg/kg/min IV contínua',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'IC pediátrica / Pós-op cardíaco',
            descricaoDose: '0,25-5 mcg/kg/min IV contínua',
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
        _textoObs('Início: 1-2 min | Meia-vida: 1-4 min'),
        _textoObs('Venodilatador > arteriodilatador (reduz pré-carga)'),
        _textoObs('CONTRAINDICADO com sildenafil/inibidores PDE5'),
        _textoObs('Tolerância em 24-48h de uso contínuo'),
        _textoObs('Cefaleia é efeito comum - não suspender'),
        _textoObs('Idoso: iniciar com doses menores'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em mcg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '100mg + 150mL SG5% (400 mcg/mL)': 400.0, // mcg/mL
      '50mg + 200mL SG5% (200 mcg/mL)': 200.0, // mcg/mL
      '25mg + 225mL SG5% (100 mcg/mL)': 100.0, // mcg/mL
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: isAdulto ? 0.1 : 0.25,
      doseMax: isAdulto ? 3.0 : 5.0,
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
