import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDimenidrinato {
  static const String nome = 'Dimenidrinato';
  static const String idBulario = 'dimenidrinato';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/dimenidrinato.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
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
      conteudo: _buildCardDimenidrinato(
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

    return _buildCardDimenidrinato(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Dimenidrinato tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardDimenidrinato(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDimenidrinato._textoObs('Anti-histamínico H1, antiemético, antivertiginoso'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDimenidrinato._linhaPreparo('Comprimidos 50 mg', ''),
        MedicamentoDimenidrinato._linhaPreparo('Ampolas 50 mg/mL (1 mL)', ''),
        MedicamentoDimenidrinato._linhaPreparo('Solução oral 12,5 mg/5 mL', ''),
        MedicamentoDimenidrinato._linhaPreparo('Supositórios 50 mg', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDimenidrinato._linhaPreparo('IV: administrar lentamente (2–3 minutos)', ''),
        MedicamentoDimenidrinato._linhaPreparo('IV: diluir em SF 0,9% ou SG 5% se necessário', ''),
        MedicamentoDimenidrinato._linhaPreparo('IM: administrar profundamente', ''),
        MedicamentoDimenidrinato._linhaPreparo('VO: comprimidos ou solução oral', ''),
        MedicamentoDimenidrinato._linhaPreparo('Retal: supositórios', ''),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDimenidrinato._textoObs('• Anti-histamínico H1 com propriedades antieméticas e antivertiginosas'),
        MedicamentoDimenidrinato._textoObs('• Efeito sedativo leve a moderado'),
        MedicamentoDimenidrinato._textoObs('• Pode causar sonolência, tontura e boca seca'),
        MedicamentoDimenidrinato._textoObs('• Contraindicado em glaucoma de ângulo fechado'),
        MedicamentoDimenidrinato._textoObs('• Cautela em pacientes com hipertrofia prostática'),
        MedicamentoDimenidrinato._textoObs('• Pode causar retenção urinária'),
        MedicamentoDimenidrinato._textoObs('• Evitar uso concomitante com álcool'),
        MedicamentoDimenidrinato._textoObs('• Meia-vida de 4–8 horas'),
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

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'Recém-nascido') {
      indicacoes.addAll([
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Náusea e vômitos',
          descricaoDose: '0,5–1 mg/kg/dose IV/IM a cada 6–8h (máx. 25 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Náusea e vômitos',
          descricaoDose: '0,5–1 mg/kg/dose IV/IM a cada 6–8h (máx. 25 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 25,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Vertigem',
          descricaoDose: '0,5–1 mg/kg/dose IV/IM a cada 6–8h (máx. 25 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Náusea e vômitos',
          descricaoDose: '0,5–1 mg/kg/dose IV/IM a cada 6–8h (máx. 50 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Vertigem',
          descricaoDose: '0,5–1 mg/kg/dose IV/IM a cada 6–8h (máx. 50 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Enjoo de movimento',
          descricaoDose: '0,5–1 mg/kg/dose VO a cada 6–8h (máx. 50 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          doseMaxima: 50,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Náusea e vômitos',
          descricaoDose: '25–50 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Vertigem',
          descricaoDose: '25–50 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Enjoo de movimento',
          descricaoDose: '25–50 mg VO a cada 6–8h',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Náusea e vômitos',
          descricaoDose: '50 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseFixa: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Vertigem',
          descricaoDose: '50 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseFixa: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Enjoo de movimento',
          descricaoDose: '50 mg VO a cada 6–8h',
          unidade: 'mg',
          doseFixa: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação leve',
          descricaoDose: '25–50 mg VO a cada 6–8h',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Náusea e vômitos',
          descricaoDose: '25–50 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Vertigem',
          descricaoDose: '25–50 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoDimenidrinato._linhaIndicacaoDoseCalculada(
          titulo: 'Enjoo de movimento',
          descricaoDose: '25–50 mg VO a cada 6–8h',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
      ]);
    }

    return indicacoes;
  }


  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? doseFixa,
    double? doseMinima,
    double? doseMaxima,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaximaTotal,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      doseCalculada = doseFixa;
      textoDose = doseFixa < 1 
        ? '${doseFixa.toStringAsFixed(1)} $unidade'
        : '${doseFixa.toStringAsFixed(0)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaximaTotal != null && doseCalculada > doseMaximaTotal) {
        doseCalculada = doseMaximaTotal;
        doseLimite = true;
      }
      textoDose = doseCalculada < 1 
        ? '${doseCalculada.toStringAsFixed(1)} $unidade'
        : '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaximaTotal != null) {
        if (doseMax > doseMaximaTotal) {
          doseMax = doseMaximaTotal;
          doseLimite = true;
        }
        if (doseMin > doseMaximaTotal) {
          doseMin = doseMaximaTotal;
          doseLimite = true;
        }
      }
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Dose calculada: $textoDose',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
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
