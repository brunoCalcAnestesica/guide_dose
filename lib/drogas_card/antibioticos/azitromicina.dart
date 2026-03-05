import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAzitromicina {
  static const String nome = 'Azitromicina';
  static const String idBulario = 'azitromicina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/azitromicina.json');
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
      conteudo: _buildCardAzitromicina(context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome)),
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

    return _buildCardAzitromicina(
      context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardAzitromicina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico macrolídeo (azalídeo)'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Pó liofilizado: 500 mg', 'Frasco-ampola'),
        _linhaPreparo('Comprimido: 250 mg, 500 mg', 'Via oral'),
        _linhaPreparo('Suspensão oral: 40 mg/mL', 'Pediátrico'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir 500 mg em 4,8 mL de água estéril', '100 mg/mL'),
        _linhaPreparo('Diluir em 250-500 mL de SF ou SG 5%', '1-2 mg/mL'),
        _linhaPreparo('Infusão em 1-3 horas (1 mg/mL = 3h, 2 mg/mL = 1h)', ''),
        _linhaPreparo('NÃO administrar em bolus IV', ''),
        _linhaPreparo('Estabilidade: 24h ambiente, 7 dias refrigerado', ''),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Bacteriostático (bactericida em altas concentrações)'),
        _textoObs('Excelente cobertura de atípicos (Mycoplasma, Chlamydia, Legionella)'),
        _textoObs('Meia-vida longa: 68-72h (dose única diária)'),
        _textoObs('Concentração tecidual >> sérica'),
        _textoObs('RISCO DE PROLONGAMENTO QT - monitorar ECG'),
        _textoObs('Não requer ajuste renal'),
        _textoObs('Interação com warfarina (monitorar INR)'),
        _textoObs('Categoria B na gestação'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia comunitária grave',
          descricaoDose: '500 mg IV 1x/dia por 2-5 dias',
          unidade: 'mg',
          doseFixa: 500,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia comunitária (VO)',
          descricaoDose: '500 mg VO 1x/dia por 3 dias',
          unidade: 'mg',
          doseFixa: 500,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Doença inflamatória pélvica',
          descricaoDose: '500 mg IV 1x/dia por 1-2 dias, depois VO',
          unidade: 'mg',
          doseFixa: 500,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Uretrite/Cervicite (Chlamydia)',
          descricaoDose: '1 g VO dose única',
          unidade: 'mg',
          doseFixa: 1000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia MAC (HIV)',
          descricaoDose: '1200 mg VO 1x/semana',
          unidade: 'mg',
          doseFixa: 1200,
          peso: peso,
        ),
      ];
    } else {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia pediátrica (IV)',
          descricaoDose: '10 mg/kg IV 1x/dia (máx 500 mg)',
          unidade: 'mg',
          dosePorKg: 10,
          doseMaxima: 500,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia pediátrica (VO)',
          descricaoDose: '10 mg/kg VO no dia 1, depois 5 mg/kg dias 2-5',
          unidade: 'mg',
          dosePorKg: 10,
          doseMaxima: 500,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Otite média',
          descricaoDose: '30 mg/kg VO dose única ou 10 mg/kg por 3 dias',
          unidade: 'mg',
          dosePorKg: 30,
          doseMaxima: 1500,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Faringite estreptocócica',
          descricaoDose: '12 mg/kg VO 1x/dia por 5 dias (máx 500 mg)',
          unidade: 'mg',
          dosePorKg: 12,
          doseMaxima: 500,
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
