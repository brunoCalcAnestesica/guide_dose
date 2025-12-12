import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSulfatoMagnesio {
  static const String nome = 'Sulfato de Magnésio';
  static const String idBulario = 'sulfato_magnesio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/sulfato_magnesio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    // Sulfato de magnésio tem indicações para todas as faixas etárias
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
      conteudo: _buildCardSulfatoMagnesio(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardSulfatoMagnesio(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSulfatoMagnesio._textoObs('Repositor eletrolítico - Anticonvulsivante, antiarrítmico e tocolítico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSulfatoMagnesio._linhaPreparo('Ampola 10% (100mg/mL) - 10mL', '1g MgSO4'),
        MedicamentoSulfatoMagnesio._linhaPreparo('Ampola 25% (250mg/mL) - 10mL', '2,5g MgSO4'),
        MedicamentoSulfatoMagnesio._linhaPreparo('Início: 1-5 min | Pico: 5-30 min', 'Rápido'),
        MedicamentoSulfatoMagnesio._linhaPreparo('Duração: 30 min - 6h', 'Conforme função renal'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSulfatoMagnesio._linhaPreparo('Bolus: diluir em SF 0,9% ou SG 5%', 'Ex: 2g em 100mL'),
        MedicamentoSulfatoMagnesio._linhaPreparo('Infusão: 4-6g em 250mL SF/SG', 'Bomba infusão'),
        MedicamentoSulfatoMagnesio._linhaPreparo('Administrar IV lento: 15-30 min', 'NUNCA bolus rápido'),
        MedicamentoSulfatoMagnesio._linhaPreparo('Incompatível: cálcio, fosfato, bicarbonato', 'Risco precipitação'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSulfatoMagnesio._linhaIndicacaoDoseFixa(
            titulo: 'Eclâmpsia - ataque',
            descricaoDose: '4-6g IV em 20-30 min',
            doseFixa: '4-6g',
          ),
          MedicamentoSulfatoMagnesio._linhaIndicacaoDoseFixa(
            titulo: 'Torsades de Pointes',
            descricaoDose: '2g IV em 10 min',
            doseFixa: '2g',
          ),
          MedicamentoSulfatoMagnesio._linhaIndicacaoDoseFixa(
            titulo: 'Hipomagnesemia severa',
            descricaoDose: '1-2g IV em 15-30 min (repetir se necessário)',
            doseFixa: '1-2g',
          ),
          MedicamentoSulfatoMagnesio._linhaIndicacaoDoseFixa(
            titulo: 'Asma grave refratária',
            descricaoDose: '2-4g IV em 15-20 min (dose única)',
            doseFixa: '2-4g',
          ),
        ] else ...[
          MedicamentoSulfatoMagnesio._linhaIndicacaoDoseCalculada(
            titulo: 'Torsades/Hipomagnesemia pediátrica',
            descricaoDose: '25-50 mg/kg IV em 10-20 min (máx 2g)',
            unidade: 'mg',
            dosePorKgMinima: 25.0,
            dosePorKgMaxima: 50.0,
            doseMaxima: 2000,
            peso: peso,
          ),
          MedicamentoSulfatoMagnesio._linhaIndicacaoDoseCalculada(
            titulo: 'Asma grave pediátrica',
            descricaoDose: '25-50 mg/kg IV em 20 min (máx 2g)',
            unidade: 'mg',
            dosePorKgMinima: 25.0,
            dosePorKgMaxima: 50.0,
            doseMaxima: 2000,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSulfatoMagnesio._textoObs('Indicação: Manutenção eclâmpsia/pré-eclâmpsia'),
        if (isAdulto) ...[
          MedicamentoSulfatoMagnesio._linhaPreparo('Dose: 1-2 g/h IV contínua', 'Após ataque 4-6g'),
          MedicamentoSulfatoMagnesio._linhaPreparo('Preparo: 4-6g em 250mL SF/SG', 'Bomba infusão'),
          MedicamentoSulfatoMagnesio._linhaPreparo('Exemplos:', ''),
          MedicamentoSulfatoMagnesio._linhaPreparo('  • 1g/h: 4g/250mL = 62,5 mL/h', ''),
          MedicamentoSulfatoMagnesio._linhaPreparo('  • 2g/h: 4g/250mL = 125 mL/h', ''),
        ] else ...[
          MedicamentoSulfatoMagnesio._linhaPreparo('Pediátrico: não utilizado rotineiramente', 'Doses repetidas conforme necessidade'),
        ],
        MedicamentoSulfatoMagnesio._linhaPreparo('Monitorar: reflexos, FR >16, diurese >25mL/h', 'ECG contínuo'),
        MedicamentoSulfatoMagnesio._linhaPreparo('Suspender: perda reflexos, FR <12, diurese <25mL/h', 'Sinais toxicidade'),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSulfatoMagnesio._textoObs('Antagonista fisiológico cálcio - bloqueia canais Ca2+ voltagem-dependentes'),
        MedicamentoSulfatoMagnesio._textoObs('Estabiliza membranas neuronais e cardíacas'),
        MedicamentoSulfatoMagnesio._textoObs('Depressor SNC - propriedades anticonvulsivantes'),
        MedicamentoSulfatoMagnesio._textoObs('Relaxamento musculatura lisa - vasodilatação, broncodilatação, tocolítico'),
        MedicamentoSulfatoMagnesio._textoObs('ATENÇÃO: Monitorar reflexos tendinosos profundos (sinal precoce toxicidade)'),
        MedicamentoSulfatoMagnesio._textoObs('ATENÇÃO: Monitorar FR (>16 irpm) e diurese (>25 mL/h)'),
        MedicamentoSulfatoMagnesio._textoObs('ATENÇÃO: Ajustar dose em insuficiência renal (risco hipermagnesemia)'),
        MedicamentoSulfatoMagnesio._textoObs('ANTÍDOTO: Gluconato cálcio 1g IV em 10 min (toxicidade)'),
        MedicamentoSulfatoMagnesio._textoObs('Sinais toxicidade: perda reflexos, sonolência, bradicardia, hipotensão, bradipneia'),
        MedicamentoSulfatoMagnesio._textoObs('Potencializa bloqueio neuromuscular (rocurônio, cisatracúrio)'),
        MedicamentoSulfatoMagnesio._textoObs('Potencializa depressão respiratória (opioides, benzodiazepínicos)'),
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
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
