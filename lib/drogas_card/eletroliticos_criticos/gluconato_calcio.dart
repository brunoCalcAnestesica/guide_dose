import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoGluconatoCalcio {
  static const String nome = 'Gluconato de Cálcio';
  static const String idBulario = 'gluconato_calcio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle
        .loadString('assets/medicamentos/gluconato_calcio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Gluconato de cálcio tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardGluconatoCalcio(
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
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return _buildCardGluconatoCalcio(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardGluconatoCalcio(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGluconatoCalcio._textoObs(
            'Repositor eletrolítico - Agente cardiotônico - Estabilizador de membrana'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGluconatoCalcio._linhaPreparo(
            'Ampola 10% (100mg/mL) - 10mL', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGluconatoCalcio._linhaPreparo(
            'Bolus IV', 'Usar direto da ampola em 5-10 minutos'),
        MedicamentoGluconatoCalcio._linhaPreparo(
            'Infusão contínua', '1-2g em 100-250mL SF 0,9% ou SG 5%'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseFixa(
            titulo: 'Hipocalcemia aguda sintomática',
            descricaoDose: '1-2g (10-20mL) IV lento em 5-10 minutos',
            doseFixa: '1-2 g (10-20 mL)',
          ),
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseFixa(
            titulo: 'Hipercalemia grave (estabilizador de membrana)',
            descricaoDose: '1g (10mL) IV lento em 2-5 minutos',
            doseFixa: '1 g (10 mL)',
          ),
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseFixa(
            titulo: 'Hipermagnesemia grave',
            descricaoDose: '1-2g (10-20mL) IV lento em 5-10 minutos',
            doseFixa: '1-2 g (10-20 mL)',
          ),
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseFixa(
            titulo: 'Intoxicação por bloqueadores de canal de cálcio',
            descricaoDose: '1-2g (10-20mL) IV, repetir conforme resposta',
            doseFixa: '1-2 g (10-20 mL)',
          ),
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseFixa(
            titulo: 'Reposição após transfusão de concentrado de hemácias',
            descricaoDose:
                '1g (10mL) IV lento a cada 4-5 unidades de sangue transfundidas',
            doseFixa: '1 g (10 mL)',
          ),
        ] else ...[
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseCalculada(
            titulo: 'Hipocalcemia pediátrica',
            descricaoDose: '60-100mg/kg IV lento em 5-10 minutos (máx 1g)',
            unidade: 'mg',
            dosePorKgMinima: 60,
            dosePorKgMaxima: 100,
            peso: peso,
            doseMaxima: 1000,
          ),
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseCalculada(
            titulo: 'Hipercalemia pediátrica',
            descricaoDose: '60-100mg/kg IV lento em 5-10 minutos (máx 1g)',
            unidade: 'mg',
            dosePorKgMinima: 60,
            dosePorKgMaxima: 100,
            peso: peso,
            doseMaxima: 1000,
          ),
          MedicamentoGluconatoCalcio._linhaIndicacaoDoseCalculada(
            titulo: 'Reposição pediátrica após transfusão',
            descricaoDose:
                '60-100mg/kg IV lento a cada 4-5 unidades de sangue (máx 1g)',
            unidade: 'mg',
            dosePorKgMinima: 60,
            dosePorKgMaxima: 100,
            peso: peso,
            doseMaxima: 1000,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGluconatoCalcio._textoObs('Início de ação: 1-3 minutos'),
        MedicamentoGluconatoCalcio._textoObs('Pico de efeito: 3-5 minutos'),
        MedicamentoGluconatoCalcio._textoObs('Duração: 20-60 minutos'),
        MedicamentoGluconatoCalcio._textoObs('Fonte de íons cálcio essenciais'),
        MedicamentoGluconatoCalcio._textoObs('Estabiliza membranas celulares'),
        MedicamentoGluconatoCalcio._textoObs(
            'Melhora contratilidade miocárdica'),
        MedicamentoGluconatoCalcio._textoObs(
            'Corrige excitabilidade neuromuscular'),
        MedicamentoGluconatoCalcio._textoObs(
            'Administrar SEMPRE IV lento (mínimo 5 minutos)'),
        MedicamentoGluconatoCalcio._textoObs(
            'Monitorizar ECG continuamente durante infusão'),
        MedicamentoGluconatoCalcio._textoObs(
            'Menos irritante que cloreto de cálcio'),
        MedicamentoGluconatoCalcio._textoObs(
            'Menor risco de necrose por extravasamento'),
        MedicamentoGluconatoCalcio._textoObs(
            'Preferir acesso central em infusões prolongadas'),
        MedicamentoGluconatoCalcio._textoObs(
            '1g de gluconato = 93mg de cálcio elementar'),
        MedicamentoGluconatoCalcio._textoObs(
            'Ampola 10mL = 1g = 93mg Ca elementar'),
        MedicamentoGluconatoCalcio._textoObs(
            'RISCO: bradicardia/assistolia se infusão rápida'),
        MedicamentoGluconatoCalcio._textoObs(
            'RISCO: arritmias fatais com digitálicos'),
        MedicamentoGluconatoCalcio._textoObs('Monitorar cálcio sérico'),
        MedicamentoGluconatoCalcio._textoObs(
            'Observar local de punção (extravasamento)'),
        MedicamentoGluconatoCalcio._textoObs(
            'Efeitos adversos: rubor, calor, náusea, gosto metálico'),
        MedicamentoGluconatoCalcio._textoObs(
            'Incompatível com bicarbonato de sódio'),
        MedicamentoGluconatoCalcio._textoObs(
            'Incompatível com fosfato (precipitação)'),
        MedicamentoGluconatoCalcio._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoGluconatoCalcio._textoObs(
            'Ajustar dose em insuficiência renal grave'),
        MedicamentoGluconatoCalcio._textoObs('Contraindicado em hipercalcemia'),
        MedicamentoGluconatoCalcio._textoObs('CUIDADO EXTREMO com digitálicos'),
        MedicamentoGluconatoCalcio._textoObs(
            'Transfusões maciças: quelação de Ca pelo citrato do sangue'),
        MedicamentoGluconatoCalcio._textoObs(
            'Repor 1g a cada 4-5 unidades de concentrado de hemácias'),
        MedicamentoGluconatoCalcio._textoObs(
            'Monitorar cálcio iônico durante transfusões'),
        MedicamentoGluconatoCalcio._textoObs('Categoria C na gravidez'),
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
    double? doseCalculada;
    String? textoDose;
    String? textoVolume;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      // Calcular volume (solução 10% = 100mg/mL)
      if (unidade == 'mg') {
        double volume = doseCalculada / 100;
        textoVolume = '${volume.toStringAsFixed(1)} mL';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
      // Calcular volume (solução 10% = 100mg/mL)
      if (unidade == 'mg') {
        double volumeMin = doseMin / 100;
        double volumeMax = doseMax / 100;
        textoVolume =
            '${volumeMin.toStringAsFixed(1)}–${volumeMax.toStringAsFixed(1)} mL';
      }
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
              child: Column(
                children: [
                  Text(
                    'Dose calculada: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (textoVolume != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Volume: $textoVolume (100mg/mL)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
