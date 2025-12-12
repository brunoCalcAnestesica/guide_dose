import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDobutamina {
  static const String nome = 'Dobutamina';
  static const String idBulario = 'dobutamina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/dobutamina.json');
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
      conteudo: _buildCardDobutamina(
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
    // Dobutamina tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardDobutamina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDobutamina._textoObs('Simpatomimético, inotrópico positivo, cronotrópico positivo'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDobutamina._linhaPreparo('Ampola 250 mg/20 mL (12,5 mg/mL)', ''),
        MedicamentoDobutamina._linhaPreparo('Ampola 250 mg/50 mL (5 mg/mL)', ''),
        MedicamentoDobutamina._linhaPreparo('Frasco-ampola 250 mg', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDobutamina._linhaPreparo('IV: infusão contínua obrigatória', ''),
        MedicamentoDobutamina._linhaPreparo('IV: diluir em SF 0,9% ou SG 5%', ''),
        MedicamentoDobutamina._linhaPreparo('IV: usar bomba de infusão', ''),
        MedicamentoDobutamina._linhaPreparo('IV: monitorar ECG e pressão arterial', ''),
        MedicamentoDobutamina._linhaPreparo('IV: titulação conforme resposta clínica', ''),
        
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
        MedicamentoDobutamina._textoObs('• Inotrópico positivo com efeito cronotrópico moderado'),
        MedicamentoDobutamina._textoObs('• Aumenta débito cardíaco com menor aumento da frequência cardíaca'),
        MedicamentoDobutamina._textoObs('• Efeito em 2–10 minutos após início da infusão'),
        MedicamentoDobutamina._textoObs('• Pode causar taquicardia, arritmias e hipertensão'),
        MedicamentoDobutamina._textoObs('• Contraindicado em estenose aórtica severa'),
        MedicamentoDobutamina._textoObs('• Cautela em pacientes com cardiomiopatia hipertrófica'),
        MedicamentoDobutamina._textoObs('• Monitorar ECG, pressão arterial e débito cardíaco'),
        MedicamentoDobutamina._textoObs('• Meia-vida de 2–3 minutos'),
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
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardíaco',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardíaco',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardíaco',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Teste de estresse cardíaco',
          descricaoDose: '5–40 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 40,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque cardiogênico',
          descricaoDose: '5–15 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 15,
          peso: peso,
        ),
        MedicamentoDobutamina._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardíaco',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 2,
          dosePorKgMaxima: 10,
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
        MedicamentoDobutamina._textoObs('Infusão contínua obrigatória com bomba de infusão'),
        MedicamentoDobutamina._textoObs('Titulação conforme resposta clínica'),
        MedicamentoDobutamina._textoObs('Monitorar ECG, pressão arterial e débito cardíaco'),
        MedicamentoDobutamina._textoObs('Ajustar dose conforme resposta hemodinâmica'),
        MedicamentoDobutamina._textoObs('Cautela em pacientes com arritmias'),
        
        const SizedBox(height: 16),
        
        // Conversor de infusão
        ConversaoInfusaoSlider(
          doseMin: isAdulto ? 2.0 : 2.0,
          doseMax: isAdulto ? 15.0 : 10.0,
          unidade: 'mcg/kg/min',
          peso: peso,
          opcoesConcentracoes: isAdulto 
            ? {
                '250 mg em 250 mL SF (1000 mcg/mL)': 1000.0,
                '250 mg em 500 mL SF (500 mcg/mL)': 500.0,
                '250 mg em 1000 mL SF (250 mcg/mL)': 250.0,
              }
            : {
                '250 mg em 500 mL SF (500 mcg/mL)': 500.0,
                '250 mg em 1000 mL SF (250 mcg/mL)': 250.0,
                '125 mg em 250 mL SF (500 mcg/mL)': 500.0,
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
