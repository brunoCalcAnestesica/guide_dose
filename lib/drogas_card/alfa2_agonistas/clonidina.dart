import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoClonidina {
  static const String nome = 'Clonidina';
  static const String idBulario = 'clonidina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/clonidina.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Clonidina tem indicações para todas as faixas etárias
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
      conteudo: _buildCardClonidina(
        context,
        peso,
        isAdulto,
        faixaEtaria, // Pass faixaEtaria to _buildCardClonidina
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardClonidina(BuildContext context, double peso, bool isAdulto, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClonidina._textoObs('Agonista alfa-2 adrenérgico central'),
        MedicamentoClonidina._textoObs('Anti-hipertensivo, sedativo e analgésico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClonidina._linhaPreparo('Comprimido 0,1 mg', 'Para uso oral'),
        MedicamentoClonidina._linhaPreparo('Comprimido 0,2 mg', 'Para uso oral'),
        MedicamentoClonidina._linhaPreparo('Comprimido 0,3 mg', 'Para uso oral'),
        MedicamentoClonidina._linhaPreparo('Ampola 150 mcg/mL (1 mL)', 'Para uso IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClonidina._linhaPreparo('150 mcg em 49 mL SF 0,9%', '3 mcg/mL'),
        MedicamentoClonidina._linhaPreparo('300 mcg em 98 mL SF 0,9%', '3 mcg/mL'),
        MedicamentoClonidina._linhaPreparo('600 mcg em 196 mL SF 0,9%', '3 mcg/mL'),
        MedicamentoClonidina._linhaPreparo('VO: administrar com ou sem alimentos', 'Manter intervalos regulares'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClonidina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClonidina._textoObs('Efeitos sedativos e anti-hipertensivos'),
        MedicamentoClonidina._textoObs('Monitorar pressão arterial e frequência cardíaca'),
        MedicamentoClonidina._textoObs('Risco de bradicardia e hipotensão'),
        MedicamentoClonidina._textoObs('Pode causar sedação prolongada'),
        MedicamentoClonidina._textoObs('Interage com outros sedativos e anti-hipertensivos'),
        MedicamentoClonidina._textoObs('Contraindicação em bloqueio AV de 2º e 3º grau'),
        MedicamentoClonidina._textoObs('Efeito rebote ao suspender abruptamente'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI neonatal',
          descricaoDose: '0,5–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial',
          descricaoDose: '0,5–1 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI pediátrica',
          descricaoDose: '0,5–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial',
          descricaoDose: '0,5–1 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Premedicação anestésica',
          descricaoDose: '1–3 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 3.0,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI pediátrica',
          descricaoDose: '0,5–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial',
          descricaoDose: '0,5–1 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Premedicação anestésica',
          descricaoDose: '1–3 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 3.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Controle de abstinência',
          descricaoDose: '1–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,5–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial',
          descricaoDose: '0,5–1 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Premedicação anestésica',
          descricaoDose: '1–3 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 3.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Controle de abstinência',
          descricaoDose: '1–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial',
          descricaoDose: '0,5–1 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Premedicação anestésica',
          descricaoDose: '1–3 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 3.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Controle de abstinência',
          descricaoDose: '1–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,5–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial',
          descricaoDose: '0,25–0,75 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.75,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Premedicação anestésica',
          descricaoDose: '0,5–2 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Controle de abstinência',
          descricaoDose: '0,5–1,5 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ),
        MedicamentoClonidina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,25–1,5 mcg/kg/dose IV',
          unidade: 'mcg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 1.5,
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
          MedicamentoClonidina._textoObs('Infusão contínua não é modalidade padrão para clonidina'),
          MedicamentoClonidina._textoObs('Usar doses intermitentes conforme protocolo'),
          MedicamentoClonidina._textoObs('Dose: 0,5–2 mcg/kg/dose IV a cada 6–8h'),
          MedicamentoClonidina._textoObs('Monitorização rigorosa da função cardiovascular'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoClonidina._textoObs('Infusão contínua não é modalidade padrão em pediatria'),
          MedicamentoClonidina._textoObs('Usar doses intermitentes conforme protocolo'),
          MedicamentoClonidina._textoObs('Dose: 0,5–2 mcg/kg/dose IV a cada 6–8h'),
          MedicamentoClonidina._textoObs('Monitorização rigorosa da função cardiovascular'),
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
    bool doseLimite = false;

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
        doseLimite = true;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
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
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Dose calculada: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (doseLimite) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Dose limitada por segurança',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
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
