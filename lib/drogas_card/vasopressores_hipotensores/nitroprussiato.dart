import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoNitroprussiato {
  static const String nome = 'Nitroprussiato de Sódio';
  static const String idBulario = 'nitroprussiato';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/nitroprussiato.json');
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
      conteudo: _buildCardNitroprussiato(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardNitroprussiato(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Vasodilatador', 'Nitrovasodilatador arterial + venoso'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 50mg', 'Pó liofilizado | Nipride®'),
        
        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('100mg + 150mL SG5%', '400 mcg/mL'),
        _linhaPreparo('50mg + 200mL SG5%', '200 mcg/mL'),
        _linhaPreparo('50mg + 450mL SG5%', '100 mcg/mL'),
        _textoObs('⚠️ FOTOSSENSÍVEL - proteger da luz (equipo opaco)'),
        
        // 4. INDICAÇÕES CLÍNICAS (TODAS infusão contínua - caixa laranja)
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoInfusao(
            titulo: 'Emergência hipertensiva',
            descricaoDose: '0,25-10 mcg/kg/min IV (iniciar 0,3 mcg/kg/min)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'IC aguda / Redução pós-carga',
            descricaoDose: '0,25-3 mcg/kg/min IV contínua',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Hipotensão controlada (cirurgia)',
            descricaoDose: '0,5-8 mcg/kg/min IV contínua',
          ),
        ] else ...[
          _linhaIndicacaoInfusao(
            titulo: 'Crise hipertensiva pediátrica',
            descricaoDose: '0,5-3 mcg/kg/min IV (iniciar baixo)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Pós-op cardíaco pediátrico',
            descricaoDose: '0,5-4 mcg/kg/min IV contínua',
          ),
        ],
        
        // 5. INFUSÃO CONTÍNUA
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Dose máx: 10 mcg/kg/min (<10 min) ou 2 mcg/kg/min (prolongado)'),
        _buildConversorInfusao(peso, isAdulto),
        
        // 6. OBSERVAÇÕES (6 mais importantes)
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: segundos | Meia-vida: 2 min'),
        _textoObs('TOXICIDADE CIANETO: >2 mcg/kg/min por >24-48h'),
        _textoObs('Antídoto: tiossulfato de sódio, hidroxicobalamina'),
        _textoObs('Monitorizar cianeto se uso >24h ou IR/IH'),
        _textoObs('FOTOSSENSÍVEL - trocar solução cada 4-6h'),
        _textoObs('Arteriodilatador = venodilatador (reduz pré e pós-carga)'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em mcg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '100mg + 150mL SG5% (400 mcg/mL)': 400.0, // mcg/mL
      '50mg + 200mL SG5% (200 mcg/mL)': 200.0, // mcg/mL
      '50mg + 450mL SG5% (100 mcg/mL)': 100.0, // mcg/mL
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: isAdulto ? 0.25 : 0.5,
      doseMax: isAdulto ? 8.0 : 4.0,
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
