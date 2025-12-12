import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDexmedetomidina {
  static const String nome = 'Dexmedetomidina';
  static const String idBulario = 'dexmedetomidina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/dexmedetomidina.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Dexmedetomidina tem indicações para todas as faixas etárias
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
      conteudo: _buildCardDexmedetomidina(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardDexmedetomidina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexmedetomidina._textoObs('Agonista α2-adrenérgico seletivo'),
        MedicamentoDexmedetomidina._textoObs('Sedativo-hipnótico não benzodiazepínico'),
        MedicamentoDexmedetomidina._textoObs('Analgesia e sedação consciente'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexmedetomidina._linhaPreparo('Ampola 100mcg/mL (2mL)', 'Via IV'),
        MedicamentoDexmedetomidina._linhaPreparo('Ampola 200mcg/2mL', 'Via IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexmedetomidina._linhaPreparo('Diluir em SF 0,9%', 'Para infusão contínua'),
        MedicamentoDexmedetomidina._linhaPreparo('Concentração final: 4mcg/mL', '200mcg em 50mL SF'),
        MedicamentoDexmedetomidina._linhaPreparo('Concentração pediátrica: 2mcg/mL', '100mcg em 50mL SF'),
        MedicamentoDexmedetomidina._linhaPreparo('Compatível com SF e SG', 'Não misturar com outros medicamentos'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexmedetomidina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDexmedetomidina._textoObs('Contraindicação: bloqueio AV de 2º e 3º grau'),
        MedicamentoDexmedetomidina._textoObs('Monitorar pressão arterial (hipotensão)'),
        MedicamentoDexmedetomidina._textoObs('Bradicardia pode ocorrer'),
        MedicamentoDexmedetomidina._textoObs('Sedação consciente (paciente responsivo)'),
        MedicamentoDexmedetomidina._textoObs('Não causa depressão respiratória'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI neonatal',
          descricaoDose: '0,2–0,7 mcg/kg/h IV contínua',
          unidade: 'mcg/kg/h',
          doseMinima: 0.2,
          doseMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI pediátrica',
          descricaoDose: '0,2–0,7 mcg/kg/h IV contínua',
          unidade: 'mcg/kg/h',
          doseMinima: 0.2,
          doseMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI pediátrica',
          descricaoDose: '0,2–0,7 mcg/kg/h IV contínua',
          unidade: 'mcg/kg/h',
          doseMinima: 0.2,
          doseMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-operatória',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,2–0,7 mcg/kg/h IV contínua',
          unidade: 'mcg/kg/h',
          doseMinima: 0.2,
          doseMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-operatória',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,2–0,7 mcg/kg/h IV contínua',
          unidade: 'mcg/kg/h',
          doseMinima: 0.2,
          doseMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-operatória',
          descricaoDose: '0,5–1 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pós-operatória',
          descricaoDose: '0,2–0,7 mcg/kg/h IV contínua',
          unidade: 'mcg/kg/h',
          doseMinima: 0.2,
          doseMaxima: 0.7,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,1–0,5 mcg/kg/h IV contínua',
          unidade: 'mcg/kg/h',
          doseMinima: 0.1,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,3–0,7 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDexmedetomidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-operatória',
          descricaoDose: '0,3–0,7 mcg/kg IV em 10 min',
          unidade: 'mcg',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.7,
          peso: peso,
        ),
      ]);
    }

    return indicacoes;
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicamentoDexmedetomidina._textoObs('Infusão contínua: 0,2–0,7 mcg/kg/h'),
        MedicamentoDexmedetomidina._textoObs('Diluir em 50–100 mL SF 0,9%'),
        MedicamentoDexmedetomidina._textoObs('Monitorar pressão arterial e FC'),
        MedicamentoDexmedetomidina._textoObs('Sedação consciente (RASS -1 a -3)'),
        const SizedBox(height: 16),
        ConversaoInfusaoSlider(
          peso: peso,
          doseMin: isAdulto ? 0.2 : 0.1,
          doseMax: isAdulto ? 0.7 : 0.5,
          unidade: 'mcg/kg/h',
          opcoesConcentracoes: {
            '200mcg em 50mL SF (4mcg/mL)': 4.0,
            '100mcg em 50mL SF (2mcg/mL)': 2.0,
            '50mcg em 50mL SF (1mcg/mL)': 1.0,
          },
        ),
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