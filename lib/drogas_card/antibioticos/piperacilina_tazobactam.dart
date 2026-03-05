import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPiperacilinaTazobactam {
  static const String nome = 'Piperacilina-Tazobactam';
  static const String idBulario = 'piperacilina_tazobactam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/piperacilina_tazobactam.json');
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
      conteudo: _buildCardPipTazo(context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome)),
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

    return _buildCardPipTazo(
      context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardPipTazo(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico beta-lactâmico + inibidor de beta-lactamase'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Pó liofilizado: 2,25 g (2 g + 0,25 g)', 'Frasco-ampola'),
        _linhaPreparo('Pó liofilizado: 4,5 g (4 g + 0,5 g)', 'Frasco-ampola'),
        _linhaPreparo('Compatível com SF 0,9% e SG 5%', ''),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir 2,25 g em 10 mL', ''),
        _linhaPreparo('Reconstituir 4,5 g em 20 mL', ''),
        _linhaPreparo('Infusão: diluir em 50-150 mL', 'Infundir em 30 min'),
        _linhaPreparo('Infusão prolongada: 4h (melhora PK/PD)', ''),
        _linhaPreparo('Estabilidade: 24h ambiente, 48h refrigerado', ''),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Amplo espectro: Gram+, Gram-, anaeróbios, Pseudomonas'),
        _textoObs('NÃO ativo contra MRSA e ESBL (na maioria dos casos)'),
        _textoObs('Bactericida tempo-dependente'),
        _textoObs('Ajuste renal: ClCr 20-40: 2,25g 6/6h | ClCr <20: 2,25g 8/8h'),
        _textoObs('Hemodiálise: 2,25g após sessão'),
        _textoObs('Contém 2,35 mEq de sódio por grama'),
        _textoObs('Pode prolongar tempo de sangramento'),
        _textoObs('Aumenta nefrotoxicidade com vancomicina'),
        _textoObs('Categoria B na gestação'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves (padrão)',
          descricaoDose: '4,5 g IV a cada 6h',
          unidade: 'g',
          doseFixa: 4.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia nosocomial',
          descricaoDose: '4,5 g IV a cada 6h',
          unidade: 'g',
          doseFixa: 4.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecção intra-abdominal',
          descricaoDose: '3,375-4,5 g IV a cada 6-8h',
          unidade: 'g',
          doseMinima: 3.375,
          doseMaxima: 4.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Neutropenia febril',
          descricaoDose: '4,5 g IV a cada 6h',
          unidade: 'g',
          doseFixa: 4.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções moderadas',
          descricaoDose: '3,375 g IV a cada 6h',
          unidade: 'g',
          doseFixa: 3.375,
          peso: peso,
        ),
      ];
    } else {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções pediátricas (> 2 meses)',
          descricaoDose: '100 mg/kg (pipera) IV a cada 8h',
          unidade: 'mg',
          dosePorKg: 100,
          doseMaxima: 4000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves/Pseudomonas',
          descricaoDose: '100 mg/kg (pipera) IV a cada 6h (máx 4g/dose)',
          unidade: 'mg',
          dosePorKg: 100,
          doseMaxima: 4000,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido' || faixaEtaria == 'Lactente') ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Neonatos < 2 meses',
            descricaoDose: '75-100 mg/kg (pipera) IV a cada 8-12h',
            unidade: 'mg',
            dosePorKgMinima: 75,
            dosePorKgMaxima: 100,
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
    double? doseCalculada;
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      textoDose = '${doseFixa} $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
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
      textoDose = '$doseMinima–$doseMaxima $unidade';
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
