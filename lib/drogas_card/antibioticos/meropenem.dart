import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMeropenem {
  static const String nome = 'Meropenem';
  static const String idBulario = 'meropenem';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/meropenem.json');
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
      conteudo: _buildCardMeropenem(
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

    return _buildCardMeropenem(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardMeropenem(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico beta-lactâmico, carbapenêmico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Pó liofilizado: 500 mg, 1 g', 'Frasco-ampola'),
        _linhaPreparo('Compatível com SF 0,9% e SG 5%', ''),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir 500 mg em 10 mL de diluente', '50 mg/mL'),
        _linhaPreparo('Reconstituir 1 g em 20 mL de diluente', '50 mg/mL'),
        _linhaPreparo('Infusão: diluir em 50-200 mL SF ou SG 5%', ''),
        _linhaPreparo('Bolus: infundir em 3-5 min', ''),
        _linhaPreparo('Infusão prolongada: 3h (melhora PK/PD)', ''),
        _linhaPreparo('Estabilidade: 4h ambiente, 24h refrigerado', ''),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Carbapenêmico de amplo espectro - bactericida tempo-dependente'),
        _textoObs('Ativo contra Gram+, Gram-, anaeróbios e ESBL'),
        _textoObs('NÃO ativo contra MRSA e Enterococcus faecium'),
        _textoObs('Penetração no SNC: adequada para meningite'),
        _textoObs('Ajuste renal: ClCr 26-50: 1g 12/12h | ClCr 10-25: 500mg 12/12h'),
        _textoObs('Hemodiálise: dose após sessão'),
        _textoObs('Reduz níveis de valproato em até 90%'),
        _textoObs('Pode causar convulsões (menos que imipenem)'),
        _textoObs('Categoria B na gestação'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves (padrão)',
          descricaoDose: '1 g IV a cada 8h',
          unidade: 'mg',
          doseFixa: 1000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Meningite bacteriana',
          descricaoDose: '2 g IV a cada 8h',
          unidade: 'mg',
          doseFixa: 2000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pneumonia nosocomial/VAP',
          descricaoDose: '1-2 g IV a cada 8h',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecção intra-abdominal',
          descricaoDose: '1 g IV a cada 8h',
          unidade: 'mg',
          doseFixa: 1000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Neutropenia febril',
          descricaoDose: '1-2 g IV a cada 8h',
          unidade: 'mg',
          doseMinima: 1000,
          doseMaxima: 2000,
          peso: peso,
        ),
      ];
    } else {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções graves pediátricas',
          descricaoDose: '20 mg/kg IV a cada 8h (máx 1 g/dose)',
          unidade: 'mg',
          dosePorKg: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Meningite pediátrica',
          descricaoDose: '40 mg/kg IV a cada 8h (máx 2 g/dose)',
          unidade: 'mg',
          dosePorKg: 40,
          doseMaxima: 2000,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido') ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'RN < 7 dias',
            descricaoDose: '20 mg/kg IV a cada 12h',
            unidade: 'mg',
            dosePorKg: 20,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'RN > 7 dias',
            descricaoDose: '20 mg/kg IV a cada 8h',
            unidade: 'mg',
            dosePorKg: 20,
            peso: peso,
          ),
        ],
        _linhaIndicacaoDoseCalculada(
          titulo: 'Fibrose cística',
          descricaoDose: '40 mg/kg IV a cada 8h (máx 2 g/dose)',
          unidade: 'mg',
          dosePorKg: 40,
          doseMaxima: 2000,
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
    double? doseMinima,
    double? doseMaxima,
    double? doseFixa,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
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
