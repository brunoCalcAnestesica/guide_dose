import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoRanitidina {
  static const String nome = 'Ranitidina';
  static const String idBulario = 'ranitidina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ranitidina.json');
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
      conteudo: _buildCardRanitidina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardRanitidina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRanitidina._textoObs('Antagonista dos receptores H2 da histamina - Antissecretor gástrico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRanitidina._linhaPreparo('Comprimidos 150mg, 300mg', 'Uso oral'),
        MedicamentoRanitidina._linhaPreparo('Solução oral 15mg/mL', 'Frasco 120mL'),
        MedicamentoRanitidina._linhaPreparo('Ampola 50mg/2mL (25mg/mL)', 'Uso IV/IM'),
        MedicamentoRanitidina._linhaPreparo('Frasco-ampola 50mg/5mL (10mg/mL)', 'Uso IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRanitidina._linhaPreparo('50mg em 20mL SF 0,9%', '2,5 mg/mL para bolus lento'),
        MedicamentoRanitidina._linhaPreparo('50mg em 100mL SF 0,9% ou SG 5%', 'Infusão intermitente 15-20 min'),
        MedicamentoRanitidina._linhaPreparo('150mg em 250mL SF 0,9%', '0,6 mg/mL para infusão contínua'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoRanitidina._linhaIndicacaoDoseFixa(
            titulo: 'Úlcera péptica ativa',
            descricaoDose: '150mg VO 2x/dia ou 300mg VO à noite por 4-8 semanas',
            doseFixa: '150-300 mg/dia',
          ),
          MedicamentoRanitidina._linhaIndicacaoDoseFixa(
            titulo: 'DRGE (esofagite de refluxo)',
            descricaoDose: '150mg VO 2x/dia ou 300mg VO 2x/dia',
            doseFixa: '150-300 mg 2x/dia',
          ),
          MedicamentoRanitidina._linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia úlcera estresse (UTI)',
            descricaoDose: '50mg IV a cada 6-8h ou infusão 6,25mg/h contínua',
            doseFixa: '50 mg IV 6-8h',
          ),
          MedicamentoRanitidina._linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia aspiração (pré-anestesia)',
            descricaoDose: '50mg IV 45-60 min antes indução anestésica',
            doseFixa: '50 mg IV',
          ),
          MedicamentoRanitidina._linhaIndicacaoDoseFixa(
            titulo: 'Síndrome de Zollinger-Ellison',
            descricaoDose: '150mg VO 3x/dia (até 6g/dia casos graves)',
            doseFixa: '150 mg 3x/dia',
          ),
        ] else ...[
          MedicamentoRanitidina._linhaIndicacaoDoseCalculada(
            titulo: 'Úlcera péptica pediátrica',
            descricaoDose: '4-8 mg/kg/dia VO dividido 12/12h (máx 300mg/dia)',
            unidade: 'mg/dia',
            dosePorKgMinima: 4.0,
            dosePorKgMaxima: 8.0,
            doseMaxima: 300,
            peso: peso,
          ),
          MedicamentoRanitidina._linhaIndicacaoDoseCalculada(
            titulo: 'DRGE pediátrica',
            descricaoDose: '2-4 mg/kg/dia VO dividido 12/12h',
            unidade: 'mg/dia',
            dosePorKgMinima: 2.0,
            dosePorKgMaxima: 4.0,
            doseMaxima: 300,
            peso: peso,
          ),
          MedicamentoRanitidina._linhaIndicacaoDoseCalculada(
            titulo: 'Profilaxia estresse pediátrica (IV)',
            descricaoDose: '2-4 mg/kg/dia IV dividido 6-8h (máx 200mg/dia)',
            unidade: 'mg/dia',
            dosePorKgMinima: 2.0,
            dosePorKgMaxima: 4.0,
            doseMaxima: 200,
            peso: peso,
          ),
          MedicamentoRanitidina._linhaIndicacaoDoseCalculada(
            titulo: 'Neonatos',
            descricaoDose: '2 mg/kg/dia IV dividido 12/12h',
            unidade: 'mg/dia',
            dosePorKg: 2.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoRanitidina._textoObs('Antagonista H2 - reduz secreção ácida gástrica 70-90%'),
        MedicamentoRanitidina._textoObs('Potência 4-10x maior que cimetidina, menos interações'),
        MedicamentoRanitidina._textoObs('ATENÇÃO: Administrar IV lento (≥5 min bolus) - risco bradicardia'),
        MedicamentoRanitidina._textoObs('Ajustar dose insuficiência renal: ClCr <50 reduzir 50%'),
        MedicamentoRanitidina._textoObs('Idosos: risco confusão mental (monitorar, reduzir dose)'),
        MedicamentoRanitidina._textoObs('Menos eficaz que IBPs - preferir IBPs em HDA ativa'),
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
