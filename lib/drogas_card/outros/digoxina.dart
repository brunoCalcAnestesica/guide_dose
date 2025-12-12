import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDigoxina {
  static const String nome = 'Digoxina';
  static const String idBulario = 'digoxina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/digoxina.json');
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
      conteudo: _buildCardDigoxina(
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
    // Digoxina tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardDigoxina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDigoxina._textoObs('Glicosídeo cardíaco, antiarrítmico, inotrópico positivo'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDigoxina._linhaPreparo('Ampola 0,25 mg/mL (2 mL)', ''),
        MedicamentoDigoxina._linhaPreparo('Comprimidos 0,25 mg', ''),
        MedicamentoDigoxina._linhaPreparo('Solução oral 0,05 mg/mL', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDigoxina._linhaPreparo('IV: administrar lentamente (2–3 minutos)', ''),
        MedicamentoDigoxina._linhaPreparo('IV: diluir em SF 0,9% ou SG 5% se necessário', ''),
        MedicamentoDigoxina._linhaPreparo('Monitorar ECG durante administração', ''),
        MedicamentoDigoxina._linhaPreparo('VO: comprimidos ou solução oral', ''),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDigoxina._textoObs('• Glicosídeo cardíaco que aumenta a força de contração e diminui a frequência cardíaca'),
        MedicamentoDigoxina._textoObs('• Efeito em 5–30 minutos após administração IV'),
        MedicamentoDigoxina._textoObs('• Pode causar bradicardia e bloqueio atrioventricular'),
        MedicamentoDigoxina._textoObs('• Contraindicado em pacientes com bloqueio AV de segundo ou terceiro grau'),
        MedicamentoDigoxina._textoObs('• Monitorar ECG e eletrólitos durante tratamento'),
        MedicamentoDigoxina._textoObs('• Pode causar intoxicação digitálica'),
        MedicamentoDigoxina._textoObs('• Efeito inotrópico positivo e cronotrópico negativo'),
        MedicamentoDigoxina._textoObs('• Meia-vida prolongada (36–48 horas)'),
        MedicamentoDigoxina._textoObs('• Ajustar dose em insuficiência renal'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      indicacoes.addAll([
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Taquicardia supraventricular',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.25,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Fibrilação atrial',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Taquicardia supraventricular',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.25,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Fibrilação atrial',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Taquicardia supraventricular',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Fibrilação atrial',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Taquicardia supraventricular',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Fibrilação atrial',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '0,005–0,01 mg/kg IV (máx. 0,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Taquicardia supraventricular',
          descricaoDose: '0,25–0,5 mg IV',
          unidade: 'mg',
          doseMinima: 0.25,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Fibrilação atrial',
          descricaoDose: '0,25–0,5 mg IV',
          unidade: 'mg',
          doseMinima: 0.25,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '0,25–0,5 mg IV',
          unidade: 'mg',
          doseMinima: 0.25,
          doseMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Flutter atrial',
          descricaoDose: '0,25–0,5 mg IV',
          unidade: 'mg',
          doseMinima: 0.25,
          doseMaxima: 0.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Taquicardia supraventricular',
          descricaoDose: '0,125–0,25 mg IV',
          unidade: 'mg',
          doseMinima: 0.125,
          doseMaxima: 0.25,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Fibrilação atrial',
          descricaoDose: '0,125–0,25 mg IV',
          unidade: 'mg',
          doseMinima: 0.125,
          doseMaxima: 0.25,
          peso: peso,
        ),
        MedicamentoDigoxina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '0,125–0,25 mg IV',
          unidade: 'mg',
          doseMinima: 0.125,
          doseMaxima: 0.25,
          peso: peso,
        ),
      ]);
    }

    return indicacoes;
  }


  static Widget _linhaPreparo(String texto, String obs) {
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
          if (obs.isNotEmpty) ...[
                    const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: obs, style: const TextStyle(fontStyle: FontStyle.italic)),
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
        textoDose = '${doseCalculada.toStringAsFixed(3)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (doseMinima != null && doseMaxima != null) {
      if (doseMinima < 1) {
        textoDose = '${doseMinima.toStringAsFixed(3)}–${doseMaxima.toStringAsFixed(3)} $unidade';
      } else {
        textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(3)} $unidade';
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
      if (doseMin < 1) {
        textoDose = '${doseMin.toStringAsFixed(3)}–${doseMax.toStringAsFixed(3)} $unidade';
      } else {
        textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
      }
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