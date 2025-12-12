import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTorasemida {
  static const String nome = 'Torasemida';
  static const String idBulario = 'torasemida';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/torasemida.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardTorasemida(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardTorasemida(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTorasemida._textoObs('• Diurético de alça - Derivado sulfoniluréia - Inibidor Na+/K+/2Cl−'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTorasemida._linhaPreparo('Ampola 10mg/2mL (5mg/mL)', 'Diuver® / Demadex®'),
        MedicamentoTorasemida._linhaPreparo('Início: 10 min IV', 'Ação rápida'),
        MedicamentoTorasemida._linhaPreparo('Pico: 1-2h | Duração: 6-8h', 'Efeito prolongado vs furosemida'),
        MedicamentoTorasemida._linhaPreparo('Meia-vida: 3-4 horas', 'Metabolismo hepático'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTorasemida._linhaPreparo('IV bolus: usar direto da ampola', 'Administrar lento 2-5 min'),
        MedicamentoTorasemida._linhaPreparo('IV infusão: 10mg em 50-100mL SF', 'Infundir em 10-20 min'),
        MedicamentoTorasemida._linhaPreparo('Compatível: SF 0,9%, SG 5%', 'Via periférica ou central'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoTorasemida._linhaIndicacaoDoseFixa(
            titulo: 'Edema (ICC, renal, hepático)',
            descricaoDose: '10-20mg IV 1x/dia (pode escalar até 200mg conforme resposta)',
            doseFixa: '10-20 mg',
          ),
          MedicamentoTorasemida._linhaIndicacaoDoseFixa(
            titulo: 'Edema agudo de pulmão',
            descricaoDose: '10-20mg IV bolus lento (repetir ou aumentar conforme necessidade)',
            doseFixa: '10-20 mg',
          ),
          MedicamentoTorasemida._linhaIndicacaoDoseFixa(
            titulo: 'Ascite / Síndrome nefrótica',
            descricaoDose: '20-100mg IV 1x/dia (titular conforme resposta)',
            doseFixa: '20-100 mg',
          ),
        ] else ...[
          MedicamentoTorasemida._linhaIndicacaoDoseCalculada(
            titulo: 'Uso pediátrico (off-label - dados limitados)',
            descricaoDose: '0,1-0,2 mg/kg/dose IV a cada 12-24h (máx 10mg/dia)',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.2,
            doseMaxima: 10.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTorasemida._textoObs('• Inibe Na+/K+/2Cl− alça de Henle - natriurese, diurese intensa'),
        MedicamentoTorasemida._textoObs('• Vantagens vs furosemida: biodisponibilidade oral alta (80-100%), duração 6-8h, menor hipocalemia'),
        MedicamentoTorasemida._textoObs('• Leve efeito anti-aldosterona + venodilatação (reduz pré-carga)'),
        MedicamentoTorasemida._textoObs('• Indicação principal: ICC com edema, edema renal/hepático, HAS'),
        MedicamentoTorasemida._textoObs('• ATENÇÃO: Hipocalemia (K+), hiponatremia (Na+), hipomagnesemia (Mg2+)'),
        MedicamentoTorasemida._textoObs('• ATENÇÃO: Hipovolemia - hipotensão postural, tontura, IR pré-renal'),
        MedicamentoTorasemida._textoObs('• ATENÇÃO: Hiperuricemia (gota), hipocalcemia (Ca2+)'),
        MedicamentoTorasemida._textoObs('• Monitorar: eletrólitos (K+, Na+, Mg2+, Ca2+), creatinina, ureia, PA, balanço hídrico'),
        MedicamentoTorasemida._textoObs('• Contraindicado: anúria, hipovolemia severa, hipocalemia/hiponatremia grave, coma hepático'),
        MedicamentoTorasemida._textoObs('• Interações: digitálicos (arritmia), aminoglicosídeos (nefrotoxicidade), lítio (toxicidade)'),
        MedicamentoTorasemida._textoObs('• AINEs reduzem efeito diurético - evitar associação'),
        MedicamentoTorasemida._textoObs('• Ototoxicidade rara (menos que furosemida) - dose-dependente'),
        MedicamentoTorasemida._textoObs('• Uso pediátrico off-label - dados limitados, cautela'),
        MedicamentoTorasemida._textoObs('• Hepatopatas: risco hipovolemia, encefalopatia (usar cautela)'),
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
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade (máx ${doseMaxima?.toStringAsFixed(0)} $unidade)';
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
        texto,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
