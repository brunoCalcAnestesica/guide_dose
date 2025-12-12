import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDextrocetamina {
  static const String nome = 'Dextrocetamina';
  static const String idBulario = 'dextrocetamina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/dextrocetamina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Dextrocetamina tem indicações para todas as faixas etárias
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
      conteudo: _buildCardDextrocetamina(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardDextrocetamina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrocetamina._textoObs('Anestésico dissociativo'),
        MedicamentoDextrocetamina._textoObs('Isômero dextrogiro da cetamina'),
        MedicamentoDextrocetamina._textoObs('Ação analgésica e sedativa'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrocetamina._linhaPreparo('Ampola 25mg/mL (2mL)', 'Via IV/IM'),
        MedicamentoDextrocetamina._linhaPreparo('Ampola 50mg/mL (1mL)', 'Via IV/IM'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrocetamina._linhaPreparo('Diluir em SF 0,9%', 'Para infusão IV'),
        MedicamentoDextrocetamina._linhaPreparo('Concentração: 1mg/mL', '25mg em 25mL SF'),
        MedicamentoDextrocetamina._linhaPreparo('Concentração: 2mg/mL', '50mg em 25mL SF'),
        MedicamentoDextrocetamina._linhaPreparo('Concentração pediátrica: 0,5mg/mL', '25mg em 50mL SF'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrocetamina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrocetamina._textoObs('Contraindicação: hipertensão arterial grave'),
        MedicamentoDextrocetamina._textoObs('Monitorar pressão arterial e FC'),
        MedicamentoDextrocetamina._textoObs('Pode causar alucinações e pesadelos'),
        MedicamentoDextrocetamina._textoObs('Sedação dissociativa (paciente não responsivo)'),
        MedicamentoDextrocetamina._textoObs('Manter via aérea pérvia'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para intubação',
          descricaoDose: '1–2 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para intubação',
          descricaoDose: '1–2 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para intubação',
          descricaoDose: '1–2 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos dolorosos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para intubação',
          descricaoDose: '1–2 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos dolorosos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para intubação',
          descricaoDose: '1–2 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos dolorosos',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos de emergência',
          descricaoDose: '1–2 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,3–0,7 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para intubação',
          descricaoDose: '0,5–1 mg/kg IV em 1–2 min',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrocetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos dolorosos',
          descricaoDose: '0,3–0,7 mg/kg IV em 1–2 min',
          unidade: 'mg',
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
        MedicamentoDextrocetamina._textoObs('Infusão contínua: 0,1–0,5 mg/kg/h'),
        MedicamentoDextrocetamina._textoObs('Diluir em 50–100 mL SF 0,9%'),
        MedicamentoDextrocetamina._textoObs('Concentração: 1 mg/mL (adultos)'),
        MedicamentoDextrocetamina._textoObs('Concentração: 0,5 mg/mL (pediátrica)'),
        MedicamentoDextrocetamina._textoObs('Monitorar pressão arterial e FC'),
        MedicamentoDextrocetamina._textoObs('Sedação dissociativa'),
        const SizedBox(height: 16),
        ConversaoInfusaoSlider(
          peso: peso,
          doseMin: isAdulto ? 0.1 : 0.05,
          doseMax: isAdulto ? 0.5 : 0.3,
          unidade: 'mg/kg/h',
          opcoesConcentracoes: {
            '25mg em 25mL SF (1mg/mL)': 1.0,
            '50mg em 25mL SF (2mg/mL)': 2.0,
            '25mg em 50mL SF (0,5mg/mL)': 0.5,
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