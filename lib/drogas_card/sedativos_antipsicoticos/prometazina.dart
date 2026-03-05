import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPrometazina {
  static const String nome = 'Prometazina';
  static const String idBulario = 'prometazina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/prometazina.json');
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
      conteudo: _buildCardPrometazina(
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

    return _buildCardPrometazina(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardPrometazina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // 1. CLASSE
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anti-histamínico (fenotiazina)', 'Antagonista H1, anticolinérgico'),
        
        const SizedBox(height: 16),
        
        // 2. APRESENTAÇÃO
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 25 mg/mL', '2 mL'),
        _linhaPreparo('Comprimido 25 mg', ''),
        _linhaPreparo('Xarope 5 mg/5 mL', ''),
        
        const SizedBox(height: 16),
        
        // 3. PREPARO
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('IM: administrar profundamente (preferencial)', ''),
        _linhaPreparo('IV: diluir em 10-20 mL de SF', 'Infundir lento (> 5 min)'),
        _linhaPreparo('EVITAR extravasamento (necrose tissular)', ''),
        _linhaPreparo('Não administrar SC ou intra-arterial', ''),
        
        const SizedBox(height: 16),
        
        // 4. INDICAÇÕES
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria),
        
        const SizedBox(height: 16),
        
        // 6. OBSERVAÇÕES
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início IV: 3-5 min | Início IM: 20 min | Duração: 4-6h'),
        _textoObs('SEDAÇÃO INTENSA - útil para ansiedade e insônia'),
        _textoObs('Efeito anticolinérgico: boca seca, retenção urinária'),
        _textoObs('EVITAR em < 2 anos (risco de depressão respiratória)'),
        _textoObs('Risco de síndrome neuroléptica maligna'),
        _textoObs('Pode causar hipotensão e prolongamento QT'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'Recém-nascido' || faixaEtaria == 'Lactente') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'CONTRAINDICADO em < 2 anos',
          descricaoDose: 'Risco de depressão respiratória fatal',
          unidade: '',
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação (> 2 anos)',
          descricaoDose: '0,25-0,5 mg/kg IV/IM (máx 25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          doseMaximaTotal: 25,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náusea/Vômito',
          descricaoDose: '0,25-0,5 mg/kg IV/IM (máx 25 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          doseMaximaTotal: 25,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Alergia/Prurido',
          descricaoDose: '0,1 mg/kg VO/IM (máx 12,5 mg)',
          unidade: 'mg',
          dosePorKg: 0.1,
          doseMaximaTotal: 12.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação',
          descricaoDose: '12,5-25 mg IV/IM',
          unidade: 'mg',
          doseMinima: 12.5,
          doseMaxima: 25,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náusea/Vômito',
          descricaoDose: '12,5-25 mg IV/IM a cada 4-6h',
          unidade: 'mg',
          doseMinima: 12.5,
          doseMaxima: 25,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação',
          descricaoDose: '12,5-25 mg IV/IM',
          unidade: 'mg',
          doseMinima: 12.5,
          doseMaxima: 25,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação leve',
          descricaoDose: '25-50 mg IV/IM',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náusea/Vômito',
          descricaoDose: '12,5-25 mg IV/IM a cada 4-6h',
          unidade: 'mg',
          doseMinima: 12.5,
          doseMaxima: 25,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pré-medicação',
          descricaoDose: '25-50 mg IM 1h antes',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      indicacoes.addAll([
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação (usar com cautela)',
          descricaoDose: '6,25-12,5 mg IV/IM (reduzir 50%)',
          unidade: 'mg',
          doseMinima: 6.25,
          doseMaxima: 12.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náusea/Vômito',
          descricaoDose: '6,25-12,5 mg IV/IM',
          unidade: 'mg',
          doseMinima: 6.25,
          doseMaxima: 12.5,
          peso: peso,
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
    String? textoDose;
    bool doseLimite = false;

    if (unidade == null || unidade.isEmpty) {
      // Para indicações que são apenas texto informativo
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 4),
            Text(
              descricaoDose,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],
        ),
      );
    }

    if (doseFixa != null) {
      textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      String minStr = doseMinima < 1 ? doseMinima.toStringAsFixed(2) : doseMinima.toStringAsFixed(1);
      String maxStr = doseMaxima < 1 ? doseMaxima.toStringAsFixed(2) : doseMaxima.toStringAsFixed(1);
      textoDose = '$minStr–$maxStr $unidade';
    } else if (dosePorKg != null) {
      double doseCalc = dosePorKg * peso;
      if (doseMaximaTotal != null && doseCalc > doseMaximaTotal) {
        doseCalc = doseMaximaTotal;
        doseLimite = true;
      }
      textoDose = '${doseCalc.toStringAsFixed(1)} $unidade';
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
