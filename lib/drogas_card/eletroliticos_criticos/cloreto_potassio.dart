import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCloretoPotassio {
  static const String nome = 'Cloreto de Potássio';
  static const String idBulario = 'cloreto_potassio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/cloreto_potassio.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Cloreto de potássio tem indicações para todas as faixas etárias
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
      conteudo: _buildCardCloretoPotassio(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardCloretoPotassio(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoPotassio._textoObs('Eletrólito crítico'),
        MedicamentoCloretoPotassio._textoObs('Reposição de potássio'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoPotassio._linhaPreparo('Ampola 19,1% (2g/10mL)', '2,6 mEq/mL de K⁺'),
        MedicamentoCloretoPotassio._linhaPreparo('Ampola 10% (1g/10mL)', '1,34 mEq/mL de K⁺'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoPotassio._linhaPreparo('NUNCA IV direto', 'Risco de parada cardíaca'),
        MedicamentoCloretoPotassio._linhaPreparo('Sempre diluir antes da administração', 'Concentração máxima 40 mEq/L'),
        MedicamentoCloretoPotassio._linhaPreparo('Velocidade máxima 10 mEq/h', '20 mEq/h em emergências'),
        MedicamentoCloretoPotassio._linhaPreparo('Preferir via central', 'Monitoramento cardíaco obrigatório'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoPotassio._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoPotassio._textoObs('Contraindicação absoluta: hipercalemia'),
        MedicamentoCloretoPotassio._textoObs('Monitorar ECG durante infusão'),
        MedicamentoCloretoPotassio._textoObs('Incompatível com bicarbonato (precipita)'),
        MedicamentoCloretoPotassio._textoObs('Extravasamento → necrose tecidual'),
        MedicamentoCloretoPotassio._textoObs('Velocidade > 10 mEq/h → risco de arritmias'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalemia sintomática',
          descricaoDose: '0,5–1 mEq/kg IV em 1–2h (máx 2 mEq/kg/dia)',
          unidade: 'mEq',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 2,
          peso: peso,
        ),
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de potássio',
          descricaoDose: '1–3 mEq/kg/dia em infusão contínua',
          unidade: 'mEq/dia',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalemia sintomática',
          descricaoDose: '0,5–1 mEq/kg IV em 1–2h (máx 4 mEq/kg/dia)',
          unidade: 'mEq',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 4,
          peso: peso,
        ),
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de potássio',
          descricaoDose: '1–3 mEq/kg/dia em infusão contínua',
          unidade: 'mEq/dia',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalemia sintomática',
          descricaoDose: '0,5–1 mEq/kg IV em 1–2h (máx 6 mEq/kg/dia)',
          unidade: 'mEq',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 6,
          peso: peso,
        ),
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de potássio',
          descricaoDose: '1–3 mEq/kg/dia em infusão contínua',
          unidade: 'mEq/dia',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalemia sintomática',
          descricaoDose: '0,5–1 mEq/kg IV em 1–2h (máx 8 mEq/kg/dia)',
          unidade: 'mEq',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de potássio',
          descricaoDose: '1–3 mEq/kg/dia em infusão contínua',
          unidade: 'mEq/dia',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalemia sintomática',
          descricaoDose: '0,5–1 mEq/kg IV em 1–2h (máx 10 mEq/kg/dia)',
          unidade: 'mEq',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de potássio',
          descricaoDose: '1–3 mEq/kg/dia em infusão contínua',
          unidade: 'mEq/dia',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalemia sintomática',
          descricaoDose: '0,5–1 mEq/kg IV em 1–2h (máx 8 mEq/kg/dia)',
          unidade: 'mEq',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 8,
          peso: peso,
        ),
        MedicamentoCloretoPotassio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de potássio',
          descricaoDose: '1–3 mEq/kg/dia em infusão contínua',
          unidade: 'mEq/dia',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    }

    return indicacoes;
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    if (isAdulto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoCloretoPotassio._textoObs('Infusão contínua: 10–40 mEq/L'),
          MedicamentoCloretoPotassio._textoObs('Velocidade: 10 mEq/h (máx 20 mEq/h em emergências)'),
          MedicamentoCloretoPotassio._textoObs('Concentração: 40 mEq/L (máxima recomendada)'),
          MedicamentoCloretoPotassio._textoObs('Monitorar ECG e eletrólitos durante infusão'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoCloretoPotassio._textoObs('Infusão contínua: 10–40 mEq/L'),
          MedicamentoCloretoPotassio._textoObs('Velocidade: 5–10 mEq/h (pediatria)'),
          MedicamentoCloretoPotassio._textoObs('Concentração: 40 mEq/L (máxima recomendada)'),
          MedicamentoCloretoPotassio._textoObs('Monitorar ECG e eletrólitos durante infusão'),
        ],
      );
    }
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
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