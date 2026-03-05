import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoHaloperidol {
  static const String nome = 'Haloperidol';
  static const String idBulario = 'haloperidol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/haloperidol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHaloperidol(
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

    return _buildCardHaloperidol(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardHaloperidol(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // 1. CLASSE
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Antipsicótico típico (butirofenona)', 'Antagonista D2'),
        
        const SizedBox(height: 16),
        
        // 2. APRESENTAÇÃO
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 5 mg/mL', '1 mL'),
        _linhaPreparo('Comprimido 1 mg', ''),
        _linhaPreparo('Comprimido 5 mg', ''),
        _linhaPreparo('Solução oral 2 mg/mL', 'Gotas'),
        
        const SizedBox(height: 16),
        
        // 3. PREPARO
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('IV: diluir em SF 0,9% ou SG 5%', ''),
        _linhaPreparo('Administrar lentamente (2-5 min)', ''),
        _linhaPreparo('IM: pode ser administrado puro', ''),
        _linhaPreparo('Infusão: 5-10 mg em 100 mL SF', '0,05-0,1 mg/mL'),
        
        const SizedBox(height: 16),
        
        // 4. INDICAÇÕES
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        
        const SizedBox(height: 16),
        
        // 5. INFUSÃO CONTÍNUA
        if (isAdulto) ...[
          const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildConversorInfusao(peso),
          const SizedBox(height: 16),
        ],
        
        // 6. OBSERVAÇÕES
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início IV: 10-20 min | Pico: 20-40 min | Duração: 4-8h'),
        _textoObs('RISCO DE QT LONGO: monitorar ECG, evitar se QTc > 500 ms'),
        _textoObs('Pode causar síndrome extrapiramidal e acatisia'),
        _textoObs('Evitar em Parkinson, demência com corpos de Lewy'),
        _textoObs('Antídoto para reações extrapiramidais: Biperideno 2-4 mg IM'),
        _textoObs('Idoso: usar 50% da dose, maior risco de efeitos adversos'),
      ],
    );
  }

  static Widget _buildConversorInfusao(double peso) {
    final opcoesConcentracoes = {
      '10 mg + 100 mL SF (0,1 mg/mL)': 0.1,
      '5 mg + 100 mL SF (0,05 mg/mL)': 0.05,
      '20 mg + 100 mL SF (0,2 mg/mL)': 0.2,
    };

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mg/h',
      doseMin: 0.5,
      doseMax: 5.0,
      concentracaoEmMcg: false,
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'Recém-nascido' || faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação/Náusea (uso limitado)',
          descricaoDose: '0,01-0,02 mg/kg IV/IM (máx 0,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.02,
          doseMaximaTotal: 0.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação psicomotora',
          descricaoDose: '0,025-0,05 mg/kg IM (máx 2,5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 2.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náusea/Vômito refratário',
          descricaoDose: '0,01-0,02 mg/kg IV (máx 1 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.02,
          doseMaximaTotal: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação psicomotora',
          descricaoDose: '0,025-0,05 mg/kg IM (máx 5 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.025,
          dosePorKgMaxima: 0.05,
          doseMaximaTotal: 5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náusea/Vômito pós-operatório',
          descricaoDose: '0,5-1 mg IV',
          unidade: 'mg',
          doseMinima: 0.5,
          doseMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação leve',
          descricaoDose: '0,5-2 mg IV/IM',
          unidade: 'mg',
          doseMinima: 0.5,
          doseMaxima: 2,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação moderada',
          descricaoDose: '5 mg IV/IM',
          unidade: 'mg',
          doseFixa: 5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação grave',
          descricaoDose: '10 mg IV/IM (pode repetir em 30 min)',
          unidade: 'mg',
          doseFixa: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Delirium em UTI',
          descricaoDose: '2-5 mg IV a cada 6-8h',
          unidade: 'mg',
          doseMinima: 2,
          doseMaxima: 5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético (NVPO)',
          descricaoDose: '0,5-2 mg IV',
          unidade: 'mg',
          doseMinima: 0.5,
          doseMaxima: 2,
          peso: peso,
        ),
        _linhaIndicacaoInfusao(
          titulo: 'Infusão contínua (delirium refratário)',
          descricaoDose: '0,5-2 mg/h IV',
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação leve',
          descricaoDose: '0,25-1 mg IV/IM (reduzir 50%)',
          unidade: 'mg',
          doseMinima: 0.25,
          doseMaxima: 1,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação moderada',
          descricaoDose: '2,5 mg IV/IM',
          unidade: 'mg',
          doseFixa: 2.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Delirium',
          descricaoDose: '0,5-2 mg IV a cada 8-12h',
          unidade: 'mg',
          doseMinima: 0.5,
          doseMaxima: 2,
          peso: peso,
        ),
        _linhaIndicacaoInfusao(
          titulo: 'Infusão contínua',
          descricaoDose: '0,5-1 mg/h IV (monitorar QT)',
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
        ? '${doseFixa.toStringAsFixed(2)} $unidade'
        : '${doseFixa.toStringAsFixed(1)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      String minStr = doseMinima < 1 ? doseMinima.toStringAsFixed(2) : doseMinima.toStringAsFixed(1);
      String maxStr = doseMaxima < 1 ? doseMaxima.toStringAsFixed(2) : doseMaxima.toStringAsFixed(1);
      textoDose = '$minStr–$maxStr $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaximaTotal != null && doseCalculada > doseMaximaTotal) {
        doseCalculada = doseMaximaTotal;
        doseLimite = true;
      }
      textoDose = doseCalculada < 1 
        ? '${doseCalculada.toStringAsFixed(2)} $unidade'
        : '${doseCalculada.toStringAsFixed(1)} $unidade';
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
      
      String doseMinFormatada = doseMin < 1 
        ? doseMin.toStringAsFixed(2) 
        : doseMin.toStringAsFixed(1);
      String doseMaxFormatada = doseMax < 1 
        ? doseMax.toStringAsFixed(2) 
        : doseMax.toStringAsFixed(1);
      
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
                  doseLimite ? 'Dose: $textoDose (máx atingida)' : 'Dose: $textoDose',
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

  static Widget _linhaIndicacaoInfusao({
    required String titulo,
    required String descricaoDose,
  }) {
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
