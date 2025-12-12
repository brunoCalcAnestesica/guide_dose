import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDiazepam {
  static const String nome = 'Diazepam';
  static const String idBulario = 'diazepam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/diazepam.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
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
      conteudo: _buildCardDiazepam(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Diazepam tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardDiazepam(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDiazepam._textoObs('Benzodiazepínico, ansiolítico, sedativo, anticonvulsivante, miorrelaxante central e hipnótico'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDiazepam._linhaPreparo('Comprimidos 2 mg, 5 mg ou 10 mg', ''),
        MedicamentoDiazepam._linhaPreparo('Solução oral 2 mg/mL', ''),
        MedicamentoDiazepam._linhaPreparo('Ampolas 5 mg/mL (2 mL, 5 mL, 10 mL)', ''),
        MedicamentoDiazepam._linhaPreparo('Gel ou solução retal', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDiazepam._linhaPreparo('IV/IM: usar ampola diretamente (5 mg/mL)', ''),
        MedicamentoDiazepam._linhaPreparo('IV/IM: diluir em SF 0,9% ou SG 5% se necessário', ''),
        MedicamentoDiazepam._linhaPreparo('Retal: usar solução pronta ou preparar diluição', ''),
        MedicamentoDiazepam._linhaPreparo('VO: solução oral 2 mg/mL ou comprimidos', ''),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDiazepam._textoObs('• Monitorização contínua de sinais vitais, ECG, frequência respiratória e sedação'),
        MedicamentoDiazepam._textoObs('• Ter disponível suporte ventilatório, oxigênio e agente reversor (flumazenil)'),
        MedicamentoDiazepam._textoObs('• Ajustar dose em idosos, insuficiência hepática ou renal'),
        MedicamentoDiazepam._textoObs('• Usar com extrema cautela em combinação com opioides'),
        MedicamentoDiazepam._textoObs('• Monitorizar para efeitos paradoxais, especialmente em crianças e idosos'),
        MedicamentoDiazepam._textoObs('• Meia-vida prolongada (20–50 horas) com metabólitos ativos'),
        MedicamentoDiazepam._textoObs('• Contraindicado em miastenia gravis não controlada'),
        MedicamentoDiazepam._textoObs('• Risco de dependência física com uso prolongado'),
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

    if (faixaEtaria == 'RN') {
      indicacoes.addAll([
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Crises convulsivas/status epilepticus',
          descricaoDose: '0,2–0,5 mg/kg IV (máx. 10 mg por dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 0.5,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-procedimento',
          descricaoDose: '0,04–0,2 mg/kg IV (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.04,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Crises convulsivas/status epilepticus',
          descricaoDose: '0,2–0,5 mg/kg IV (máx. 10 mg por dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 0.5,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-procedimento',
          descricaoDose: '0,04–0,2 mg/kg IV (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.04,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Crises convulsivas/status epilepticus',
          descricaoDose: '0,2–0,5 mg/kg IV (máx. 10 mg por dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 0.5,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-procedimento',
          descricaoDose: '0,04–0,2 mg/kg IV (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.04,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Ansiedade aguda',
          descricaoDose: '0,1–0,3 mg/kg VO (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          doseMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Crises convulsivas/status epilepticus',
          descricaoDose: '0,2–0,5 mg/kg IV (máx. 10 mg por dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 0.5,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-procedimento',
          descricaoDose: '0,04–0,2 mg/kg IV (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.04,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Ansiedade aguda',
          descricaoDose: '0,1–0,3 mg/kg VO (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          doseMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Crises convulsivas/status epilepticus',
          descricaoDose: '5–10 mg IV, repetir a cada 10–15 min (máx. 30 mg)',
          unidade: 'mg',
          doseMinima: 5,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-operatória',
          descricaoDose: '2–10 mg IM/IV, 30–60 min antes do procedimento',
          unidade: 'mg',
          doseMinima: 2,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Ansiedade aguda',
          descricaoDose: '2–10 mg VO, 2–4 vezes ao dia',
          unidade: 'mg',
          doseMinima: 2,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Abstinência alcoólica',
          descricaoDose: '10 mg VO a cada 6–8h nas primeiras 24h',
          unidade: 'mg',
          doseFixa: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Crises convulsivas/status epilepticus',
          descricaoDose: '2,5–5 mg IV, repetir a cada 10–15 min (máx. 15 mg)',
          unidade: 'mg',
          doseMinima: 2.5,
          doseMaxima: 5,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pré-operatória',
          descricaoDose: '1–5 mg IM/IV, 30–60 min antes do procedimento',
          unidade: 'mg',
          doseMinima: 1,
          doseMaxima: 5,
          peso: peso,
        ),
        MedicamentoDiazepam._linhaIndicacaoDoseCalculada(
          titulo: 'Ansiedade aguda',
          descricaoDose: '1–5 mg VO, 2–3 vezes ao dia',
          unidade: 'mg',
          doseMinima: 1,
          doseMaxima: 5,
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
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      doseCalculada = doseFixa;
      if (doseFixa < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        if (doseMax > doseMaxima) {
          doseMax = doseMaxima;
          doseLimite = true;
        }
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
                  doseLimite ? 'Dose limitada por segurança: $textoDose' : 'Dose calculada: $textoDose',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                    fontSize: 14,
                  ),
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
