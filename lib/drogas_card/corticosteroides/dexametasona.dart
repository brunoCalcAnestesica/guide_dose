import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDexametasona {
  static const String nome = 'Dexametasona';
  static const String idBulario = 'dexametasona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/dexametasona.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Dexametasona tem indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardDexametasona(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardDexametasona(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexametasona._textoObs('Corticosteroide sintético'),
        MedicamentoDexametasona._textoObs('Ação anti-inflamatória potente'),
        MedicamentoDexametasona._textoObs('Baixa atividade mineralocorticoide'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexametasona._linhaPreparo('Ampola 4mg/mL (1mL)', 'Via IV/IM'),
        MedicamentoDexametasona._linhaPreparo('Ampola 8mg/mL (1mL)', 'Via IV/IM'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexametasona._linhaPreparo('Diluir em SF 0,9%', 'Para infusão IV'),
        MedicamentoDexametasona._linhaPreparo('Administrar em 15–30 min', 'Infusão lenta'),
        MedicamentoDexametasona._linhaPreparo('Compatível com SF e SG', 'Não misturar com outros medicamentos'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexametasona._textoObs('Contraindicação: infecções sistêmicas não tratadas'),
        MedicamentoDexametasona._textoObs('Monitorar glicemia (hiperglicemia)'),
        MedicamentoDexametasona._textoObs('Risco de supressão adrenal com uso prolongado'),
        MedicamentoDexametasona._textoObs('Evitar uso em gestantes (categoria C)'),
        MedicamentoDexametasona._textoObs('Monitorar pressão arterial'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '0,1–0,2 mg/kg IV a cada 6–8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Síndrome do desconforto respiratório',
          descricaoDose: '0,5 mg/kg IV a cada 12h por 3 dias',
          unidade: 'mg',
          dosePorKg: 0.5,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de náusea e vômitos',
          descricaoDose: '0,1–0,2 mg/kg IV (dose única)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '0,1–0,2 mg/kg IV a cada 6–8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Bronquiolite grave',
          descricaoDose: '0,6 mg/kg/dia IV em 2–3 doses',
          unidade: 'mg',
          dosePorKg: 0.6,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de náusea e vômitos',
          descricaoDose: '0,1–0,2 mg/kg IV (dose única)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '0,1–0,2 mg/kg IV a cada 6–8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Asma grave',
          descricaoDose: '0,3–0,6 mg/kg/dia IV em 2–3 doses',
          unidade: 'mg',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.6,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Laringite (crup)',
          descricaoDose: '0,6 mg/kg IM (dose única)',
          unidade: 'mg',
          dosePorKg: 0.6,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de náusea e vômitos',
          descricaoDose: '0,1–0,2 mg/kg IV (dose única)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '4–8 mg IV a cada 6–8h',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Asma grave',
          descricaoDose: '0,3–0,6 mg/kg/dia IV em 2–3 doses',
          unidade: 'mg',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.6,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Reação alérgica grave',
          descricaoDose: '4–8 mg IV (dose única)',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de náusea e vômitos',
          descricaoDose: '4–8 mg IV (dose única)',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '4–8 mg IV a cada 6–8h',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Asma grave',
          descricaoDose: '0,3–0,6 mg/kg/dia IV em 2–3 doses',
          unidade: 'mg',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.6,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Reação alérgica grave',
          descricaoDose: '4–8 mg IV (dose única)',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '6 mg IV a cada 12h por 3 dias',
          unidade: 'mg',
          doseFixa: 6,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de náusea e vômitos',
          descricaoDose: '4–8 mg IV (dose única)',
          unidade: 'mg',
          doseMinima: 4,
          doseMaxima: 8,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '2–4 mg IV a cada 6–8h',
          unidade: 'mg',
          doseMinima: 2,
          doseMaxima: 4,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Asma grave',
          descricaoDose: '0,2–0,4 mg/kg/dia IV em 2–3 doses',
          unidade: 'mg',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 0.4,
          peso: peso,
        ),
        MedicamentoDexametasona._linhaIndicacaoDoseCalculada(
          titulo: 'Reação alérgica grave',
          descricaoDose: '2–4 mg IV (dose única)',
          unidade: 'mg',
          doseMinima: 2,
          doseMaxima: 4,
          peso: peso,
        ),
      ]);
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

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMinima,
    double? doseMaxima,
    double? doseFixa,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (doseFixa != null) {
      if (doseFixa < 1) {
        textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
      }
      // Verificar se dose mínima não ultrapassou a máxima
      if (doseMin > doseMax) doseMin = doseMax;
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
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
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
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