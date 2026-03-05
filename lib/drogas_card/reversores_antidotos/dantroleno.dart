import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDantroleno {
  static const String nome = 'Dantroleno';
  static const String idBulario = 'dantroleno';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/dantroleno.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Dantroleno tem indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardDantroleno(
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

    return _buildCardDantroleno(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardDantroleno(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDantroleno._textoObs('Relaxante muscular de ação direta'),
        MedicamentoDantroleno._textoObs('Antagonista do cálcio no retículo sarcoplasmático'),
        MedicamentoDantroleno._textoObs('Antídoto para hipertermia maligna'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDantroleno._linhaPreparo('Pó para reconstituição 20mg', 'Frasco-ampola'),
        MedicamentoDantroleno._linhaPreparo('Cápsula 25mg e 50mg', 'Via oral'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDantroleno._linhaPreparo('Reconstituir com 60mL água destilada', 'Agitar vigorosamente até dissolução completa'),
        MedicamentoDantroleno._linhaPreparo('Filtrar através de filtro 5μm', 'Remover partículas não dissolvidas'),
        MedicamentoDantroleno._linhaPreparo('Administrar IV lento (10–15 min)', 'Monitorar função cardíaca'),
        MedicamentoDantroleno._linhaPreparo('Manter refrigerado após reconstituição', 'Usar em 6 horas'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDantroleno._textoObs('Contraindicação: hipersensibilidade conhecida'),
        MedicamentoDantroleno._textoObs('Monitorar função hepática (hepatotoxicidade)'),
        MedicamentoDantroleno._textoObs('Pode causar fraqueza muscular generalizada'),
        MedicamentoDantroleno._textoObs('Interage com bloqueadores neuromusculares'),
        MedicamentoDantroleno._textoObs('Monitorar temperatura corporal e função cardíaca'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'Recém-nascido') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Dose inicial',
          descricaoDose: '2,5 mg/kg IV em bolus (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Doses adicionais',
          descricaoDose: '1 mg/kg IV se sintomas persistirem (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 1,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de hipertermia maligna',
          descricaoDose: '2,5 mg/kg IV 75 min antes da cirurgia',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Dose inicial',
          descricaoDose: '2,5 mg/kg IV em bolus (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Doses adicionais',
          descricaoDose: '1 mg/kg IV se sintomas persistirem (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 1,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de hipertermia maligna',
          descricaoDose: '2,5 mg/kg IV 75 min antes da cirurgia',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Dose inicial',
          descricaoDose: '2,5 mg/kg IV em bolus (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Doses adicionais',
          descricaoDose: '1 mg/kg IV se sintomas persistirem (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 1,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de hipertermia maligna',
          descricaoDose: '2,5 mg/kg IV 75 min antes da cirurgia',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Dose inicial',
          descricaoDose: '2,5 mg/kg IV em bolus (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Doses adicionais',
          descricaoDose: '1 mg/kg IV se sintomas persistirem (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 1,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de hipertermia maligna',
          descricaoDose: '2,5 mg/kg IV 75 min antes da cirurgia',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Dose inicial',
          descricaoDose: '2,5 mg/kg IV em bolus (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Doses adicionais',
          descricaoDose: '1 mg/kg IV se sintomas persistirem (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 1,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de hipertermia maligna',
          descricaoDose: '2,5 mg/kg IV 75 min antes da cirurgia',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Dose inicial',
          descricaoDose: '2,5 mg/kg IV em bolus (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertermia maligna - Doses adicionais',
          descricaoDose: '1 mg/kg IV se sintomas persistirem (dose cumulativa máx 10 mg/kg)',
          unidade: 'mg',
          dosePorKg: 1,
          peso: peso,
        ),
        MedicamentoDantroleno._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia de hipertermia maligna',
          descricaoDose: '2,5 mg/kg IV 75 min antes da cirurgia',
          unidade: 'mg',
          dosePorKg: 2.5,
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
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMinima,
    double? doseMaxima,
    double? doseFixa,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (doseFixa != null) {
      if (doseFixa < 1) {
        textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
      }
      // Verificar se dose mínima não ultrapassou a máxima
      if (doseMin > doseMax) doseMin = doseMax;
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
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