import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFurosemida {
  static const String nome = 'Furosemida';
  static const String idBulario = 'furosemida';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/furosemida.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Furosemida tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardFurosemida(
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

    return _buildCardFurosemida(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardFurosemida(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFurosemida._textoObs(
            'Diurético de alça - Derivado da sulfonamida'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFurosemida._linhaPreparo('Ampola 20mg/2mL (10mg/mL)', ''),
        MedicamentoFurosemida._linhaPreparo('Comprimido 40mg', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFurosemida._linhaPreparo(
            'Bolus IV', 'Usar direto da ampola em 2-5 minutos'),
        MedicamentoFurosemida._linhaPreparo(
            'Infusão IV', '40mg (2 amp) em 50-100mL SF 0,9% ou SG 5%'),
        MedicamentoFurosemida._linhaPreparo(
            'Tempo de infusão', '10-20 minutos'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoFurosemida._linhaIndicacaoDoseFixa(
            titulo: 'Edema (dose inicial)',
            descricaoDose: '20-40mg IV em bolus lento',
            doseFixa: '20-40 mg',
          ),
          MedicamentoFurosemida._linhaIndicacaoDoseFixa(
            titulo: 'Edema agudo de pulmão',
            descricaoDose: '40-80mg IV em bolus',
            doseFixa: '40-80 mg',
          ),
          MedicamentoFurosemida._linhaIndicacaoDoseFixa(
            titulo: 'Crise hipertensiva',
            descricaoDose: '20-40mg IV (associado a outros anti-hipertensivos)',
            doseFixa: '20-40 mg',
          ),
          MedicamentoFurosemida._linhaIndicacaoDoseFixa(
            titulo: 'Hipercalcemia',
            descricaoDose: '80-100mg IV (associado a hidratação vigorosa)',
            doseFixa: '80-100 mg',
          ),
        ] else ...[
          MedicamentoFurosemida._linhaIndicacaoDoseCalculada(
            titulo: 'Edema pediátrico',
            descricaoDose: '1-2mg/kg/dose IV ou VO (a cada 6-12h)',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
            doseMaxima: 120,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFurosemida._textoObs('Início de ação IV: 5 minutos'),
        MedicamentoFurosemida._textoObs('Pico de efeito IV: 30 minutos'),
        MedicamentoFurosemida._textoObs('Duração IV: 2 horas'),
        MedicamentoFurosemida._textoObs('Meia-vida: 1-2 horas'),
        MedicamentoFurosemida._textoObs(
            'Inibe cotransportador Na+/K+/2Cl- na alça de Henle'),
        MedicamentoFurosemida._textoObs('Promove vasodilatação venosa precoce'),
        MedicamentoFurosemida._textoObs(
            'Reduz pré-carga antes do efeito diurético'),
        MedicamentoFurosemida._textoObs(
            'Eficaz mesmo com função renal reduzida'),
        MedicamentoFurosemida._textoObs(
            'Doses maiores necessárias em insuficiência renal'),
        MedicamentoFurosemida._textoObs(
            'Administrar bolus LENTO (2-5 minutos)'),
        MedicamentoFurosemida._textoObs('Infusão recomendada para doses >80mg'),
        MedicamentoFurosemida._textoObs('Dose máxima adultos: 600mg/dia'),
        MedicamentoFurosemida._textoObs('Dose máxima pediátrica: 6mg/kg/dia'),
        MedicamentoFurosemida._textoObs('Monitorar PA, FC, balanço hídrico'),
        MedicamentoFurosemida._textoObs(
            'Monitorar eletrólitos: K+, Na+, Mg2+, Ca2+'),
        MedicamentoFurosemida._textoObs(
            'Monitorar função renal (ureia, creatinina)'),
        MedicamentoFurosemida._textoObs('RISCO: hipocalemia (principal)'),
        MedicamentoFurosemida._textoObs('RISCO: hiponatremia'),
        MedicamentoFurosemida._textoObs('RISCO: hipomagnesemia'),
        MedicamentoFurosemida._textoObs('RISCO: hipocalcemia'),
        MedicamentoFurosemida._textoObs('RISCO: hipovolemia e hipotensão'),
        MedicamentoFurosemida._textoObs(
            'RISCO: ototoxicidade (infusão rápida ou altas doses)'),
        MedicamentoFurosemida._textoObs(
            'Potencializa hipocalemia com digitálicos'),
        MedicamentoFurosemida._textoObs(
            'Aumenta nefrotoxicidade com aminoglicosídeos'),
        MedicamentoFurosemida._textoObs('Aumenta toxicidade do lítio'),
        MedicamentoFurosemida._textoObs(
            'Suplementar K+ e/ou Mg2+ conforme necessidade'),
        MedicamentoFurosemida._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoFurosemida._textoObs('Contraindicado em anúria'),
        MedicamentoFurosemida._textoObs('Contraindicado em hipovolemia severa'),
        MedicamentoFurosemida._textoObs(
            'Contraindicado em hipocalemia severa não corrigida'),
        MedicamentoFurosemida._textoObs(
            'Cautela em hepatopatia (risco de encefalopatia)'),
        MedicamentoFurosemida._textoObs('Categoria C na gravidez'),
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

    // Se a unidade contém "/kg", não multiplicamos pelo peso (a dose já é por kg)
    bool isDosePorKg = unidade?.contains('/kg') ?? false;

    if (dosePorKg != null) {
      if (isDosePorKg) {
        // Para doses do tipo mg/kg/h, mostramos apenas o valor
        textoDose = '${dosePorKg.toStringAsFixed(1)} $unidade';
      } else {
        // Para doses totais (mg), calculamos multiplicando pelo peso
        doseCalculada = dosePorKg * peso;
        if (doseMaxima != null && doseCalculada > doseMaxima) {
          doseCalculada = doseMaxima;
        }
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      if (isDosePorKg) {
        // Para doses do tipo mg/kg/h, mostramos apenas o intervalo
        textoDose =
            '${dosePorKgMinima.toStringAsFixed(1)}–${dosePorKgMaxima.toStringAsFixed(1)} $unidade';
      } else {
        // Para doses totais, calculamos multiplicando pelo peso
        double doseMin = dosePorKgMinima * peso;
        double doseMax = dosePorKgMaxima * peso;
        if (doseMaxima != null) {
          doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
        }
        textoDose =
            '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
