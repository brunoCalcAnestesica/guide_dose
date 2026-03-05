import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSolucaoSalinaHipertonica {
  static const String nome = 'Salina 3%';
  static const String idBulario = 'solucaosalinahipertonica';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle
        .loadString('assets/medicamentos/solucaosalinahipertonica.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    // Solução salina hipertônica tem indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    // Verificar se deve mostrar o card para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria()) {
      return const SizedBox.shrink();
    }

    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardSolucaoSalinaHipertonica(
        context,
        peso,
        faixaEtaria,
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

    return _buildCardSolucaoSalinaHipertonica(
      context,
      peso,
      faixaEtaria,
      isFavorito,
      () => onToggleFavorito(nome),
    );
  }

  static Widget _buildCardSolucaoSalinaHipertonica(
      BuildContext context,
      double peso,
      String faixaEtaria,
      bool isFavorito,
      VoidCallback onToggleFavorito) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'Solução eletrolítica hipertônica (NaCl 3%) - Corretor hidroeletrolítico'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Frasco/bolsa 250mL, 500mL, 1000mL', '30 mg/mL = 3%'),
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Osmolaridade: 513 mOsm/L', '1,7× plasma (300 mOsm/L)'),
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Composição: 0,51 mEq Na⁺/mL', '51 mEq/100mL, 255 mEq/500mL'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Pronto uso - NÃO diluir', 'Já vem NaCl 3%'),
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Via periférica calibrosa ou central',
            'Vigiar flebite via periférica'),
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Infusão contínua bomba', 'Controle rigoroso velocidade'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSolucaoSalinaHipertonica._linhaIndicacaoDoseFixa(
            titulo: 'Hiponatremia crônica sintomática (Na⁺ <120 mEq/L)',
            descricaoDose:
                '50-150 mL/h IV contínuo bomba. Meta: ↑Na⁺ 0,5-1 mEq/L/h',
            doseFixa: '50-150 mL/h',
          ),
          MedicamentoSolucaoSalinaHipertonica._linhaIndicacaoDoseFixa(
            titulo: 'Ressuscitação volêmica (trauma, choque)',
            descricaoDose:
                '250 mL IV rápido (equivale ~1L SF 0,9%). Repetir se necessário',
            doseFixa: '250 mL',
          ),
          MedicamentoSolucaoSalinaHipertonica._linhaIndicacaoDoseFixa(
            titulo: 'Edema cerebral (osmoterapia moderada)',
            descricaoDose: '150-250 mL IV em 15-30 min',
            doseFixa: '150-250 mL',
          ),
        ] else ...[
          MedicamentoSolucaoSalinaHipertonica._linhaIndicacaoDoseCalculada(
            titulo: 'Hiponatremia crônica sintomática pediátrica',
            descricaoDose: '1-2 mL/kg/h IV contínuo bomba (máx 100 mL/h)',
            unidade: 'mL/h',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 2.0,
            doseMaxima: 100,
            peso: peso,
          ),
          MedicamentoSolucaoSalinaHipertonica._linhaIndicacaoDoseCalculada(
            titulo: 'Ressuscitação volêmica pediátrica',
            descricaoDose: '3-5 mL/kg IV rápido (máx 250 mL)',
            unidade: 'mL',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 5.0,
            doseMaxima: 250,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'Indicação: Correção CRÔNICA controlada hiponatremia'),
        if (isAdulto) ...[
          MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
              'Velocidade inicial: 50-100 mL/h', 'Adulto'),
          MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
              'Velocidade máxima: 150 mL/h', 'Ajustar conforme Na⁺'),
          MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
              'Meta: ↑Na⁺ 0,5-1 mEq/L/h', 'Máx 10-12 mEq/L/24h'),
        ] else ...[
          MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
              'Velocidade: 1-2 mL/kg/h', 'Pediátrico (máx 100 mL/h)'),
          MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
              'Meta: ↑Na⁺ 0,5 mEq/L/h', 'Máx 10 mEq/L/24h pediátrico'),
        ],
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Monitorar Na⁺ horário primeiras 6h', 'Depois 4/4h'),
        MedicamentoSolucaoSalinaHipertonica._linhaPreparo(
            'Suspender: Na⁺ >120 mEq/L ou ↑>10 mEq/L/24h',
            'Prevenir mielinólise'),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'NaCl 3% (SSH) - osmolaridade 513 mOsm/L (1,7× plasma)'),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'Diferença NaCl 3% vs 20%: 3% = correção CRÔNICA controlada (infusão contínua), 20% = emergência AGUDA (bolus convulsão)'),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'Via periférica possível (menos hipertônico que 20%), porém vigiar flebite'),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'Via central preferencial (mais seguro)'),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'ATENÇÃO: Monitorar Na⁺ HORÁRIO - meta ↑0,5-1 mEq/L/h'),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'LIMITE CRÍTICO: Máx ↑10-12 mEq/L/24h (prevenir mielinólise pontina)'),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'Cálculo: 100 mL NaCl 3% ≈ ↑Na⁺ 0,3-0,5 mEq/L (adulto 70kg)'),
        MedicamentoSolucaoSalinaHipertonica._textoObs(
            'Ressuscitação: 250 mL NaCl 3% = expansão equivalente 1L SF 0,9%'),
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
      textoDose =
          '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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
        '• $texto',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
