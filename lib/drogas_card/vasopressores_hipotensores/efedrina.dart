import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoEfedrina {
  static const String nome = 'Efedrina';
  static const String idBulario = 'efedrina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/efedrina.json');
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
      conteudo: _buildCardEfedrina(
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
    // Efedrina tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardEfedrina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEfedrina._textoObs('Simpatomimético, vasopressor, broncodilatador'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEfedrina._linhaPreparo('Ampola 30 mg/mL (1 mL)', ''),
        MedicamentoEfedrina._linhaPreparo('Ampola 50 mg/mL (1 mL)', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEfedrina._linhaPreparo('IV: administrar lentamente (2–3 minutos)', ''),
        MedicamentoEfedrina._linhaPreparo('IV: diluir em SF 0,9% ou SG 5% se necessário', ''),
        MedicamentoEfedrina._linhaPreparo('IM: administrar profundamente', ''),
        MedicamentoEfedrina._linhaPreparo('Monitorar ECG e pressão arterial', ''),
        
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
        MedicamentoEfedrina._textoObs('Simpatomimético com efeitos alfa e beta-adrenérgicos'),
        MedicamentoEfedrina._textoObs('Efeito vasopressor e broncodilatador'),
        MedicamentoEfedrina._textoObs('Efeito em 1–5 minutos após administração IV'),
        MedicamentoEfedrina._textoObs('Pode causar taquicardia, arritmias e hipertensão'),
        MedicamentoEfedrina._textoObs('Contraindicado em pacientes com arritmias ventriculares'),
        MedicamentoEfedrina._textoObs('Cautela em pacientes com hipertensão arterial'),
        MedicamentoEfedrina._textoObs('Monitorar ECG, pressão arterial e frequência cardíaca'),
        MedicamentoEfedrina._textoObs('Pode causar insônia e ansiedade'),
        MedicamentoEfedrina._textoObs('Meia-vida de 3–6 horas'),
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
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão arterial',
          descricaoDose: '0,1–0,3 mg/kg IV/IM (máx. 15 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          doseMaximaTotal: 15,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo',
          descricaoDose: '0,1–0,2 mg/kg IV/IM (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaximaTotal: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão arterial',
          descricaoDose: '0,1–0,3 mg/kg IV/IM (máx. 15 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          doseMaximaTotal: 15,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo',
          descricaoDose: '0,1–0,2 mg/kg IV/IM (máx. 10 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaximaTotal: 10,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão arterial',
          descricaoDose: '0,1–0,3 mg/kg IV/IM (máx. 25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          doseMaximaTotal: 25,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo',
          descricaoDose: '0,1–0,2 mg/kg IV/IM (máx. 15 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaximaTotal: 15,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Asma aguda',
          descricaoDose: '0,1–0,2 mg/kg IV/IM (máx. 15 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaximaTotal: 15,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão arterial',
          descricaoDose: '0,1–0,3 mg/kg IV/IM (máx. 50 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          doseMaximaTotal: 50,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo',
          descricaoDose: '0,1–0,2 mg/kg IV/IM (máx. 25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaximaTotal: 25,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Asma aguda',
          descricaoDose: '0,1–0,2 mg/kg IV/IM (máx. 25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaximaTotal: 25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão arterial',
          descricaoDose: '5–25 mg IV/IM',
          unidade: 'mg',
          doseMinima: 5,
          doseMaxima: 25,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo',
          descricaoDose: '5–15 mg IV/IM',
          unidade: 'mg',
          doseMinima: 5,
          doseMaxima: 15,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Asma aguda',
          descricaoDose: '5–15 mg IV/IM',
          unidade: 'mg',
          doseMinima: 5,
          doseMaxima: 15,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão arterial',
          descricaoDose: '2,5–15 mg IV/IM',
          unidade: 'mg',
          doseMinima: 2.5,
          doseMaxima: 15,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo',
          descricaoDose: '2,5–10 mg IV/IM',
          unidade: 'mg',
          doseMinima: 2.5,
          doseMaxima: 10,
          peso: peso,
        ),
        MedicamentoEfedrina._linhaIndicacaoDoseCalculada(
          titulo: 'Asma aguda',
          descricaoDose: '2,5–10 mg IV/IM',
          unidade: 'mg',
          doseMinima: 2.5,
          doseMaxima: 10,
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
        MedicamentoEfedrina._textoObs('Infusão contínua para hipotensão refratária'),
        MedicamentoEfedrina._textoObs('Titulação conforme resposta clínica'),
        MedicamentoEfedrina._textoObs('Monitorar ECG, pressão arterial e frequência cardíaca'),
        MedicamentoEfedrina._textoObs('Ajustar dose conforme resposta hemodinâmica'),
        MedicamentoEfedrina._textoObs('Cautela em pacientes com arritmias'),
        
        const SizedBox(height: 16),
        
        // Conversor de infusão
        ConversaoInfusaoSlider(
          doseMin: isAdulto ? 0.1 : 0.05,
          doseMax: isAdulto ? 0.5 : 0.3,
          unidade: 'mg/kg/h',
          peso: peso,
          opcoesConcentracoes: {
            '50 mg em 100 mL SF (0,5 mg/mL)': 0.5,
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
      
      // Formatação inteligente para doses por kg
      String doseMinFormatada;
      String doseMaxFormatada;
      
      if (doseMin < 1) {
        doseMinFormatada = doseMin.toStringAsFixed(3);
        // Remove zeros desnecessários
        doseMinFormatada = doseMinFormatada.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        if (doseMinFormatada.isEmpty) doseMinFormatada = '0';
      } else if (doseMin < 10) {
        doseMinFormatada = doseMin.toStringAsFixed(2);
        doseMinFormatada = doseMinFormatada.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        if (doseMinFormatada.isEmpty) doseMinFormatada = '0';
      } else {
        doseMinFormatada = doseMin.toStringAsFixed(1);
        doseMinFormatada = doseMinFormatada.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        if (doseMinFormatada.isEmpty) doseMinFormatada = '0';
      }
      
      if (doseMax < 1) {
        doseMaxFormatada = doseMax.toStringAsFixed(3);
        doseMaxFormatada = doseMaxFormatada.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        if (doseMaxFormatada.isEmpty) doseMaxFormatada = '0';
      } else if (doseMax < 10) {
        doseMaxFormatada = doseMax.toStringAsFixed(2);
        doseMaxFormatada = doseMaxFormatada.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        if (doseMaxFormatada.isEmpty) doseMaxFormatada = '0';
      } else {
        doseMaxFormatada = doseMax.toStringAsFixed(1);
        doseMaxFormatada = doseMaxFormatada.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        if (doseMaxFormatada.isEmpty) doseMaxFormatada = '0';
      }
      
      textoDose = '$doseMinFormatada–$doseMaxFormatada $unidade';
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
