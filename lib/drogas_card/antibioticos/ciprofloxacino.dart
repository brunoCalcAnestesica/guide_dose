import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCiprofloxacino {
  static const String nome = 'Ciprofloxacino';
  static const String idBulario = 'ciprofloxacino';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ciprofloxacino.json');
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
      conteudo: _buildCardCiprofloxacino(context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome)),
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

    return _buildCardCiprofloxacino(
      context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardCiprofloxacino(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico fluoroquinolona de segunda geração'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Bolsa 200 mg/100 mL', '2 mg/mL'),
        _linhaPreparo('Bolsa 400 mg/200 mL', '2 mg/mL'),
        _linhaPreparo('Comprimido 250 mg, 500 mg', 'Via oral'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Infusão pronta para uso', 'Não necessita diluição'),
        _linhaPreparo('Infusão em 60 minutos (200 mg) ou 60-90 min (400 mg)', ''),
        _linhaPreparo('Proteger da luz durante infusão', ''),
        _linhaPreparo('Incompatível com soluções alcalinas', ''),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Bactericida concentração-dependente'),
        _textoObs('Excelente atividade contra Gram-negativos e Pseudomonas'),
        _textoObs('EVITAR em pediatria (risco de lesão cartilaginosa)'),
        _textoObs('RISCO DE PROLONGAMENTO QT - monitorar ECG'),
        _textoObs('Tendinopatia e ruptura de tendão (especialmente Aquiles)'),
        _textoObs('Ajuste renal: ClCr 30-50: 50% dose | ClCr <30: 50% dose 12/12h'),
        _textoObs('Interage com teofilina, warfarina, ciclosporina'),
        _textoObs('Não administrar com antiácidos, ferro, zinco'),
        _textoObs('Categoria C na gestação'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves',
          descricaoDose: '400 mg IV a cada 8-12h',
          unidade: 'mg',
          doseMinima: 400,
          doseMaxima: 400,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia nosocomial',
          descricaoDose: '400 mg IV a cada 8h',
          unidade: 'mg',
          doseFixa: 400,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'ITU complicada',
          descricaoDose: '400 mg IV a cada 12h',
          unidade: 'mg',
          doseFixa: 400,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'ITU não complicada',
          descricaoDose: '200 mg IV a cada 12h',
          unidade: 'mg',
          doseFixa: 200,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções intra-abdominais',
          descricaoDose: '400 mg IV a cada 12h (+ metronidazol)',
          unidade: 'mg',
          doseFixa: 400,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia meningocócica',
          descricaoDose: '500 mg VO dose única',
          unidade: 'mg',
          doseFixa: 500,
          peso: peso,
        ),
      ];
    } else {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pediatria (uso restrito)',
          descricaoDose: '10-15 mg/kg IV a cada 12h (máx 400 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 15,
          doseMaxima: 400,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Fibrose cística',
          descricaoDose: '15-20 mg/kg IV a cada 8-12h (máx 400 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 15,
          dosePorKgMaxima: 20,
          doseMaxima: 400,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções por Pseudomonas',
          descricaoDose: '15 mg/kg IV a cada 8h (máx 400 mg/dose)',
          unidade: 'mg',
          dosePorKg: 15,
          doseMaxima: 400,
          peso: peso,
        ),
      ];
    }
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
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMinima,
    double? doseMaxima,
    double? doseFixa,
    required double peso,
  }) {
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
    } else if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Dose calculada: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (doseLimite) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Dose limitada por segurança',
                      style: TextStyle(fontSize: 10, color: Colors.orange.shade600, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
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
