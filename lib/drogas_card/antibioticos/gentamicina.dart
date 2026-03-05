import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoGentamicina {
  static const String nome = 'Gentamicina';
  static const String idBulario = 'gentamicina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/gentamicina.json');
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
      conteudo: _buildCardGentamicina(context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome)),
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

    return _buildCardGentamicina(
      context, peso, faixaEtaria, isAdulto, isFavorito, () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardGentamicina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Antibiótico aminoglicosídeo'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 20 mg/2 mL', '10 mg/mL'),
        _linhaPreparo('Ampola 40 mg/mL', '1 mL ou 2 mL'),
        _linhaPreparo('Ampola 80 mg/2 mL', '40 mg/mL'),
        _linhaPreparo('Compatível com SF 0,9% e SG 5%', ''),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Diluir em 50-200 mL de SF ou SG 5%', ''),
        _linhaPreparo('Infusão em 30-60 minutos', ''),
        _linhaPreparo('IM: administrar sem diluição', ''),
        _linhaPreparo('Estabilidade: 24h ambiente', ''),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Bactericida concentração-dependente'),
        _textoObs('Espectro: Gram-negativos aeróbios'),
        _textoObs('Sinergismo com beta-lactâmicos para Gram+ (endocardite)'),
        _textoObs('NEFROTÓXICO e OTOTÓXICO - monitorar'),
        _textoObs('Pico sérico: 5-10 mcg/mL | Vale: < 2 mcg/mL'),
        _textoObs('Dose única diária preferível (menos toxicidade)'),
        _textoObs('Ajuste por ClCr OBRIGATÓRIO'),
        _textoObs('Evitar uso > 7-10 dias'),
        _textoObs('Categoria D na gestação'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Dose única diária (padrão)',
          descricaoDose: '5-7 mg/kg IV 1x/dia',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 7,
          doseMaxima: 500,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Dose fracionada tradicional',
          descricaoDose: '1-2,5 mg/kg IV a cada 8h',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sinergismo endocardite',
          descricaoDose: '3 mg/kg/dia IV dividido 8/8h ou 1x/dia',
          unidade: 'mg',
          dosePorKg: 3,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'ITU não complicada',
          descricaoDose: '5 mg/kg IV 1x/dia',
          unidade: 'mg',
          dosePorKg: 5,
          doseMaxima: 400,
          peso: peso,
        ),
      ];
    } else {
      return [
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pediatria (> 1 mês)',
          descricaoDose: '2,5 mg/kg IV a cada 8h',
          unidade: 'mg',
          dosePorKg: 2.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Dose única diária pediátrica',
          descricaoDose: '5-7,5 mg/kg IV 1x/dia',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 7.5,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido') ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'RN prematuro < 30 sem',
            descricaoDose: '5 mg/kg IV a cada 48h',
            unidade: 'mg',
            dosePorKg: 5,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'RN prematuro 30-36 sem',
            descricaoDose: '4-5 mg/kg IV a cada 36h',
            unidade: 'mg',
            dosePorKgMinima: 4,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'RN termo',
            descricaoDose: '4-5 mg/kg IV a cada 24h',
            unidade: 'mg',
            dosePorKgMinima: 4,
            dosePorKgMaxima: 5,
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
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;
    bool doseLimite = false;

    if (dosePorKg != null) {
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
