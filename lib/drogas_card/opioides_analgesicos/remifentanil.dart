import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRemifentanil {
  static const String nome = 'Remifentanil';
  static const String idBulario = 'remifentanil';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/remifentanil.json');
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
      conteudo: _buildCardRemifentanil(
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

    return _buildCardRemifentanil(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardRemifentanil(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Opioide sintético ultra-curto', 'Agonista μ, meia-vida 3-10 min'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco-ampola 1mg', 'Pó liofilizado'),
        _linhaPreparo('Frasco-ampola 2mg', 'Pó liofilizado'),
        _linhaPreparo('Frasco-ampola 5mg', 'Pó liofilizado'),

        // 3. PREPARO (maior para menor concentração)
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('5mg + 100mL SF 0,9%', '50 mcg/mL'),
        _linhaPreparo('2mg + 50mL SF 0,9%', '40 mcg/mL'),
        _linhaPreparo('1mg + 50mL SF 0,9%', '20 mcg/mL'),
        _textoObs('Reconstituir com água estéril antes de diluir'),

        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          // BOLUS - caixa azul calculada
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica (bolus)',
            descricaoDose: '1 mcg/kg IV em 30-60 seg (com hipnótico)',
            dosePorKg: 1.0,
            unidade: 'mcg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação sem BNM (bolus)',
            descricaoDose: '3-4 mcg/kg IV lento (com propofol 2-2,5 mg/kg)',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 4.0,
            unidade: 'mcg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Bolus adicional intraop (se superficial)',
            descricaoDose: '1 mcg/kg IV em 30-60 seg (repetir a cada 2-5 min SN)',
            dosePorKg: 1.0,
            unidade: 'mcg',
            peso: peso,
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Indução (infusão)',
            descricaoDose: '0,5-1 mcg/kg/min IV contínua',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção com N2O 66%',
            descricaoDose: '0,1-2 mcg/kg/min (média 0,4 mcg/kg/min)',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção com propofol/isoflurano',
            descricaoDose: '0,05-2 mcg/kg/min (média 0,25 mcg/kg/min)',
          ),
        ] else ...[
          // PEDIÁTRICO
          _linhaIndicacaoDoseCalculada(
            titulo: 'Indução pediátrica (bolus)',
            descricaoDose: '1 mcg/kg IV em 30-60 seg',
            dosePorKg: 1.0,
            unidade: 'mcg',
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica sem BNM',
            descricaoDose: '2-3 mcg/kg IV lento (com sevoflurano)',
            dosePorKgMinima: 2.0,
            dosePorKgMaxima: 3.0,
            unidade: 'mcg',
            peso: peso,
          ),
          // INFUSÃO CONTÍNUA - caixa laranja
          _linhaIndicacaoInfusao(
            titulo: 'Indução pediátrica (infusão)',
            descricaoDose: '0,5-1 mcg/kg/min IV contínua',
          ),
          _linhaIndicacaoInfusao(
            titulo: 'Manutenção pediátrica',
            descricaoDose: '0,05-2 mcg/kg/min IV contínua',
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
        _textoObs('Início: <1 min | Recuperação: 5-10 min (esterases)'),
        _textoObs('SINERGISMO: reduzir propofol/isoflurano/midazolam em até 75%'),
        _textoObs('DOR PÓS-OP: iniciar analgesia multimodal ANTES de suspender'),
        _textoObs('Depressão respiratória intensa - VM obrigatória'),
        _textoObs('Rigidez torácica se bolus rápido - administrar lentamente'),
        _textoObs('NÃO requer ajuste em insuficiência renal ou hepática'),
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
    // Concentrações em mcg/mL - ordenadas da maior para menor
    final opcoesConcentracoes = {
      '5mg + 100mL SF (50 mcg/mL)': 50.0,
      '2mg + 50mL SF (40 mcg/mL)': 40.0,
      '1mg + 50mL SF (20 mcg/mL)': 20.0,
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: 0.05,
      doseMax: 2.0,
      concentracaoEmMcg: true,
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    required String unidade,
    required double peso,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
  }) {
    String? textoDose;
    bool doseLimite = false;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseMin.toStringAsFixed(1)}-${doseMax.toStringAsFixed(1)} $unidade';
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
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Text(
                doseLimite ? 'Dose: $textoDose (máx atingida)' : 'Dose: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
