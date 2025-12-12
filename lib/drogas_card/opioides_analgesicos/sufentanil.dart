import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSufentanil {
  static const String nome = 'Sufentanil';
  static const String idBulario = 'sufentanil';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/sufentanil.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    // Sufentanil tem indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    // Verificar se deve mostrar o card para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria()) {
      return const SizedBox.shrink();
    }

    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardSufentanil(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardSufentanil(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSufentanil._textoObs('Analgésico opioide ultrapotente - Agonista μ-opioide (7-10× fentanil)'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSufentanil._linhaPreparo('Ampola 50 mcg/mL (1mL, 2mL, 5mL)', 'Sufenta®'),
        MedicamentoSufentanil._linhaPreparo('Início: 1-3 min | Pico: 3-5 min', 'Rápido'),
        MedicamentoSufentanil._linhaPreparo('Duração: 20-30 min (bolus)', 'Curta'),
        MedicamentoSufentanil._linhaPreparo('Meia-vida: 2,5-3h', 'Efeito cumulativo infusão prolongada'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSufentanil._linhaPreparo('Bolus: administrar direto (50 mcg/mL)', 'Lento ≥60 seg'),
        MedicamentoSufentanil._linhaPreparo('Infusão: diluir em SF 0,9% ou SG 5%', 'Ex: 250 mcg em 50mL = 5 mcg/mL'),
        MedicamentoSufentanil._linhaPreparo('Intratecal: solução SEM conservantes', 'Técnica asséptica rigorosa'),
        MedicamentoSufentanil._linhaPreparo('Armazenamento: 15-30°C', 'Proteger luz'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSufentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Bolus anestésico (indução/manutenção)',
            descricaoDose: '0,3-1 mcg/kg IV lento (≥60 seg)',
            unidade: 'mcg',
            dosePorKgMinima: 0.3,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          MedicamentoSufentanil._linhaIndicacaoDoseFixa(
            titulo: 'Intratecal (adjuvante bloqueio raqui)',
            descricaoDose: '2,5-10 mcg IT (obstetrícia, ortopedia)',
            doseFixa: '2,5-10 mcg',
          ),
        ] else ...[
          MedicamentoSufentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Bolus pediátrico (indução/manutenção)',
            descricaoDose: '0,1-0,3 mcg/kg IV lento (≥60 seg)',
            unidade: 'mcg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.3,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSufentanil._textoObs('Indicação: Anestesia geral, sedação UTI, cirurgias prolongadas'),
        _buildConversorInfusao(context, peso, faixaEtaria),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSufentanil._textoObs('Opioide ultrapotente - 7-10× mais potente que fentanil'),
        MedicamentoSufentanil._textoObs('Alta lipossolubilidade - rápida penetração SNC'),
        MedicamentoSufentanil._textoObs('Estabilidade hemodinâmica superior - mínima liberação histamina'),
        MedicamentoSufentanil._textoObs('Ideal cirurgias cardíacas, neurocirurgias, grandes cirurgias'),
        MedicamentoSufentanil._textoObs('Efeito cumulativo significativo em infusões prolongadas'),
        MedicamentoSufentanil._textoObs('ATENÇÃO: Depressão respiratória prolongada (ter naloxona)'),
        MedicamentoSufentanil._textoObs('ATENÇÃO: Rigidez torácica se bolus rápido (administrar ≥60 seg)'),
        MedicamentoSufentanil._textoObs('Monitorar: SatO2, capnografia, pressão arterial, FC'),
        MedicamentoSufentanil._textoObs('Suporte ventilatório obrigatório disponível'),
      ],
    );
  }

  static Widget _buildConversorInfusao(BuildContext context, double peso, String faixaEtaria) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAdulto) ...[
          MedicamentoSufentanil._textoObs('Adulto: 0,1-0,5 mcg/kg/h'),
          MedicamentoSufentanil._textoObs('  • Anestesia geral: 0,2-0,5 mcg/kg/h'),
          MedicamentoSufentanil._textoObs('  • Sedação UTI: 0,1-0,3 mcg/kg/h'),
        ] else ...[
          MedicamentoSufentanil._textoObs('Pediátrico: 0,05-0,3 mcg/kg/h'),
          MedicamentoSufentanil._textoObs('  • UTI com ventilação: titular individualmente'),
        ],
        const SizedBox(height: 8),
        ConversaoInfusaoSlider(
          peso: peso,
          opcoesConcentracoes: {
            '1 mcg/mL (50mcg/50mL)': 1,
            '2 mcg/mL (100mcg/50mL)': 2,
            '5 mcg/mL (250mcg/50mL)': 5,
            '10 mcg/mL (500mcg/50mL)': 10,
          },
          doseMin: isAdulto ? 0.1 : 0.05,
          doseMax: isAdulto ? 0.5 : 0.3,
          unidade: 'mcg/kg/h',
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        texto.startsWith('•') ? texto : '• $texto',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
