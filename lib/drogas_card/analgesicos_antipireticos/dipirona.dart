import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDipirona {
  static const String nome = 'Dipirona';
  static const String idBulario = 'dipirona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/dipirona.json');
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
      conteudo: _buildCardDipirona(
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
    // Dipirona tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardDipirona(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDipirona._textoObs('Analgésico, antipirético, anti-inflamatório não esteroidal (AINE)'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDipirona._linhaPreparo('Comprimidos 500 mg', ''),
        MedicamentoDipirona._linhaPreparo('Ampolas 500 mg/mL (2 mL)', ''),
        MedicamentoDipirona._linhaPreparo('Ampolas 1 g/mL (2 mL)', ''),
        MedicamentoDipirona._linhaPreparo('Solução oral 500 mg/mL', ''),
        MedicamentoDipirona._linhaPreparo('Supositórios 500 mg', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDipirona._linhaPreparo('IV: administrar lentamente (3–5 minutos)', ''),
        MedicamentoDipirona._linhaPreparo('IV: diluir em SF 0,9% ou SG 5% se necessário', ''),
        MedicamentoDipirona._linhaPreparo('IM: administrar profundamente', ''),
        MedicamentoDipirona._linhaPreparo('VO: comprimidos ou solução oral', ''),
        MedicamentoDipirona._linhaPreparo('Retal: supositórios', ''),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        
        const SizedBox(height: 16),
        
        // Infusão contínua
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildConversorInfusao(peso, isAdulto),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDipirona._textoObs('• Analgésico e antipirético potente com efeito anti-inflamatório'),
        MedicamentoDipirona._textoObs('• Efeito analgésico em 15–30 minutos após administração'),
        MedicamentoDipirona._textoObs('• Pode causar agranulocitose (raro, mas grave)'),
        MedicamentoDipirona._textoObs('• Contraindicado em pacientes com história de agranulocitose'),
        MedicamentoDipirona._textoObs('• Cautela em pacientes com asma ou alergia a AINEs'),
        MedicamentoDipirona._textoObs('• Pode causar hipotensão e choque anafilático'),
        MedicamentoDipirona._textoObs('• Monitorar sinais de reação alérgica'),
        MedicamentoDipirona._textoObs('• Meia-vida de 2–4 horas'),
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
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor e febre',
          descricaoDose: '5–10 mg/kg/dose IV/IM a cada 6–8h (máx. 200 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaximaTotal: 200,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor e febre',
          descricaoDose: '5–10 mg/kg/dose IV/IM a cada 6–8h (máx. 300 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaximaTotal: 300,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor pós-operatória',
          descricaoDose: '5–10 mg/kg/dose IV/IM a cada 6–8h (máx. 300 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaximaTotal: 300,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor e febre',
          descricaoDose: '5–10 mg/kg/dose IV/IM a cada 6–8h (máx. 2000 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaximaTotal: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor pós-operatória',
          descricaoDose: '5–10 mg/kg/dose IV/IM a cada 6–8h (máx. 2000 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaximaTotal: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Cólica renal',
          descricaoDose: '5–10 mg/kg/dose IV/IM a cada 6–8h (máx. 2000 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaximaTotal: 2000,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor e febre',
          descricaoDose: '500–2000 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 500,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor pós-operatória',
          descricaoDose: '500–2000 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 500,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Cólica renal',
          descricaoDose: '500–2000 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 500,
          doseMaxima: 2000,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor e febre',
          descricaoDose: '1–2 g IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor pós-operatória',
          descricaoDose: '1–2 g IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Cólica renal',
          descricaoDose: '1–2 g IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor de cabeça',
          descricaoDose: '500–2000 mg VO a cada 6–8h',
          unidade: 'mg',
          doseMinima: 500,
          doseMaxima: 2000,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor e febre',
          descricaoDose: '500–2000 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 500,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Dor pós-operatória',
          descricaoDose: '500–2000 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 500,
          doseMaxima: 2000,
          peso: peso,
        ),
        MedicamentoDipirona._linhaIndicacaoDoseCalculada(
          titulo: 'Cólica renal',
          descricaoDose: '500–2000 mg IV/IM a cada 6–8h',
          unidade: 'mg',
          doseMinima: 500,
          doseMaxima: 2000,
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
        MedicamentoDipirona._textoObs('Infusão contínua: 0,5–1 g a cada 6–8h'),
        MedicamentoDipirona._textoObs('Alternativa: 500–1000 mg a cada 6–8h'),
        MedicamentoDipirona._textoObs('Monitorar sinais de reação alérgica'),
        MedicamentoDipirona._textoObs('Ajustar dose conforme resposta clínica'),
        MedicamentoDipirona._textoObs('Cautela em pacientes com asma'),
        
        const SizedBox(height: 16),
        
        // Conversor de infusão
        ConversaoInfusaoSlider(
          doseMin: isAdulto ? 0.5 : 0.25,
          doseMax: isAdulto ? 1.0 : 0.75,
          unidade: 'g/h',
          peso: peso,
          opcoesConcentracoes: isAdulto 
            ? {
                '1 g em 100 mL SF (10 mg/mL)': 10.0,
                '1 g em 50 mL SF (20 mg/mL)': 20.0,
                '500 mg em 50 mL SF (10 mg/mL)': 10.0,
              }
            : {
                '500 mg em 100 mL SF (5 mg/mL)': 5.0,
                '500 mg em 50 mL SF (10 mg/mL)': 10.0,
                '250 mg em 50 mL SF (5 mg/mL)': 5.0,
              },
        ),
      ],
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
