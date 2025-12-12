import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDopamina {
  static const String nome = 'Dopamina';
  static const String idBulario = 'dopamina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/dopamina.json');
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
      conteudo: _buildCardDopamina(
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
    // Dopamina tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardDopamina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDopamina._textoObs('Simpatomimético, vasopressor, inotrópico positivo'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDopamina._linhaPreparo('Ampola 200 mg/5 mL (40 mg/mL)', ''),
        MedicamentoDopamina._linhaPreparo('Ampola 400 mg/10 mL (40 mg/mL)', ''),
        MedicamentoDopamina._linhaPreparo('Frasco-ampola 200 mg', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDopamina._linhaPreparo('IV: infusão contínua obrigatória', ''),
        MedicamentoDopamina._linhaPreparo('IV: diluir em SF 0,9% ou SG 5%', ''),
        MedicamentoDopamina._linhaPreparo('IV: usar bomba de infusão', ''),
        MedicamentoDopamina._linhaPreparo('IV: monitorar ECG e pressão arterial', ''),
        MedicamentoDopamina._linhaPreparo('IV: titulação conforme resposta clínica', ''),
        
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
        MedicamentoDopamina._textoObs('• Vasopressor com efeitos dose-dependentes'),
        MedicamentoDopamina._textoObs('• Baixas doses: efeito dopaminérgico (renal)'),
        MedicamentoDopamina._textoObs('• Doses médias: efeito beta-adrenérgico (cardíaco)'),
        MedicamentoDopamina._textoObs('• Altas doses: efeito alfa-adrenérgico (vasoconstritor)'),
        MedicamentoDopamina._textoObs('• Efeito em 5–10 minutos após início da infusão'),
        MedicamentoDopamina._textoObs('• Pode causar taquicardia, arritmias e vasoconstrição'),
        MedicamentoDopamina._textoObs('• Contraindicado em feocromocitoma'),
        MedicamentoDopamina._textoObs('• Cautela em pacientes com arritmias ventriculares'),
        MedicamentoDopamina._textoObs('• Monitorar ECG, pressão arterial e débito urinário'),
        MedicamentoDopamina._textoObs('• Meia-vida de 2–5 minutos'),
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
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência renal aguda',
          descricaoDose: '1–3 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência renal aguda',
          descricaoDose: '1–3 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência renal aguda',
          descricaoDose: '1–3 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência renal aguda',
          descricaoDose: '1–3 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência renal aguda',
          descricaoDose: '1–3 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '5–20 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque hipovolêmico',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência renal aguda',
          descricaoDose: '1–3 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
        MedicamentoDopamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
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
        MedicamentoDopamina._textoObs('Infusão contínua obrigatória com bomba de infusão'),
        MedicamentoDopamina._textoObs('Titulação conforme resposta clínica'),
        MedicamentoDopamina._textoObs('Monitorar ECG, pressão arterial e débito urinário'),
        MedicamentoDopamina._textoObs('Ajustar dose conforme resposta hemodinâmica'),
        MedicamentoDopamina._textoObs('Cautela em pacientes com arritmias'),
        
        const SizedBox(height: 16),
        
        // Conversor de infusão
        ConversaoInfusaoSlider(
          doseMin: isAdulto ? 2.0 : 1.0,
          doseMax: isAdulto ? 20.0 : 15.0,
          unidade: 'mcg/kg/min',
          peso: peso,
          opcoesConcentracoes: isAdulto 
            ? {
                '400 mg em 250 mL SF (1600 mcg/mL)': 1600.0,
                '400 mg em 500 mL SF (800 mcg/mL)': 800.0,
                '200 mg em 250 mL SF (800 mcg/mL)': 800.0,
              }
            : {
                '200 mg em 250 mL SF (800 mcg/mL)': 800.0,
                '200 mg em 500 mL SF (400 mcg/mL)': 400.0,
                '100 mg em 250 mL SF (400 mcg/mL)': 400.0,
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
