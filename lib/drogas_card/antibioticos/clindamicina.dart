import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoClindamicina {
  static const String nome = 'Clindamicina';
  static const String idBulario = 'clindamicina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/clindamicina.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Clindamicina tem indicações para todas as faixas etárias exceto RN
    return faixaEtaria != 'RN';
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
      conteudo: _buildCardClindamicina(
        context,
        peso,
        isAdulto,
        faixaEtaria, // Pass faixaEtaria to _buildCardClindamicina
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

    return _buildCardClindamicina(
      context,
        peso,
        isAdulto,
        faixaEtaria, // Pass faixaEtaria to _buildCardClindamicina
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardClindamicina(BuildContext context, double peso, bool isAdulto, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClindamicina._textoObs('Antibiótico lincosamida, bacteriostático'),
        MedicamentoClindamicina._textoObs('Ativo contra cocos Gram-positivos e anaeróbios'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClindamicina._linhaPreparo('Frasco 600 mg/4 mL', 'Para uso IV'),
        MedicamentoClindamicina._linhaPreparo('Cápsulas 300 mg', 'Para uso VO'),
        MedicamentoClindamicina._linhaPreparo('Creme vaginal', 'Para uso tópico'),
        MedicamentoClindamicina._linhaPreparo('Solução tópica 1%', 'Para uso cutâneo'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClindamicina._linhaPreparo('IV: 600 mg em 100 mL SF ou SG 5%', 'Infusão lenta ≥30 minutos'),
        MedicamentoClindamicina._linhaPreparo('VO: manter intervalo de 6/6h ou 8/8h', 'Administrar com ou sem alimentos'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoClindamicina._textoObs('Excelente cobertura contra cocos Gram-positivos e anaeróbios'),
        MedicamentoClindamicina._textoObs('Opção para alérgicos à penicilina'),
        MedicamentoClindamicina._textoObs('Bloqueia toxinas de Streptococcus pyogenes e Staphylococcus aureus'),
        MedicamentoClindamicina._textoObs('Risco de colite associada ao uso (C. difficile)'),
        MedicamentoClindamicina._textoObs('Não requer ajuste para função renal — metabolismo hepático'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso') {
      // Adultos
      indicacoes.addAll([
        MedicamentoClindamicina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções de pele, partes moles e odontogênicas',
          descricaoDose: '300–600 mg VO ou IV a cada 6–8h',
          unidade: 'mg',
          doseMinima: 300,
          doseMaxima: 600,
          peso: peso,
        ),
        MedicamentoClindamicina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções intra-abdominais e pélvicas',
          descricaoDose: '600–900 mg IV a cada 8h',
          unidade: 'mg',
          doseMinima: 600,
          doseMaxima: 900,
          peso: peso,
        ),
        MedicamentoClindamicina._linhaIndicacaoDoseCalculada(
          titulo: 'Toxina estreptocócica (Strep. pyogenes)',
          descricaoDose: '600–900 mg IV a cada 8h associada à penicilina',
          unidade: 'mg',
          doseMinima: 600,
          doseMaxima: 900,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente' || faixaEtaria == 'Criança' || faixaEtaria == 'Adolescente') {
      // Pediatria
      indicacoes.addAll([
        MedicamentoClindamicina._linhaIndicacaoDoseCalculada(
          titulo: 'Infecções pediátricas (≥1 mês)',
          descricaoDose: '10–13 mg/kg/dose IV ou VO a cada 8h (máx 600 mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 13,
          doseMaxima: 600,
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
    bool doseLimite = false;

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
        doseLimite = true;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
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
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
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
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade600,
                        fontStyle: FontStyle.italic,
                      ),
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
