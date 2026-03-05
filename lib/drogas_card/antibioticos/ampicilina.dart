import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAmpicilina {
  static const String nome = 'Ampicilina';
  static const String idBulario = 'ampicilina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ampicilina.json');
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
      conteudo: _buildCardAmpicilina(context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome)),
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

    return _buildCardAmpicilina(
      context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardAmpicilina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico beta-lactâmico, aminopenicilina'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Pó liofilizado: 500 mg, 1 g', 'Frasco-ampola'),
        _linhaPreparo('Compatível com SF 0,9% e SG 5%', ''),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir 500 mg em 5 mL de água estéril', '100 mg/mL'),
        _linhaPreparo('Reconstituir 1 g em 10 mL de água estéril', '100 mg/mL'),
        _linhaPreparo('IV direto: infundir em 3-5 min', ''),
        _linhaPreparo('Infusão: diluir em 50-100 mL, infundir em 15-30 min', ''),
        _linhaPreparo('Estabilidade: 1h ambiente (usar rapidamente)', ''),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Bactericida tempo-dependente'),
        _textoObs('Espectro: Streptococcus, Enterococcus faecalis, Listeria'),
        _textoObs('Boa penetração no SNC'),
        _textoObs('NÃO ativo contra MRSA, maioria das Enterobacteriaceae'),
        _textoObs('Ajuste renal: ClCr 10-50: a cada 6-12h | ClCr <10: a cada 12-24h'),
        _textoObs('Rash cutâneo comum (especialmente com mononucleose)'),
        _textoObs('Alergia cruzada com penicilinas'),
        _textoObs('Categoria B na gestação'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções moderadas',
          descricaoDose: '1-2 g IV a cada 6h',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Meningite bacteriana',
          descricaoDose: '2 g IV a cada 4h',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Endocardite por Enterococcus',
          descricaoDose: '2 g IV a cada 4h (+ aminoglicosídeo)',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Listeriose',
          descricaoDose: '2 g IV a cada 4h',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia GBS intraparto',
          descricaoDose: '2 g IV (ataque) + 1 g a cada 4h',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
      ];
    } else {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções pediátricas',
          descricaoDose: '50-100 mg/kg/dia IV dividido a cada 6h',
          unidade: 'mg',
          dosePorKgMinima: 50,
          dosePorKgMaxima: 100,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Meningite pediátrica',
          descricaoDose: '200-400 mg/kg/dia IV dividido a cada 4-6h',
          unidade: 'mg',
          dosePorKgMinima: 200,
          dosePorKgMaxima: 400,
          doseMaxima: 12000,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido') ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'RN < 7 dias',
            descricaoDose: '50 mg/kg IV a cada 12h',
            unidade: 'mg',
            dosePorKg: 50,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'RN > 7 dias',
            descricaoDose: '50 mg/kg IV a cada 8h',
            unidade: 'mg',
            dosePorKg: 50,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Meningite neonatal',
            descricaoDose: '100 mg/kg IV a cada 6-8h',
            unidade: 'mg',
            dosePorKg: 100,
            peso: peso,
          ),
        ],
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
