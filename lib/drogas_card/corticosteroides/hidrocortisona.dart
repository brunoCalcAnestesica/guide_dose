import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoHidrocortisona {
  static const String nome = 'Hidrocortisona';
  static const String idBulario = 'hidrocortisona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/hidrocortisona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Hidrocortisona tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHidrocortisona(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardHidrocortisona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidrocortisona._textoObs(
            'Corticosteroide sistêmico - Glicocorticoide de curta duração'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidrocortisona._linhaPreparo(
            'Frasco-ampola 100mg liofilizado', ''),
        MedicamentoHidrocortisona._linhaPreparo(
            'Frasco-ampola 500mg liofilizado', ''),
        MedicamentoHidrocortisona._linhaPreparo(
            'Frasco-ampola 1g liofilizado', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidrocortisona._linhaPreparo(
            'Reconstituir 100mg', 'Adicionar 2mL do diluente fornecido'),
        MedicamentoHidrocortisona._linhaPreparo(
            'Reconstituir 500mg', 'Adicionar 5mL do diluente fornecido'),
        MedicamentoHidrocortisona._linhaPreparo(
            'Bolus IV', 'Usar direto ou diluir em 10-20mL SF 0,9% (2-5 min)'),
        MedicamentoHidrocortisona._linhaPreparo(
            'Infusão IV', 'Diluir em 100-250mL SF 0,9% ou SG 5%'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoHidrocortisona._linhaIndicacaoDoseFixa(
            titulo: 'Crise adrenal aguda (dose de ataque)',
            descricaoDose: '100mg IV em bolus',
            doseFixa: '100 mg',
          ),
          MedicamentoHidrocortisona._linhaIndicacaoDoseFixa(
            titulo: 'Manutenção crise adrenal',
            descricaoDose: '50-100mg IV a cada 6-8h',
            doseFixa: '50-100 mg',
          ),
          MedicamentoHidrocortisona._linhaIndicacaoDoseFixa(
            titulo: 'Choque séptico com insuficiência adrenal',
            descricaoDose: '50mg IV a cada 6h (200mg/dia)',
            doseFixa: '50 mg',
          ),
          MedicamentoHidrocortisona._linhaIndicacaoDoseFixa(
            titulo: 'Anafilaxia',
            descricaoDose: '100-500mg IV',
            doseFixa: '100-500 mg',
          ),
          MedicamentoHidrocortisona._linhaIndicacaoDoseFixa(
            titulo: 'Asma grave/DPOC aguda',
            descricaoDose: '100-200mg IV a cada 6h',
            doseFixa: '100-200 mg',
          ),
        ] else ...[
          MedicamentoHidrocortisona._linhaIndicacaoDoseCalculada(
            titulo: 'Crise adrenal pediátrica',
            descricaoDose: '1-2mg/kg/dose IV a cada 6h',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
          ),
          MedicamentoHidrocortisona._linhaIndicacaoDoseCalculada(
            titulo: 'Anafilaxia pediátrica',
            descricaoDose: '1-2mg/kg IV (máx 100mg)',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
            doseMaxima: 100,
          ),
          MedicamentoHidrocortisona._linhaIndicacaoDoseCalculada(
            titulo: 'Crupe',
            descricaoDose: '1mg/kg IV',
            unidade: 'mg',
            dosePorKg: 1,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidrocortisona._textoObs(
            'Início de ação: minutos (choque adrenal)'),
        MedicamentoHidrocortisona._textoObs('Efeito anti-inflamatório: 1 hora'),
        MedicamentoHidrocortisona._textoObs('Pico: 1-2 horas'),
        MedicamentoHidrocortisona._textoObs(
            'Meia-vida plasmática: 1,5-2 horas'),
        MedicamentoHidrocortisona._textoObs('Meia-vida biológica: 8-12 horas'),
        MedicamentoHidrocortisona._textoObs(
            'Glicocorticoide + leve efeito mineralocorticoide'),
        MedicamentoHidrocortisona._textoObs('Modula transcrição gênica'),
        MedicamentoHidrocortisona._textoObs(
            'Inibe citocinas pró-inflamatórias (TNF-α, IL-1, IL-6)'),
        MedicamentoHidrocortisona._textoObs('Estabiliza membranas lisossomais'),
        MedicamentoHidrocortisona._textoObs(
            'Potência equivalente ao cortisol endógeno'),
        MedicamentoHidrocortisona._textoObs(
            'Administrar bolus lento (2-5 minutos)'),
        MedicamentoHidrocortisona._textoObs('Dose máxima adultos: 1,5-2g/dia'),
        MedicamentoHidrocortisona._textoObs(
            'Dose máxima pediátrica: 240mg/m²/dia'),
        MedicamentoHidrocortisona._textoObs(
            'Monitorar glicemia (risco de hiperglicemia)'),
        MedicamentoHidrocortisona._textoObs('Monitorar eletrólitos (K+, Na+)'),
        MedicamentoHidrocortisona._textoObs('Monitorar PA (retenção de sódio)'),
        MedicamentoHidrocortisona._textoObs('RISCO: hiperglicemia'),
        MedicamentoHidrocortisona._textoObs('RISCO: hipocalemia'),
        MedicamentoHidrocortisona._textoObs('RISCO: retenção de sódio e edema'),
        MedicamentoHidrocortisona._textoObs('RISCO: hipertensão'),
        MedicamentoHidrocortisona._textoObs(
            'RISCO: supressão adrenal (uso prolongado)'),
        MedicamentoHidrocortisona._textoObs(
            'Após reconstituição: usar em 4h (ambiente) ou 24h (refrigerado)'),
        MedicamentoHidrocortisona._textoObs(
            'Potencializa hipocalemia com diuréticos'),
        MedicamentoHidrocortisona._textoObs(
            'Aumenta glicemia (ajustar antidiabéticos)'),
        MedicamentoHidrocortisona._textoObs('Risco gastrointestinal com AINEs'),
        MedicamentoHidrocortisona._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoHidrocortisona._textoObs(
            'Contraindicado em infecção fúngica sistêmica'),
        MedicamentoHidrocortisona._textoObs(
            'Contraindicado com vacinas de vírus vivos'),
        MedicamentoHidrocortisona._textoObs('Categoria C na gravidez'),
        MedicamentoHidrocortisona._textoObs('Seguro na lactação (uso curto)'),
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
