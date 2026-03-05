import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoColoides {
  static const String nome = 'Coloides';
  static const String idBulario = 'coloides';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/coloides.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Coloides têm indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardColoides(
        context,
        peso,
        faixaEtaria,
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

    return _buildCardColoides(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardColoides(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoColoides._textoObs('Soluções expansoras plasmáticas'),
        MedicamentoColoides._textoObs('Mantêm pressão oncótica intravascular'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoColoides._linhaPreparo('Hidroxietilamido (HEA) 6%', '500mL e 1000mL'),
        MedicamentoColoides._linhaPreparo('Albumina 20%', '100mL'),
        MedicamentoColoides._linhaPreparo('Albumina 5%', '500mL'),
        MedicamentoColoides._linhaPreparo('Gelatina fluida modificada', '500mL'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoColoides._linhaPreparo('Verificar compatibilidade com outros medicamentos', 'Pode precipitar'),
        MedicamentoColoides._linhaPreparo('Aquecer a temperatura corporal', '37°C'),
        MedicamentoColoides._linhaPreparo('Filtrar se necessário', 'Filtro 0,22μm'),
        MedicamentoColoides._linhaPreparo('Administrar via central preferencialmente', 'Monitorar pressão venosa'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoColoides._textoObs('Contraindicação: hipersensibilidade conhecida'),
        MedicamentoColoides._textoObs('Monitorar função renal e coagulação'),
        MedicamentoColoides._textoObs('Risco de reações anafiláticas'),
        MedicamentoColoides._textoObs('Evitar em insuficiência renal grave'),
        MedicamentoColoides._textoObs('Monitorar pressão arterial e débito urinário'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'Recém-nascido') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '10–20 mL/kg IV em bolus (máx 100mL)',
          unidade: 'mL',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 100,
          peso: peso,
        ),
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de volume',
          descricaoDose: '5–10 mL/kg/h IV contínua',
          unidade: 'mL/h',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '10–20 mL/kg IV em bolus (máx 200mL)',
          unidade: 'mL',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 200,
          peso: peso,
        ),
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de volume',
          descricaoDose: '5–10 mL/kg/h IV contínua',
          unidade: 'mL/h',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '10–20 mL/kg IV em bolus (máx 500mL)',
          unidade: 'mL',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 500,
          peso: peso,
        ),
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de volume',
          descricaoDose: '5–10 mL/kg/h IV contínua',
          unidade: 'mL/h',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '10–20 mL/kg IV em bolus (máx 1000mL)',
          unidade: 'mL',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de volume',
          descricaoDose: '5–10 mL/kg/h IV contínua',
          unidade: 'mL/h',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '10–20 mL/kg IV em bolus (máx 1500mL)',
          unidade: 'mL',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1500,
          peso: peso,
        ),
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de volume',
          descricaoDose: '5–10 mL/kg/h IV contínua',
          unidade: 'mL/h',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '10–20 mL/kg IV em bolus (máx 1000mL)',
          unidade: 'mL',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoColoides._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção de volume',
          descricaoDose: '5–10 mL/kg/h IV contínua',
          unidade: 'mL/h',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
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