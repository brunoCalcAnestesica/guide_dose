import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoOmeprazol {
  static const String nome = 'Omeprazol';
  static const String idBulario = 'omeprazol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/omeprazol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardOmeprazol(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardOmeprazol(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOmeprazol._textoObs('Inibidor da Bomba de Prótons (IBP)'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOmeprazol._linhaPreparo('Cápsulas 10mg, 20mg, 40mg', 'Uso oral'),
        MedicamentoOmeprazol._linhaPreparo('Comprimidos 20mg', 'Uso oral'),
        MedicamentoOmeprazol._linhaPreparo('Frasco-ampola 40mg', 'Pó liofilizado para IV'),
        MedicamentoOmeprazol._linhaPreparo('Solução injetável 40mg/10mL', 'Uso IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOmeprazol._linhaPreparo('40mg em 100mL SF 0,9% ou SG 5%', 'Infundir em 15-30 min'),
        MedicamentoOmeprazol._linhaPreparo('80mg em 100mL SF 0,9%', 'Para hemorragia digestiva'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOmeprazol._textoObs('IBP de escolha para úlcera péptica e DRGE'),
        MedicamentoOmeprazol._textoObs('Protocolo HDA: 80mg IV bolus + 8mg/h por 72h'),
        MedicamentoOmeprazol._textoObs('Monitorar magnésio sérico em uso prolongado (>3 meses)'),
        MedicamentoOmeprazol._textoObs('Risco de fraturas ósseas com uso prolongado (>1 ano)'),
        MedicamentoOmeprazol._textoObs('Reduz eficácia do clopidogrel - preferir pantoprazol'),
        MedicamentoOmeprazol._textoObs('Administrar 30 minutos antes das refeições'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
        indicacoes.addAll([
          MedicamentoOmeprazol._linhaIndicacaoDoseCalculada(
            titulo: 'Esofagite de refluxo',
            descricaoDose: '0,5-1 mg/kg/dia IV/VO',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseCalculada(
            titulo: 'Úlceras de estresse',
            descricaoDose: '0,5-1 mg/kg/dia IV',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
        ]);
        break;
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoOmeprazol._linhaIndicacaoDoseCalculada(
            titulo: 'Esofagite de refluxo',
            descricaoDose: '0,7-1,4 mg/kg/dia (máx 40mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.7,
            dosePorKgMaxima: 1.4,
            doseMaxima: 40.0,
            peso: peso,
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseCalculada(
            titulo: 'Úlcera péptica',
            descricaoDose: '0,7-1,4 mg/kg/dia (máx 40mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.7,
            dosePorKgMaxima: 1.4,
            doseMaxima: 40.0,
            peso: peso,
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseCalculada(
            titulo: 'H. pylori (com antibióticos)',
            descricaoDose: '0,7-1 mg/kg 2x/dia por 7-14 dias',
            unidade: 'mg',
            dosePorKgMinima: 0.7,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
        ]);
        break;
      case 'Adolescente':
        indicacoes.addAll([
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Úlcera péptica',
            descricaoDose: '20-40mg/dia VO ou IV',
            doseFixa: '20-40 mg',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Esofagite de refluxo',
            descricaoDose: '20-40mg/dia VO ou IV',
            doseFixa: '20-40 mg',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'H. pylori',
            descricaoDose: '20mg 2x/dia + antibióticos por 7-14 dias',
            doseFixa: '20 mg 2x/dia',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia digestiva',
            descricaoDose: '80mg IV bolus + 8mg/h por 72h',
            doseFixa: '80 mg bolus',
          ),
        ]);
        break;
      case 'Adulto':
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Úlcera péptica gástrica/duodenal',
            descricaoDose: '20-40mg/dia VO ou IV',
            doseFixa: '20-40 mg',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Esofagite de refluxo (DRGE)',
            descricaoDose: '20-40mg/dia VO ou IV',
            doseFixa: '20-40 mg',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Síndrome de Zollinger-Ellison',
            descricaoDose: '60-120mg/dia VO (dividir em 2-3 doses)',
            doseFixa: '60-120 mg',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'H. pylori (terapia tripla)',
            descricaoDose: '20mg 2x/dia + amoxicilina + claritromicina',
            doseFixa: '20 mg 2x/dia',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia digestiva alta',
            descricaoDose: '80mg IV bolus + 8mg/h infusão por 72h',
            doseFixa: '80 mg bolus',
          ),
          MedicamentoOmeprazol._linhaIndicacaoDoseFixa(
            titulo: 'Prevenção úlcera por AINEs',
            descricaoDose: '20-40mg/dia VO',
            doseFixa: '20-40 mg',
          ),
        ]);
        break;
    }

    return indicacoes;
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
