import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDroperidol {
  static const String nome = 'Droperidol';
  static const String idBulario = 'droperidol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/droperidol.json');
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
      conteudo: _buildCardDroperidol(
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
    // Droperidol tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardDroperidol(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDroperidol._textoObs('Antipsicótico, antiemético, sedativo, neuroléptico'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDroperidol._linhaPreparo('Ampola 2,5 mg/mL (2 mL)', ''),
        MedicamentoDroperidol._linhaPreparo('Ampola 5 mg/mL (2 mL)', ''),
        MedicamentoDroperidol._linhaPreparo('Frasco-ampola 2,5 mg/mL', ''),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDroperidol._linhaPreparo('IV: administrar lentamente (2–3 minutos)', ''),
        MedicamentoDroperidol._linhaPreparo('IV: diluir em SF 0,9% ou SG 5% se necessário', ''),
        MedicamentoDroperidol._linhaPreparo('IM: administrar profundamente', ''),
        MedicamentoDroperidol._linhaPreparo('Monitorar ECG durante administração', ''),
        MedicamentoDroperidol._linhaPreparo('Titulação conforme resposta clínica', ''),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDroperidol._textoObs('Antipsicótico neuroléptico com propriedades antieméticas'),
        MedicamentoDroperidol._textoObs('Efeito sedativo e ansiolítico'),
        MedicamentoDroperidol._textoObs('Efeito em 3–10 minutos após administração IV'),
        MedicamentoDroperidol._textoObs('Pode causar prolongamento do intervalo QT'),
        MedicamentoDroperidol._textoObs('Contraindicado em pacientes com QT prolongado'),
        MedicamentoDroperidol._textoObs('Cautela em pacientes com arritmias cardíacas'),
        MedicamentoDroperidol._textoObs('Monitorar ECG e sinais vitais'),
        MedicamentoDroperidol._textoObs('Pode causar discinesia tardia'),
        MedicamentoDroperidol._textoObs('Meia-vida de 2–3 horas'),
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
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em procedimentos',
          descricaoDose: '0,025–0,05 mg/kg IV/IM (máx. 1,25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 1.25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em procedimentos',
          descricaoDose: '0,025–0,05 mg/kg IV/IM (máx. 1,25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 1.25,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético',
          descricaoDose: '0,01–0,025 mg/kg IV/IM (máx. 0,625 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.025,
          doseMaximaTotal: 0.625,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em procedimentos',
          descricaoDose: '0,025–0,05 mg/kg IV/IM (máx. 2,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 2.5,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético',
          descricaoDose: '0,01–0,025 mg/kg IV/IM (máx. 1,25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.025,
          doseMaximaTotal: 1.25,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Agitação psicomotora',
          descricaoDose: '0,025–0,05 mg/kg IV/IM (máx. 2,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 2.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em procedimentos',
          descricaoDose: '0,025–0,05 mg/kg IV/IM (máx. 5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 5,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético',
          descricaoDose: '0,01–0,025 mg/kg IV/IM (máx. 2,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.025,
          doseMaximaTotal: 2.5,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Agitação psicomotora',
          descricaoDose: '0,025–0,05 mg/kg IV/IM (máx. 5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em procedimentos',
          descricaoDose: '1,25–5 mg IV/IM',
          unidade: 'mg',
          doseMinima: 1.25,
          doseMaxima: 5,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético',
          descricaoDose: '0,625–1,25 mg IV/IM',
          unidade: 'mg',
          doseMinima: 0.625,
          doseMaxima: 1.25,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Agitação psicomotora',
          descricaoDose: '1,25–5 mg IV/IM',
          unidade: 'mg',
          doseMinima: 1.25,
          doseMaxima: 5,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Delírio pós-operatório',
          descricaoDose: '0,625–1,25 mg IV/IM',
          unidade: 'mg',
          doseMinima: 0.625,
          doseMaxima: 1.25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em procedimentos',
          descricaoDose: '0,625–2,5 mg IV/IM',
          unidade: 'mg',
          doseMinima: 0.625,
          doseMaxima: 2.5,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético',
          descricaoDose: '0,3125–0,625 mg IV/IM',
          unidade: 'mg',
          doseMinima: 0.3125,
          doseMaxima: 0.625,
          peso: peso,
        ),
        MedicamentoDroperidol._linhaIndicacaoDoseCalculada(
          titulo: 'Delírio pós-operatório',
          descricaoDose: '0,3125–0,625 mg IV/IM',
          unidade: 'mg',
          doseMinima: 0.3125,
          doseMaxima: 0.625,
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
