import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMetilprednisolona {
  static const String nome = 'Metilprednisolona';
  static const String idBulario = 'metilprednisolona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle
        .loadString('assets/medicamentos/metilprednisolona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Metilprednisolona tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMetilprednisolona(
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

    return _buildCardMetilprednisolona(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardMetilprednisolona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetilprednisolona._textoObs(
            'Glicocorticoide sintético - Anti-inflamatório esteroidal - Imunossupressor'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Frasco-ampola 40mg (liofilizado)', ''),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Frasco-ampola 125mg (liofilizado)', ''),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Frasco-ampola 500mg (liofilizado)', ''),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Frasco-ampola 1000mg (liofilizado)', ''),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Comprimido 4mg, 16mg, 32mg', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Reconstituir', 'Com diluente fornecido ou água destilada'),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Para infusão', 'Diluir em 50-250mL SF 0,9% ou SG 5%'),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Tempo de infusão', '30-60 minutos (doses altas)'),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Bolus', '3-5 minutos (doses moderadas)'),
        MedicamentoMetilprednisolona._linhaPreparo(
            'Via oral', 'Comprimido com alimentos'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoMetilprednisolona._linhaIndicacaoDoseFixa(
            titulo: 'Pulse therapy (doenças autoimunes)',
            descricaoDose: '500-1000mg IV/dia por 3-5 dias',
            doseFixa: '500-1000 mg/dia',
          ),
          MedicamentoMetilprednisolona._linhaIndicacaoDoseFixa(
            titulo: 'Edema cerebral',
            descricaoDose: '40-80mg IV a cada 6-8h',
            doseFixa: '40-80 mg',
          ),
          MedicamentoMetilprednisolona._linhaIndicacaoDoseFixa(
            titulo: 'Reação alérgica grave/anafilaxia',
            descricaoDose: '125-250mg IV',
            doseFixa: '125-250 mg',
          ),
          MedicamentoMetilprednisolona._linhaIndicacaoDoseFixa(
            titulo: 'Asma grave/exacerbação de DPOC',
            descricaoDose: '40-125mg IV a cada 6h',
            doseFixa: '40-125 mg',
          ),
          MedicamentoMetilprednisolona._linhaIndicacaoDoseFixa(
            titulo: 'Rejeição aguda de transplante',
            descricaoDose: '500-1000mg IV/dia por 3 dias',
            doseFixa: '500-1000 mg/dia',
          ),
          MedicamentoMetilprednisolona._linhaIndicacaoDoseFixa(
            titulo: 'Trauma raquimedular (controverso)',
            descricaoDose: '30 mg/kg IV em bolus + 5,4 mg/kg/h por 23h',
            doseFixa: '30 mg/kg bolus',
          ),
        ] else ...[
          MedicamentoMetilprednisolona._linhaIndicacaoDoseCalculada(
            titulo: 'Status asmático pediátrico',
            descricaoDose: '1-2 mg/kg IV a cada 6h (máx 125mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
            doseMaxima: 125,
          ),
          MedicamentoMetilprednisolona._linhaIndicacaoDoseCalculada(
            titulo: 'Reação alérgica grave pediátrica',
            descricaoDose: '1-2 mg/kg IV (máx 125mg)',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
            doseMaxima: 125,
          ),
          MedicamentoMetilprednisolona._linhaIndicacaoDoseCalculada(
            titulo: 'Anti-inflamatório pediátrico',
            descricaoDose: '0,5-1 mg/kg/dia VO/IV',
            unidade: 'mg/dia',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
        ],
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
