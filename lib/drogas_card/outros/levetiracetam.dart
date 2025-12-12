import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoLevetiracetam {
  static const String nome = 'Levetiracetam';
  static const String idBulario = 'levetiracetam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/levetiracetam.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Levetiracetam tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardLevetiracetam(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardLevetiracetam(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLevetiracetam._textoObs(
            'Anticonvulsivante - Agente antiepiléptico de amplo espectro'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLevetiracetam._linhaPreparo(
            'Ampola 100mg/mL (5mL = 500mg)', ''),
        MedicamentoLevetiracetam._linhaPreparo(
            'Comprimido 250mg, 500mg, 750mg, 1000mg', ''),
        MedicamentoLevetiracetam._linhaPreparo('Solução oral 100mg/mL', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLevetiracetam._linhaPreparo(
            'Via IV', 'Diluir em 100mL SF 0,9% ou SG 5%'),
        MedicamentoLevetiracetam._linhaPreparo(
            'Tempo de infusão', '15 minutos'),
        MedicamentoLevetiracetam._linhaPreparo(
            'Alternativa', 'Push lento IV em 2-5 minutos sem diluir'),
        MedicamentoLevetiracetam._linhaPreparo(
            'Via oral', 'Comprimido ou solução, com ou sem alimentos'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoLevetiracetam._linhaIndicacaoDoseFixa(
            titulo: 'Status epilepticus (dose de ataque)',
            descricaoDose: '1000-3000mg IV (infusão 15min)',
            doseFixa: '1000-3000 mg',
          ),
          MedicamentoLevetiracetam._linhaIndicacaoDoseFixa(
            titulo: 'Convulsões focais',
            descricaoDose: '1000-2000mg IV',
            doseFixa: '1000-2000 mg',
          ),
          MedicamentoLevetiracetam._linhaIndicacaoDoseFixa(
            titulo: 'Convulsões tônico-clônicas generalizadas',
            descricaoDose: '1000-2000mg IV',
            doseFixa: '1000-2000 mg',
          ),
          MedicamentoLevetiracetam._linhaIndicacaoDoseFixa(
            titulo: 'Manutenção (dose diária)',
            descricaoDose: '500-1500mg VO/IV 2x/dia',
            doseFixa: '1000-3000 mg/dia total',
          ),
        ] else ...[
          MedicamentoLevetiracetam._linhaIndicacaoDoseCalculada(
            titulo: 'Status epilepticus pediátrico (dose de ataque)',
            descricaoDose: '20-60 mg/kg IV (máx 3000mg)',
            unidade: 'mg',
            dosePorKgMinima: 20,
            dosePorKgMaxima: 60,
            peso: peso,
            doseMaxima: 3000,
          ),
          MedicamentoLevetiracetam._linhaIndicacaoDoseCalculada(
            titulo: 'Convulsões febris pediátricas',
            descricaoDose: '20-40 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 20,
            dosePorKgMaxima: 40,
            peso: peso,
          ),
          MedicamentoLevetiracetam._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção pediátrica (dose diária total)',
            descricaoDose: '20-60 mg/kg/dia dividido em 2 doses',
            unidade: 'mg/dia',
            dosePorKgMinima: 20,
            dosePorKgMaxima: 60,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLevetiracetam._textoObs('Início de ação IV: 15-30 minutos'),
        MedicamentoLevetiracetam._textoObs('Pico plasmático oral: 1 hora'),
        MedicamentoLevetiracetam._textoObs(
            'Meia-vida: 6-8 horas (adultos), 5-7h (crianças)'),
        MedicamentoLevetiracetam._textoObs('Biodisponibilidade oral: >95%'),
        MedicamentoLevetiracetam._textoObs(
            'Mecanismo único: liga-se à proteína SV2A'),
        MedicamentoLevetiracetam._textoObs(
            'Modula liberação de neurotransmissores'),
        MedicamentoLevetiracetam._textoObs(
            'NÃO atua em canais iônicos ou GABA'),
        MedicamentoLevetiracetam._textoObs(
            'Metabolização mínima (<24%), não hepática'),
        MedicamentoLevetiracetam._textoObs('Excreção renal: 66% inalterado'),
        MedicamentoLevetiracetam._textoObs('NÃO induz ou inibe enzimas CYP450'),
        MedicamentoLevetiracetam._textoObs('Mínimas interações medicamentosas'),
        MedicamentoLevetiracetam._textoObs(
            'Eficaz em convulsões focais e generalizadas'),
        MedicamentoLevetiracetam._textoObs('Eficaz em convulsões mioclônicas'),
        MedicamentoLevetiracetam._textoObs(
            'Pode ser usado em epilepsia refratária'),
        MedicamentoLevetiracetam._textoObs(
            'NÃO causa depressão do SNC significativa'),
        MedicamentoLevetiracetam._textoObs(
            'Reações comuns: sonolência, fadiga, tontura'),
        MedicamentoLevetiracetam._textoObs(
            'Pode causar irritabilidade, mudanças comportamentais'),
        MedicamentoLevetiracetam._textoObs(
            'Risco de depressão e ideação suicida (monitorar)'),
        MedicamentoLevetiracetam._textoObs('AJUSTE RENAL obrigatório:'),
        MedicamentoLevetiracetam._textoObs('  - ClCr 50-80: reduzir 25%'),
        MedicamentoLevetiracetam._textoObs('  - ClCr 30-50: reduzir 50%'),
        MedicamentoLevetiracetam._textoObs('  - ClCr <30: reduzir 75%'),
        MedicamentoLevetiracetam._textoObs(
            '  - Hemodiálise: suplementar após sessão'),
        MedicamentoLevetiracetam._textoObs('NÃO requer ajuste hepático'),
        MedicamentoLevetiracetam._textoObs(
            'NÃO suspender abruptamente (risco de convulsões)'),
        MedicamentoLevetiracetam._textoObs('Desmame gradual obrigatório'),
        MedicamentoLevetiracetam._textoObs('Monitorar comportamento e humor'),
        MedicamentoLevetiracetam._textoObs(
            'Monitorar frequência de convulsões'),
        MedicamentoLevetiracetam._textoObs(
            'Compatível com SF 0,9%, SG 5%, Ringer Lactato'),
        MedicamentoLevetiracetam._textoObs(
            'Categoria C na gravidez (registrar em vigilância)'),
        MedicamentoLevetiracetam._textoObs(
            'Excreta no leite (avaliar risco/benefício)'),
        MedicamentoLevetiracetam._textoObs(
            'Armazenar em temperatura ambiente (15-30°C)'),
        MedicamentoLevetiracetam._textoObs('Proteger da luz'),
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

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
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
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
