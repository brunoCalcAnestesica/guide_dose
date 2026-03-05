import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoVasopressina {
  static const String nome = 'Vasopressina';
  static const String idBulario = 'vasopressina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/vasopressina.json');
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
      conteudo: _buildCardVasopressina(
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

    return _buildCardVasopressina(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardVasopressina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Vasopressor não-catecolaminérgico', 'Agonista V1/V2 (ADH sintético)'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 20 U/mL', '1 mL'),

        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('40U (2 amp) + 100mL SF', '0,4 U/mL'),
        _linhaPreparo('20U (1 amp) + 100mL SF', '0,2 U/mL'),
        _textoObs('Acesso CENTRAL obrigatório'),

        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - caixa azul (dose fixa)
          _linhaIndicacaoDoseFixa(
            titulo: 'PCR (ACLS)',
            descricaoDose: '40 U IV/IO bolus (substitui 1ª ou 2ª adrenalina)',
            doseFixa: '40 U',
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Choque séptico (adjuvante noradrenalina)',
            descricaoDose: '0,01-0,04 U/min (dose FIXA, não titular)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Choque vasodilatado/pós-PCR',
            descricaoDose: '0,01-0,04 U/min IV contínua',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Hemorragia varicosa',
            descricaoDose: '0,2-0,4 U/min IV (associar nitroglicerina)',
          ),
        ] else ...[
          // PEDIÁTRICO
          _linhaIndicacaoInfusao(
            titulo: 'Choque séptico pediátrico',
            descricaoDose: '0,0002-0,002 U/kg/min (máx 0,04 U/min)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Choque refratário a catecolaminas',
            descricaoDose: '0,0003-0,002 U/kg/min IV contínua',
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
        _textoObs('Início: 15-20 min | Meia-vida: 10-35 min'),
        _textoObs('ADJUVANTE noradrenalina - nunca 1ª linha'),
        _textoObs('Dose FIXA 0,03 U/min - não titular como catecolaminas'),
        _textoObs('Isquemia digital/mesentérica - monitorar perfusão'),
        _textoObs('Hiponatremia (efeito V2) - monitorar Na+'),
        _textoObs('Extravasamento → necrose - acesso central'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    // Concentrações em U/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '40U + 100mL SF (0,4 U/mL)': 0.4,
      '20U + 100mL SF (0,2 U/mL)': 0.2,
    };

    if (isAdulto) {
      // Adulto: dose fixa em U/min (não por kg)
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'U/min',
        doseMin: 0.01,
        doseMax: 0.04,
      );
    } else {
      // Pediátrico: U/kg/min
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'U/kg/min',
        doseMin: 0.0002,
        doseMax: 0.002,
      );
    }
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
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
