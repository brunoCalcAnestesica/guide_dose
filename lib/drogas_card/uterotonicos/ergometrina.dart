import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoErgometrina {
  static const String nome = 'Ergometrina';
  static const String idBulario = 'ergometrina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/ergometrina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Ergometrina é exclusivamente para uso obstétrico em adultos
    if (!isAdulto) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardErgometrina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardErgometrina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoErgometrina._textoObs('Uterotônico - Alcaloide do ergot'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoErgometrina._linhaPreparo(
            'Ampola 0,2mg/mL (1mL)', 'Ergotrate®, Methergin®'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoErgometrina._linhaPreparo('Via IV',
            'Uso direto ou diluir em 10mL SF 0,9% (infusão lenta mínimo 1min)'),
        MedicamentoErgometrina._linhaPreparo(
            'Via IM', 'Uso direto - administrar profundamente'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoErgometrina._linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia pós-parto (HPP)',
            descricaoDose:
                '0,2mg IM ou IV lento (repetir a cada 2-4h se necessário, máx 5 doses/dia)',
            doseFixa: '0,2 mg (1 mL)',
          ),
          MedicamentoErgometrina._linhaIndicacaoDoseFixa(
            titulo: 'Prevenção da HPP',
            descricaoDose: '0,2mg IM imediatamente após dequitação placentária',
            doseFixa: '0,2 mg (1 mL)',
          ),
          MedicamentoErgometrina._linhaIndicacaoDoseFixa(
            titulo: 'Atonia uterina',
            descricaoDose: '0,2mg IV ou IM',
            doseFixa: '0,2 mg (1 mL)',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoErgometrina._textoObs(
            'Início de ação: 1-2min IV, 2-5min IM'),
        MedicamentoErgometrina._textoObs('Duração do efeito: 2-4 horas'),
        MedicamentoErgometrina._textoObs(
            'Promove contração uterina tetânica do segmento superior'),
        MedicamentoErgometrina._textoObs('Dose máxima: 1mg/dia (5 doses)'),
        MedicamentoErgometrina._textoObs(
            'Monitorar PA, FC e sinais de isquemia rigorosamente'),
        MedicamentoErgometrina._textoObs(
            'Contraindicado em hipertensão não controlada'),
        MedicamentoErgometrina._textoObs(
            'Contraindicado em doença cardíaca isquêmica'),
        MedicamentoErgometrina._textoObs(
            'Usar apenas após dequitação placentária'),
        MedicamentoErgometrina._textoObs(
            'Risco de hipertensão severa e vasoespasmo coronariano'),
        MedicamentoErgometrina._textoObs(
            'Evitar amamentação nas primeiras 12h após uso IV/IM'),
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
